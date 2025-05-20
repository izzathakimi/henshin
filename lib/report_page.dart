import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class ReportPage extends StatefulWidget {
  final String? reportedUserId;
  final String? reportedUserName;
  final String? reporterUserId;
  final String? reporterUserName;
  final String? serviceId;
  final bool isOwner;
  const ReportPage({Key? key, this.reportedUserId, this.reportedUserName, this.reporterUserId, this.reporterUserName, this.serviceId, required this.isOwner}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _descController = TextEditingController();
  File? _imageFile;
  Uint8List? _imageBytes;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
      if (kIsWeb) {
        _imageBytes = await picked.readAsBytes();
        setState(() {});
      }
    }
  }

  Future<String?> _uploadImage() async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('report_proofs/${DateTime.now().millisecondsSinceEpoch}');
    if (kIsWeb && _imageBytes != null) {
      final uploadTask = ref.putData(_imageBytes!);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } else if (_imageFile != null) {
      final uploadTask = ref.putFile(_imageFile!);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    }
    return null;
  }

  Future<void> _submitReport() async {
    if (_descController.text.trim().isEmpty) return;
    setState(() { _isLoading = true; });
    String? mediaUrl;
    if (_imageFile != null || (kIsWeb && _imageBytes != null)) {
      mediaUrl = await _uploadImage();
    }
    await FirebaseFirestore.instance.collection('reports').add({
      'reporterUserId': widget.reporterUserId,
      'reporterUserName': widget.reporterUserName,
      'reportedUserId': widget.reportedUserId,
      'reportedUserName': widget.reportedUserName,
      'serviceId': widget.serviceId,
      'description': _descController.text.trim(),
      'mediaUrl': mediaUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
      'isOwner': widget.isOwner,
    });
    setState(() { _isLoading = false; });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ruang Lapor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nyatakan Jenis Kesalahan Yang Dilakukan:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Contoh: Penipuan, Tidak Hadir, dll.',
              ),
            ),
            const SizedBox(height: 16),
            if (_imageFile != null)
              kIsWeb && _imageBytes != null
                ? Image.memory(_imageBytes!, height: 150)
                : Image.file(_imageFile!, height: 150),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.attach_file),
                  label: Text('Muat Naik Bukti'),
                ),
                if (_imageFile != null)
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () => setState(() => _imageFile = null),
                  ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReport,
                child: _isLoading ? CircularProgressIndicator() : Text('Hantar Laporan'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 