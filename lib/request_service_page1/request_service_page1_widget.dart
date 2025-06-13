import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../common/Henshin_theme.dart';
import '../common/Henshin_widgets.dart';
import '../home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../secrets.dart';

class RequestServicePage1Widget extends StatefulWidget {
  const RequestServicePage1Widget({Key? key}) : super(key: key);

  @override
  RequestServicePage1WidgetState createState() => RequestServicePage1WidgetState();
}

class RequestServicePage1WidgetState extends State<RequestServicePage1Widget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _selectedPaymentRate = 'Per Jam';
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<String?> uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = storageReference.putFile(image);
      await uploadTask;
      return await storageReference.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void navigateToSummary() async {
    double price = double.tryParse(_priceController.text) ?? 0;
    List<String> requirements = _requirementsController.text.split('\n');
    String description = _descriptionController.text;
    String location = _locationController.text;
    String? imageUrl;
    final user = FirebaseAuth.instance.currentUser;
    String? userEmail = user?.email;
    String? userUid = user?.uid;
    if (_image != null) {
      imageUrl = await uploadImage(_image!);
    }

    try {
      await FirebaseFirestore.instance.collection('service_requests').add({
        'price': price,
        'paymentRate': _selectedPaymentRate,
        'requirements': requirements,
        'description': description,
        'location': location,
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
        'createdByEmail': userEmail,
        'createdByUid': userUid,
        'approved': false,
      });

      // Show success popup
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Berjaya!', style: HenshinTheme.title3),
              content: Text(
                'Perkhidmatan anda telah disimpan! Iklan akan dipaparkan setelah diluluskan oleh admin.',
                style: HenshinTheme.bodyText1,
              ),
              actions: [
                TextButton(
                  child: Text('Balik ke Halaman Utama', style: HenshinTheme.subtitle2),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error saving to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ralat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
    // appBar: AppBar(
    //     backgroundColor: HenshinTheme.primaryColor.withOpacity(0.5), // Added opacity
    //     leading: IconButton(
    //       icon: const Icon(Icons.keyboard_arrow_left_outlined,
    //         color: Colors.black,
    //         size: 24,
    //         ),
    //       onPressed: () {
    //         Navigator.pushReplacement(
    //           context,
    //           MaterialPageRoute(builder: (context) => const HomePage()),
    //         );
    //       },
    //     ),
    //     // title: const Text('Request Service'),
    //     // elevation: 0,
    //   ),
      // Add gradient background
      body: Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: HenshinTheme.primaryGradient.map((color) => color.withOpacity(0.5)).toList(),                     stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Nyatakan Perkhidmatan Yang Ditawarkan',
                    style: HenshinTheme.title2.copyWith(fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Kami Membantu Dengan Keperluan Anda',
                    style: HenshinTheme.bodyText1.override(
                      fontFamily: 'NatoSansKhmer',
                      color: Colors.black.withOpacity(0.8),
                      useGoogleFonts: false,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F7FE),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nama Perkhidmatan/Pekerjaan',
                            style: HenshinTheme.bodyText1.override(
                              fontFamily: 'NatoSansKhmer',
                              fontWeight: FontWeight.bold,
                              useGoogleFonts: false,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Terangkan secara ringkas apa yang anda perlukan',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Upah (RM)',
                            style: HenshinTheme.bodyText1.override(
                              fontFamily: 'NatoSansKhmer',
                              fontWeight: FontWeight.bold,
                              useGoogleFonts: false,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Masukkan upah pekerjaan yang akan ditawarkan',
                              // prefixText: 'RM',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Kadar Bayaran',
                            style: HenshinTheme.bodyText1.override(
                              fontFamily: 'NatoSansKhmer',
                              fontWeight: FontWeight.bold,
                              useGoogleFonts: false,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButton<String>(
                                value: _selectedPaymentRate,
                                isExpanded: true,
                                underline: Container(),
                                items: <String>['Per Jam', 'Per Hari']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedPaymentRate = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Butiran Pekerjaan',
                            style: HenshinTheme.bodyText1.override(
                              fontFamily: 'NatoSansKhmer',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              useGoogleFonts: false,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _requirementsController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Senaraikan butiran yang perlu diberi perhatian',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Lokasi',
                            style: HenshinTheme.bodyText1.override(
                              fontFamily: 'NatoSansKhmer',
                              fontWeight: FontWeight.bold,
                              useGoogleFonts: false,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              hintText: 'Masukkan lokasi anda',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FFButtonWidget(
                    onPressed: navigateToSummary,
                    text: 'Pasang Iklan',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 50,
                      color: HenshinTheme.primaryColor,
                      textStyle: HenshinTheme.subtitle2.override(
                        fontFamily: 'NatoSansKhmer',
                        color: Colors.white,
                        useGoogleFonts: false,
                      ),
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: 18,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Anda tidak akan dicaj sekarang',
                    style: HenshinTheme.bodyText1.override(
                      fontFamily: 'NatoSansKhmer',
                      color: const Color(0xCF303030),
                      useGoogleFonts: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
