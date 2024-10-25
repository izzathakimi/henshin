import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:flutterizzat/app_state.dart';
import 'package:go_router/go_router.dart';

class NetworkImageWithLoader extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? backgroundColor;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  const NetworkImageWithLoader({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.backgroundColor,
    this.errorWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[200],
      child: imageUrl.isEmpty
          ? errorWidget ?? const Icon(Icons.image_not_supported, color: Colors.grey)
          : Image.network(
              imageUrl,
              fit: fit,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: frame != null ? child : loadingWidget ?? _defaultLoader(),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading image: $error');
                debugPrint('Stack trace: $stackTrace');
                return errorWidget ??
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.grey),
                        SizedBox(height: 4),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    );
              },
            ),
    );
  }

  Widget _defaultLoader() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF008080)),
      ),
    );
  }
}

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
  final ImageCropper cropper = ImageCropper(); 

  
  bool _isLoading = false;
  String? profilePhotoUrl;
  String name = '';
  String phone = '';
  String specialty = '';
  String country = '';
  String city = '';
  List<Post> posts = [];
  final _formKey = GlobalKey<FormState>();
  String _description = '';
  Uint8List? _imageBytes;
  String? _imageName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserPosts();
  }

 Future<void> _loadUserData() async {
    try {
      if (user != null) {
        print('Loading user data for ID: ${user!.uid}');
        final userData = await _firestore
            .collection('freelancers')
            .doc(user!.uid)
            .get();

        if (userData.exists) {
          final data = userData.data();
          print('User data loaded: $data');
          setState(() {
            name = data?['name'] ?? '';
            phone = data?['phone number'] ?? '';
            specialty = data?['specialty'] ?? '';
            country = data?['country'] ?? '';
            city = data?['city'] ?? '';
            profilePhotoUrl = data?['profilePhotoUrl'];
          });
          print('Profile photo URL: $profilePhotoUrl');
        } else {
          print('User document does not exist');
        }
      } else {
        print('No user logged in');
      }
    } catch (e) {
      print('Error loading user data: $e');
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
    print('Starting image upload to path: $path');
    final ref = _storage.ref().child(path);
    
    // Upload the file
    final uploadTask = await ref.putFile(imageFile);
    
    // Get download URL immediately after upload completes
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    print('Upload complete. Download URL: $downloadUrl');
    return downloadUrl;
  } catch (e) {
    print('Error uploading image: $e');
    return null;
  }
}

Future<void> _updateProfilePhoto() async {
    try {
      setState(() => _isLoading = true);
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        print('Image selected: ${image.path}');

        // Upload to Firebase Storage
        final String path = 'profile_photos/${user!.uid}/profile.jpg';
        print('Uploading to path: $path');
        
        String? imageUrl;
        if (kIsWeb) {
          // Handle web upload
          final imageBytes = await image.readAsBytes();
          final ref = _storage.ref().child(path);
          final metadata = SettableMetadata(contentType: 'image/jpeg');
          final uploadTask = ref.putData(imageBytes, metadata);
          final snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        } else {
          // Handle mobile upload
          final imageFile = File(image.path);
          imageUrl = await _uploadImage(imageFile, path);
        }

        print('Upload complete, URL: $imageUrl');

        if (imageUrl != null) {
          await _firestore
              .collection('freelancers')
              .doc(user!.uid)
              .update({'profilePhotoUrl': imageUrl});

          setState(() => profilePhotoUrl = imageUrl);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')),
          );
        }
      }
    } catch (e) {
      print('Error in _updateProfilePhoto: $e');
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
        String? description = await _showDescriptionDialog();
        if (description == null) return;

        setState(() => _isLoading = true);

        final String path = 'posts/${user!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        String? imageUrl;

        if (kIsWeb) {
          // Handle web upload
          print('Uploading image for web...');
          final imageBytes = await image.readAsBytes();
          final ref = _storage.ref().child(path);
          final metadata = SettableMetadata(contentType: 'image/jpeg');
          try {
            final uploadTask = ref.putData(imageBytes, metadata);
            final snapshot = await uploadTask;
            imageUrl = await snapshot.ref.getDownloadURL();
            print('Image uploaded successfully. URL: $imageUrl');
          } catch (e) {
            print('Error uploading image: $e');
            throw e;
          }
        } else {
          // Handle mobile upload
          final imageFile = File(image.path);
          imageUrl = await _uploadImage(imageFile, path);
        }

        if (imageUrl != null) {
          print('Creating post document...');
          final post = Post(
            id: '',
            userId: user!.uid,
            description: description,
            imageUrl: imageUrl,
            timestamp: DateTime.now(),
          );

          try {
            final docRef = await _firestore.collection('posts').add(post.toJson());
            print('Post created successfully with ID: ${docRef.id}');
            await _loadUserPosts();
          } catch (e) {
            print('Error creating post document: $e');
            throw e;
          }
        }
      }
    } catch (e) {
      print('Error in _createPost: $e');
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

  void _showPostDetail(Post post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NetworkImageWithLoader(
                imageUrl: post.imageUrl,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(post.description),
              Text('Likes: ${post.likes}'),
              // Add more details as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageName = pickedFile.name;
        });

        if (kIsWeb) {
          // For web
          _imageBytes = await pickedFile.readAsBytes();
        } else {
          // For mobile platforms
          final File file = File(pickedFile.path);
          _imageBytes = await file.readAsBytes();
        }

        setState(() {});
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showAddPostDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Post'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    onSaved: (value) => _description = value ?? '',
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter a description'
                        : null,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pick Image'),
                  ),
                  SizedBox(height: 20),
                  if (_imageBytes != null)
                    Image.memory(_imageBytes!, height: 200),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                _imageBytes = null;
                _imageName = null;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Post'),
              onPressed: () async {
                if (_formKey.currentState!.validate() && _imageBytes != null) {
                  _formKey.currentState!.save();
                  try {
                    final appState = Provider.of<ApplicationState>(context, listen: false);
                    await appState.addPost(_description, _imageBytes!, _imageName!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Post created successfully')),
                    );
                    Navigator.of(context).pop();
                    await _loadUserPosts();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error creating post: $e')),
                    );
                  }
                } else if (_imageBytes == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select an image')),
                  );
                }
              },
            ),
          ],
        );
      },
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
        onPressed: _showAddPostDialog,
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
                  child: profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty
                      ? Image.network(
                          profilePhotoUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF008080)),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image: $error');
                            return const Icon(Icons.person, size: 60, color: Colors.grey);
                          },
                        )
                      : const Icon(Icons.person, size: 60, color: Colors.grey),
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

// ... existing code ...

  Widget _buildPostItem(Post post) {
    return GestureDetector(
      onTap: () => _showPostDetail(post),
      child: NetworkImageWithLoader(
        imageUrl: post.imageUrl,
        backgroundColor: Colors.grey[200],
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
