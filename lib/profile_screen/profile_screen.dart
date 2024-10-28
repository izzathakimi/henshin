import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:henshin/application_state.dart';
import 'package:henshin/profile_screen/profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _description = '';
  Uint8List? _imageBytes;
  String? _imageName;
  final ImagePicker _picker = ImagePicker();

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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<ApplicationState>(context);

    if (!appState.loggedIn) {
      return Scaffold(
        appBar: AppBar(title: Text('Add Post')),
        body: Center(
          child: ElevatedButton(
            child: Text('Sign In to Add Post'),
            onPressed: () {
              Navigator.pushNamed(context, '/sign-in');
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Add Post')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() &&
                        _imageBytes != null) {
                      _formKey.currentState!.save();
                      try {
                        await appState.addPost(
                            _description, _imageBytes!, _imageName!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Post created successfully')),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Profile()),
                        );
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
                  child: Text('Post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
