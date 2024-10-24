import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GridPhoto {
  final Uint8List imageBytes;
  String caption;
  GridPhoto({required this.imageBytes, this.caption = ''});
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<GridPhoto> gridPhotos = [];
  final ImagePicker _picker = ImagePicker();
  Uint8List? profilePhotoBytes;

  // Najm Add these variables
  String name = '';
  String phone = '';
  String specialty = '';
  String country = '';
  String city = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('freelancers')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        setState(() {
          name = userData.data()?['name'] ?? '';
          phone = userData.data()?['phone number'] ?? '';
          specialty = userData.data()?['specialty'] ?? '';
          country = userData.data()?['country'] ?? '';
          city = userData.data()?['city'] ?? '';
        });
      }
    }
  }

  Future<void> _updateUserData() async {
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
  }
// Najm End of Update User Data
  // Updated profile photo function
  Future<void> _updateProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          profilePhotoBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error picking image')),
      );
    }
  }

  // Updated grid photo function
  Future<void> _addGridPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        
        String? caption = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            String tempCaption = '';
            return AlertDialog(
              title: const Text('Add a caption'),
              content: TextField(
                onChanged: (value) => tempCaption = value,
                decoration: const InputDecoration(
                  hintText: 'Enter caption for your photo',
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () => Navigator.pop(context, tempCaption),
                ),
              ],
            );
          },
        );

        if (mounted) {
          setState(() {
            gridPhotos.add(GridPhoto(
              imageBytes: bytes,
              caption: caption ?? '',
            ));
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error adding photo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Profile Header
              Stack(
                alignment: Alignment.center,
                children: [
                  // Profile circle
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
                    child: profilePhotoBytes != null
                        ? ClipOval(
                            child: Image.memory(
                              profilePhotoBytes!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person, size: 60);
                              },
                            ),
                          )
                        : const Icon(Icons.person, size: 60),
                  ),
                  
                  // Camera button
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
              
              // Name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  phone,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              
              // Specialty
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  specialty,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              
              // Location
              Text(
                '$city, $country',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Edit Profile Button
              ElevatedButton(
                onPressed: _showEditProfileDialog,
                child: const Text('Edit Profile'),
              ),

              const SizedBox(height: 24),
              
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat('6142', 'Posts'),
                  _buildStat('1470', 'Friends'),
                  _buildStat('889', 'Groups'),
                ],
              ),

              const SizedBox(height: 24),
              
              // Photo Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: gridPhotos.length + 1,
                itemBuilder: (context, index) {
                  if (index == gridPhotos.length) {
                    return GestureDetector(
                      onTap: _addGridPhoto,
                      child: Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.add_photo_alternate,
                          color: Color(0xFF008080),
                          size: 40,
                        ),
                      ),
                    );
                  }
                  
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(
                        gridPhotos[index].imageBytes,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                      if (gridPhotos[index].caption.isNotEmpty)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            color: Colors.black54,
                            child: Text(
                              gridPhotos[index].caption,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
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
