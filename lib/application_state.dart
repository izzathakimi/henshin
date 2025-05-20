import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class ApplicationState extends ChangeNotifier {
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  ApplicationState() {
    FirebaseAuth.instance.userChanges().listen((user) async {
      _loggedIn = user != null;
      notifyListeners();
    });
  }

  Future<void> addPost(String description, Uint8List imageBytes, String imageName) async {
    if (!_loggedIn) throw Exception('Must be logged in');
    
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final imageUrl = await _uploadImage(imageBytes, imageName);

      // Get user's data from users collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final userData = userDoc.data();
      final userName = userData?['name'] ?? 'Anonymous';
      final profilePicture = userData?['profilePicture'];
      
      print('Adding post with profile picture: $profilePicture'); // Debug print

      // Create post with profilePicture field
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': user.uid,
        'username': userName,
        'profilePicture': profilePicture,  // Add this field to posts
        'description': description,
        'mediaUrl': imageUrl,
        'likes': 0,
        'comments': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });

      notifyListeners();
    } catch (e) {
      print('Error adding post: $e');
      rethrow;
    }
  }

  Future<String> _uploadImage(Uint8List imageBytes, String imageName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Must be logged in to upload an image');

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('post_images/${DateTime.now().toIso8601String()}_$imageName');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=31536000',
        customMetadata: {
          'Access-Control-Allow-Origin': '*',
        },
      );
      
      final uploadTask = ref.putData(imageBytes, metadata);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('Upload successful. Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<String> uploadProfilePicture(Uint8List imageBytes, String imageName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Must be logged in to upload profile picture');

    try {
      // Create a reference specifically for profile pictures
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');

      // Upload the file
      await storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Get the download URL
      final downloadUrl = await storageRef.getDownloadURL();
      
      // Update the user's profile picture URL in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profilePicture': downloadUrl,  // Changed back to profilePicture
      });

      print('Profile picture URL updated: $downloadUrl'); // Debug print
      notifyListeners();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      rethrow;
    }
  }
}
