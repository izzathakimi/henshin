import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:henshin/application_state.dart';
import 'package:henshin/profile_screen/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class PostModel {
  final String id;
  final String description;
  final DateTime timestamp;
  final String? profilePicture;
  final String? username;
  final String mediaUrl;
  final int likes;
  final int comments;
  final bool isLiked;

  PostModel({
    required this.id,
    required this.description,
    required this.timestamp,
    this.profilePicture,
    this.username,
    required this.mediaUrl,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  factory PostModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return PostModel(
      id: docId,
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] != null) 
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      profilePicture: data['profilePicture'],
      username: data['username'],
      mediaUrl: data['mediaUrl'] ?? '',
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      isLiked: (data['likedBy'] ?? []).contains(FirebaseAuth.instance.currentUser?.uid),
    );
  }
}

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? userData;

  // Define TextEditingController for each field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('freelancers')
          .doc(user.uid)
          .get();
      setState(() {
        userData = doc.data();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4A90E2).withOpacity(0.5),
              const Color(0xFF50E3C2).withOpacity(0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Profile Section
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Profile Picture Section
                        _buildProfilePicture(),
                        const SizedBox(height: 16),
                        
                        // Name
                        Text(
                          userData?['name'] ?? 'Name',
                          style: GoogleFonts.ubuntu(
                            textStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Location
                        Text(
                          '${userData?['city'] ?? 'City'}, ${userData?['country'] ?? 'Country'}',
                          style: GoogleFonts.ubuntu(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Phone Number
                        Text(
                          userData?['phone number'] ?? 'Phone Number',
                          style: GoogleFonts.ubuntu(
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Connections
                        Text(
                          '0 Kenalan',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Edit Profile Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _showEditDialog,
                          child: const Text('Ubah Maklumat'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Existing Posts Section
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No posts yet'));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        print('Raw post data: $data');
                        
                        final post = PostModel.fromFirestore(data, doc.id);
                        print('Post model data:');
                        print('- Profile Picture: ${post.profilePicture}');
                        print('- Username: ${post.username}');
                        print('- Description: ${post.description}');

                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: post.profilePicture != null 
                                      ? CachedNetworkImageProvider(
                                          post.profilePicture!,
                                          errorListener: (error) => print('Image error: $error'),
                                        ) 
                                      : null,
                                  child: post.profilePicture == null
                                      ? const Icon(Icons.person, color: Colors.grey) 
                                      : null,
                                ),
                                title: Text(post.username ?? 'Anonymous'),
                                subtitle: Text(
                                  post.timestamp.toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              if (post.mediaUrl.isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  height: 200,
                                  child: CachedNetworkImage(
                                    imageUrl: post.mediaUrl,
                                    fit: BoxFit.cover,
                                    httpHeaders: {
                                      'Access-Control-Allow-Origin': '*',
                                      'Access-Control-Allow-Methods': 'GET',
                                      'Access-Control-Allow-Headers': 'Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale',
                                    },
                                    progressIndicatorBuilder: (context, url, progress) => Center(
                                      child: CircularProgressIndicator(
                                        value: progress.progress,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) {
                                      print('Image error: $error');
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error, color: Colors.red),
                                            Text('Error loading image'),
                                            Text(error.toString(), style: TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Description: ${post.description}'), // Modified to show field name
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: post.isLiked ? Colors.red : null,
                                      ),
                                      onPressed: () => _handleLike(post.id),
                                    ),
                                    Text('${post.likes}'),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      icon: const Icon(Icons.comment),
                                      onPressed: () => _handleComment(),
                                    ),
                                    Text('${post.comments}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
        child: const Icon(Icons.add_a_photo),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _updateProfilePicture(BuildContext context) async {
    // TODO: Implement profile picture update
  }

  Future<void> _updateUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Map<String, dynamic> updatedData = {};

      // Use the text from the controllers
      final name = _nameController.text;
      final phone = _phoneController.text;
      final specialty = _specialtyController.text;
      final country = _countryController.text;
      final city = _cityController.text;

      if (name.isNotEmpty) {
        updatedData['name'] = name;
      }
      if (phone.isNotEmpty) {
        updatedData['phone number'] = phone;
      }
      if (specialty.isNotEmpty) {
        updatedData['specialty'] = specialty;
      }
      if (country.isNotEmpty) {
        updatedData['country'] = country;
      }
      if (city.isNotEmpty) {
        updatedData['city'] = city;
      }

      if (updatedData.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('freelancers')
            .doc(user.uid)
            .update(updatedData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        _fetchUserData(); // Refresh the user data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes to update')),
        );
      }
    }
  }

  Future<String?> _getImageUrl(String mediaUrl) async {
    try {
      // The mediaUrl is already the full download URL, so just return it
      return mediaUrl;
    } catch (e) {
      print('Error fetching image URL: $e');
      return null;
    }
  }

  void _handleLike(String postId) {
    // TODO: Implement like functionality using Firebase
    FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'likes': FieldValue.increment(1),
      'likedBy': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.uid])
    });
  }

  void _handleComment() {
    // TODO: Implement comment functionality
  }

  Future<void> _uploadProfilePicture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      late Uint8List imageBytes;
      if (kIsWeb) {
        // For web
        imageBytes = await pickedFile.readAsBytes();
      } else {
        // For mobile platforms
        final File file = File(pickedFile.path);
        imageBytes = await file.readAsBytes();
      }

      // Upload using ApplicationState
      final appState = Provider.of<ApplicationState>(context, listen: false);
      await appState.uploadProfilePicture(imageBytes, pickedFile.name);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully')),
      );
    } catch (e) {
      print('Error updating profile picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile picture: $e')),
      );
    }
  }

  Widget _buildProfilePicture() {
    final user = FirebaseAuth.instance.currentUser;
    
    return Stack(
      children: [
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('freelancers')
              .doc(user?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            print('Snapshot data: ${snapshot.data?.data()}');
            
            if (snapshot.hasData && snapshot.data!.exists) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final profilePicUrl = userData['profilePicture'] as String?;
              
              print('Profile URL found: $profilePicUrl');
              
              return CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: profilePicUrl != null 
                    ? CachedNetworkImageProvider(profilePicUrl) as ImageProvider
                    : null,
                child: profilePicUrl == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              );
            }
            return const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            );
          },
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _uploadProfilePicture,
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                TextField(
                  controller: _specialtyController,
                  decoration: const InputDecoration(labelText: 'Specialty'),
                ),
                TextField(
                  controller: _countryController,
                  decoration: const InputDecoration(labelText: 'Country'),
                ),
                TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateUserData();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
