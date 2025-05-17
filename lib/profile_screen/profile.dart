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
import '../common/Henshin_theme.dart';

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
  final String userId;

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
    required this.userId,
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
      userId: data['userId'] ?? '',
    );
  }
}

class Profile extends StatefulWidget {
  final String? userId;
  const Profile({super.key, this.userId});

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
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  bool get isCurrentUserProfile {
    final currentUser = FirebaseAuth.instance.currentUser;
    return widget.userId == null || widget.userId == currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userId = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
    print('Fetching profile for userId: ' + (userId ?? 'null'));
    if (userId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('freelancers')
          .doc(userId)
          .get();
      print('Document exists: \\${doc.exists}');
      print('Document data: \\${doc.data()}');
      setState(() {
        userData = doc.data();
        _nameController.text = userData?['name'] ?? '';
        _phoneController.text = userData?['phone number'] ?? '';
        _specialtyController.text = userData?['specialty'] ?? '';
        _stateController.text = userData?['state'] ?? '';
        _cityController.text = userData?['city'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = widget.userId ?? user?.uid;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
          child: const Icon(
            Icons.keyboard_arrow_left_outlined,
            color: Colors.black,
            size: 24,
          ),
        ),
        actions: const [],
        centerTitle: true,
      ),
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
          child: FutureBuilder<List>(
            future: _fetchCombinedData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final completedServices = snapshot.data![0] as List<QueryDocumentSnapshot>;
              final posts = snapshot.data![1] as List<QueryDocumentSnapshot>;
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Profile info section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildProfilePicture(),
                        const SizedBox(height: 16),
                        Text(
                          userData?['name'] ?? 'Tiada Nama',
                          style: GoogleFonts.ubuntu(
                            textStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${userData?['city'] ?? '-'}, ${userData?['state'] ?? '-'}',
                          style: GoogleFonts.ubuntu(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userData?['phone number'] ?? '-',
                          style: GoogleFonts.ubuntu(
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (userData?['specialty'] != null && (userData?['specialty'] as String).isNotEmpty)
                          Text(
                            userData?['specialty'],
                            style: GoogleFonts.ubuntu(
                              textStyle: const TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ),
                        if (userData?['email'] != null && (userData?['email'] as String).isNotEmpty)
                          Text(
                            userData?['email'],
                            style: GoogleFonts.ubuntu(
                              textStyle: const TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ),
                        const SizedBox(height: 16),
                        if (isCurrentUserProfile)
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
                  // Servis Selesai Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Sejarah Perkhidmatan', style: GoogleFonts.ubuntu(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  if (completedServices.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Tiada sejarah perkhidmatan.'),
                    )
                  else
                    ...completedServices.map((doc) => _buildCompletedServiceCard(doc, userId)).toList(),
                  // Posts Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Kandungan', style: GoogleFonts.ubuntu(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  if (posts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Tiada kandungan.'),
                    )
                  else
                    ...posts.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final post = PostModel.fromFirestore(data, doc.id);
                      return _buildPostCard(post);
                    }).toList(),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: isCurrentUserProfile
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: const Icon(Icons.add_a_photo),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<List> _fetchCombinedData() async {
    final userId = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
    final serviceSnap = await FirebaseFirestore.instance
        .collection('service_requests')
        .orderBy('timestamp', descending: true)
        .get();
    final completedServices = serviceSnap.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final statusMap = data['status'] as Map<String, dynamic>?;
      final isApplicant = statusMap != null && statusMap[userId] == 'Selesai';
      final isOwner = data['createdByUid'] == userId && (statusMap?.values.contains('Selesai') ?? false);
      return isApplicant || isOwner;
    }).toList();

    final postSnap = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
    final posts = postSnap.docs;

    return [completedServices, posts];
  }

  Widget _buildCompletedServiceCard(QueryDocumentSnapshot doc, String? userId) {
    final data = doc.data() as Map<String, dynamic>;
    final ownerId = data['createdByUid'];
    final ownerEmail = data['createdByEmail'];
    final ownerReview = data['ownerReview'] as Map<String, dynamic>?;
    final applicantReview = data['applicantReview'] as Map<String, dynamic>?;
    final finishedTimestamp = ownerReview?['timestamp'] ?? applicantReview?['timestamp'];
    final statusMap = data['status'] as Map<String, dynamic>?;
    String? applicantId;
    if (statusMap != null) {
      final found = statusMap.entries.firstWhere(
        (e) => e.value == 'Selesai',
        orElse: () => const MapEntry<String, dynamic>('', null),
      );
      applicantId = found.key.isNotEmpty ? found.key : null;
    }
    final isOwner = userId == ownerId;
    final isApplicant = userId == applicantId;
    // Debug print
    print('ownerId: ' + ownerId.toString() + ', applicantId: ' + applicantId.toString() + ', isOwner: ' + isOwner.toString() + ', isApplicant: ' + isApplicant.toString());
    final otherPartyId = isOwner ? applicantId : ownerId;
    final otherPartyEmail = isOwner ? applicantId : ownerEmail;
    final label = isOwner ? 'Penerima: ' : 'Pemohon: ';
    // Debug print
    print('otherPartyId: ' + (otherPartyId?.toString() ?? 'null') + ', otherPartyEmail: ' + otherPartyEmail);
    return FutureBuilder<List<DocumentSnapshot>>(
      future: Future.wait([
        FirebaseFirestore.instance.collection('freelancers').doc(ownerId).get(),
        if (applicantId != null)
          FirebaseFirestore.instance.collection('freelancers').doc(applicantId).get(),
      ]),
      builder: (context, snap) {
        String ownerEmailFetched = ownerEmail;
        String applicantEmailFetched = '';
        if (snap.hasData) {
          final ownerData = snap.data![0].data() as Map<String, dynamic>?;
          if (ownerData != null && ownerData['email'] != null && ownerData['email'].toString().isNotEmpty) {
            ownerEmailFetched = ownerData['email'];
          } else if (ownerId != null) {
            ownerEmailFetched = ownerId;
          }
          if (applicantId != null && snap.data!.length > 1) {
            final applicantData = snap.data![1].data() as Map<String, dynamic>?;
            if (applicantData != null && applicantData['email'] != null && applicantData['email'].toString().isNotEmpty) {
              applicantEmailFetched = applicantData['email'];
            } else {
              applicantEmailFetched = applicantId;
            }
          }
        }
        final isOwner = userId == ownerId;
        final otherPartyId = isOwner ? applicantId : ownerId;
        final otherPartyEmail = isOwner ? applicantEmailFetched : ownerEmailFetched;
        final label = isOwner ? 'Penerima: ' : 'Pemohon: ';
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['description'] ?? 'Servis', style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Status: Selesai', style: TextStyle(color: Colors.green)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
                    if (otherPartyId != null && otherPartyEmail.isNotEmpty)
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => Profile(userId: otherPartyId)),
                          );
                        },
                        child: Text(otherPartyEmail, style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                      )
                    else
                      Text(otherPartyEmail),
                  ],
                ),
                if (finishedTimestamp != null)
                  Text('Tarikh Selesai: ' + _formatTimestamp(finishedTimestamp)),
                if (ownerReview != null) ...[
                  const SizedBox(height: 8),
                  Text('Ulasan Pemohon:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      Text('${ownerReview['rating'] ?? '-'}'),
                    ],
                  ),
                  Text(ownerReview['review'] ?? ''),
                ],
                if (applicantReview != null) ...[
                  const SizedBox(height: 8),
                  Text('Ulasan Penerima:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      Text('${applicantReview['rating'] ?? '-'}'),
                    ],
                  ),
                  Text(applicantReview['review'] ?? ''),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostCard(PostModel post) {
    final isCurrentUserPost = isCurrentUserProfile;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('freelancers').doc(post.userId).snapshots(),
      builder: (context, snapshot) {
        String displayName = post.username ?? 'Anonymous';
        String? profilePicUrl = post.profilePicture;
        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          if (userData['name'] != null) displayName = userData['name'];
          if (userData['profilePicture'] != null) profilePicUrl = userData['profilePicture'];
        }
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: profilePicUrl != null 
                      ? CachedNetworkImageProvider(profilePicUrl) as ImageProvider
                      : null,
                  child: profilePicUrl == null
                      ? const Icon(Icons.person, color: Colors.grey) 
                      : null,
                ),
                title: Text(displayName),
                trailing: isCurrentUserPost ? PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditPostDialog(post);
                    } else if (value == 'delete') {
                      _deletePost(post.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Sunting')), 
                    const PopupMenuItem(value: 'delete', child: Text('Padam')),
                  ],
                ) : null,
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
                child: Text(post.description),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditPostDialog(PostModel post) {
    final TextEditingController controller = TextEditingController(text: post.description);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Post'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(hintText: 'Edit caption...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('posts').doc(post.id).update({'description': controller.text});
                Navigator.pop(context);
                setState(() {});
              },
              child: Text('Simpan'),
            ),
            TextButton(
              onPressed: () async {
                await _deletePost(post.id);
                Navigator.pop(context);
              },
              child: Text('Padam', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost(String postId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
    setState(() {});
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
      final state = _stateController.text;
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
      if (state.isNotEmpty) {
        updatedData['state'] = state;
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
    final isCurrent = isCurrentUserProfile;
    return Stack(
      children: [
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('freelancers')
              .doc(widget.userId ?? user?.uid)
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
        if (isCurrent)
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
    // Set the current values to the controllers before showing the dialog
    _nameController.text = userData?['name'] ?? '';
    _phoneController.text = userData?['phone number'] ?? '';
    _specialtyController.text = userData?['specialty'] ?? '';
    _stateController.text = userData?['state'] ?? '';
    _cityController.text = userData?['city'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ubah Profil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Nombor Telefon'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _specialtyController,
                  decoration: const InputDecoration(labelText: 'Kepakaran'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _stateController,
                  decoration: const InputDecoration(labelText: 'Negeri'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'Bandar'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _updateUserData();
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return '-';
  }
}
