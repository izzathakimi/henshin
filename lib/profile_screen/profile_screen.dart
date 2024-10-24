import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';

import 'dart:io';

class Post {
  final String id;
  final String userId;
  final String description;
  final String imageUrl;
  final DateTime timestamp;
  int likes;
  List<Comment> comments;

  Post({
    required this.id,
    required this.userId,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
    this.likes = 0,
    this.comments = const [],
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'description': description,
    'imageUrl': imageUrl,
    'timestamp': timestamp,
    'likes': likes,
  };
}

class Comment {
  final String id;
  final String userId;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.userId,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'text': text,
    'timestamp': timestamp,
  };
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  
  bool _isLoading = false;
  String? profilePhotoUrl;
  String name = '';
  String phone = '';
  String specialty = '';
  String country = '';
  String city = '';
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserPosts();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final userData = await _firestore
          .collection('freelancers')
          .doc(user!.uid)
          .get();

      if (userData.exists) {
        setState(() {
          name = userData.data()?['name'] ?? '';
          phone = userData.data()?['phone number'] ?? '';
          specialty = userData.data()?['specialty'] ?? '';
          country = userData.data()?['country'] ?? '';
          city = userData.data()?['city'] ?? '';
          profilePhotoUrl = userData.data()?['profilePhotoUrl'];
        });
      }
    }
  }

  Future<void> _loadUserPosts() async {
    if (user != null) {
      final postsSnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: user!.uid)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        posts = postsSnapshot.docs
            .map((doc) => Post(
                  id: doc.id,
                  userId: doc['userId'],
                  description: doc['description'],
                  imageUrl: doc['imageUrl'],
                  timestamp: (doc['timestamp'] as Timestamp).toDate(),
                  likes: doc['likes'],
                ))
            .toList();
      });
    }
  }

  Future<void> _updateUserData() async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('freelancers')
              .doc(user.uid)
              .update({
            'name': name,
            'phone number': phone,
            'specialty': specialty,
            'country': country,
            'city': city,
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
    
  Future<String?> _uploadImage(File imageFile, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

Future<File?> _cropImage(String imagePath) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      compressQuality: 90,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit Image',
          toolbarColor: const Color(0xFF008080),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Edit Image',
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
          aspectRatioLockEnabled: true,
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
}

  Future<void> _updateProfilePhoto() async {
    try {
      setState(() => _isLoading = true);
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        // Crop image
        File? croppedImage = await _cropImage(image.path);
        if (croppedImage == null) return;

        // Upload to Firebase Storage
        final String path = 'profile_photos/${user!.uid}/profile.jpg';
        final String? imageUrl = await _uploadImage(croppedImage, path);

        if (imageUrl != null) {
          // Update Firestore
          await _firestore
              .collection('freelancers')
              .doc(user!.uid)
              .update({'profilePhotoUrl': imageUrl});

          setState(() => profilePhotoUrl = imageUrl);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile photo: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createPost() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        // Get description
        String? description = await _showDescriptionDialog();
        if (description == null) return;

        setState(() => _isLoading = true);

        // Crop image
        File? croppedImage = await _cropImage(image.path);
        if (croppedImage == null) return;

        // Upload to Firebase Storage
        final String path = 'posts/${user!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String? imageUrl = await _uploadImage(croppedImage, path);

        if (imageUrl != null) {
          // Create post in Firestore
          final post = Post(
            id: '',
            userId: user!.uid,
            description: description,
            imageUrl: imageUrl,
            timestamp: DateTime.now(),
          );

          await _firestore.collection('posts').add(post.toJson());
          await _loadUserPosts(); // Refresh posts
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _showDescriptionDialog() {
    String description = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Description'),
        content: TextField(
          onChanged: (value) => description = value,
          decoration: const InputDecoration(
            hintText: 'Write something about your post...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, description),
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await _loadUserData();
              await _loadUserPosts();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  _buildStats(),
                  _buildPosts(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF008080)),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPost,
        backgroundColor: const Color(0xFF008080),
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF008080),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: profilePhotoUrl != null
                      ? Image.network(
                          profilePhotoUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF008080)),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, size: 60);
                          },
                        )
                      : const Icon(Icons.person, size: 60),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _updateProfilePhoto,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E90FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            phone,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            specialty,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$city, $country',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showEditProfileDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008080),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

// ... Previous code remains the same ...

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat(posts.length.toString(), 'Posts'),
          _buildStat('1470', 'Friends'),
          _buildStat('889', 'Groups'),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF008080),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPosts() {
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No posts yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your posts will appear here',
                style: TextStyle(
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) => _buildPostItem(posts[index]),
    );
  }

  Widget _buildPostItem(Post post) {
    return GestureDetector(
      onTap: () => _showPostDetail(post),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF008080)),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    post.likes.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPostDetail(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        post.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            post.likes > 0 ? Icons.favorite : Icons.favorite_border,
                            color: post.likes > 0 ? Colors.red : null,
                          ),
                          onPressed: () => _toggleLike(post),
                        ),
                        Text(
                          '${post.likes} likes',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deletePost(post),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCommentsList(post),
                    const SizedBox(height: 8),
                    _buildCommentInput(post),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsList(Post post) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: post.comments.length,
      itemBuilder: (context, index) {
        final comment = post.comments[index];
        return ListTile(
          title: Text(comment.text),
          subtitle: Text(
            _formatTimestamp(comment.timestamp),
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: comment.userId == user?.uid
              ? IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteComment(post, comment),
                )
              : null,
        );
      },
    );
  }

  Widget _buildCommentInput(Post post) {
    final controller = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Add a comment...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.send),
          color: const Color(0xFF008080),
          onPressed: () {
            if (controller.text.isNotEmpty) {
              _addComment(post, controller.text);
              controller.clear();
            }
          },
        ),
      ],
    );
  }

  Future<void> _toggleLike(Post post) async {
    try {
      final postRef = _firestore.collection('posts').doc(post.id);
      final postDoc = await postRef.get();
      
      if (postDoc.exists) {
        final currentLikes = postDoc.data()?['likes'] ?? 0;
        await postRef.update({'likes': currentLikes + 1});
        await _loadUserPosts();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating like: $e')),
      );
    }
  }

  Future<void> _deletePost(Post post) async {
    try {
      // Delete image from Storage
      final ref = _storage.refFromURL(post.imageUrl);
      await ref.delete();

      // Delete post from Firestore
      await _firestore.collection('posts').doc(post.id).delete();

      // Refresh posts
      await _loadUserPosts();

      Navigator.pop(context); // Close detail view

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: $e')),
      );
    }
  }

  Future<void> _addComment(Post post, String text) async {
    try {
      final comment = Comment(
        id: '',
        userId: user!.uid,
        text: text,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('posts')
          .doc(post.id)
          .collection('comments')
          .add(comment.toJson());

      await _loadUserPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding comment: $e')),
      );
    }
  }

  Future<void> _deleteComment(Post post, Comment comment) async {
    try {
      await _firestore
          .collection('posts')
          .doc(post.id)
          .collection('comments')
          .doc(comment.id)
          .delete();

      await _loadUserPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting comment: $e')),
      );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  controller: TextEditingController(text: name),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  controller: TextEditingController(text: phone),
                  onChanged: (value) => phone = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Specialty'),
                  controller: TextEditingController(text: specialty),
                  onChanged: (value) => specialty = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Country'),
                  controller: TextEditingController(text: country),
                  onChanged: (value) => country = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'City'),
                  controller: TextEditingController(text: city),
                  onChanged: (value) => city = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                _updateUserData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

