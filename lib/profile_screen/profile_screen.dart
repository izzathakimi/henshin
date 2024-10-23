import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class GridPhoto {
  final Uint8List imageBytes;
  String caption;
  GridPhoto({required this.imageBytes, this.caption = ''});
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<GridPhoto> gridPhotos = [];
  final ImagePicker _picker = ImagePicker();
  Uint8List? profilePhotoBytes;

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
              
              // Name and Status
              const Text(
                'Kurt Toms',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Status should be here',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF008080),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.message,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA500),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ],
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
}