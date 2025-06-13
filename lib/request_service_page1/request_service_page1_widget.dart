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

  String? _descError, _priceError, _requirementsError, _locationError;

  void navigateToSummary() async {
    setState(() {
      _descError = _descriptionController.text.trim().isEmpty ? 'Sila isi nama perkhidmatan.' : null;
      _priceError = _priceController.text.trim().isEmpty ? 'Sila isi upah.' : null;
      _requirementsError = _requirementsController.text.trim().isEmpty ? 'Sila isi butiran pekerjaan.' : null;
      _locationError = _locationController.text.trim().isEmpty ? 'Sila isi lokasi.' : null;
    });
    if (_descError != null || _priceError != null || _requirementsError != null || _locationError != null) {
      return;
    }
    double price = double.tryParse(_priceController.text) ?? 0;
    List<String> requirements = _requirementsController.text.split('\n');
    String description = _descriptionController.text;
    String location = _locationController.text;
    final user = FirebaseAuth.instance.currentUser;
    String? userEmail = user?.email;
    String? userUid = user?.uid;

    try {
      await FirebaseFirestore.instance.collection('service_requests').add({
        'price': price,
        'paymentRate': _selectedPaymentRate,
        'requirements': requirements,
        'description': description,
        'location': location,
        'timestamp': FieldValue.serverTimestamp(),
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
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Service Name
                          Text(
                            'Nama Perkhidmatan/Pekerjaan',
                            style: HenshinTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.work_outline),
                              hintText: 'Terangkan secara ringkas apa yang anda perlukan',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          if (_descError != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, top: 4),
                              child: Text(_descError!, style: TextStyle(color: Colors.red, fontSize: 13)),
                            ),
                          const SizedBox(height: 18),
                          // Price
                          Text(
                            'Upah (RM)',
                            style: HenshinTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.attach_money),
                              hintText: 'Masukkan upah pekerjaan yang akan ditawarkan',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          if (_priceError != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, top: 4),
                              child: Text(_priceError!, style: TextStyle(color: Colors.red, fontSize: 13)),
                            ),
                          const SizedBox(height: 18),
                          // Payment Rate
                          Text(
                            'Kadar Bayaran',
                            style: HenshinTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.grey[100],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButton<String>(
                                value: _selectedPaymentRate,
                                isExpanded: true,
                                underline: Container(),
                                icon: Icon(Icons.arrow_drop_down),
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
                          const SizedBox(height: 18),
                          // Requirements
                          Text(
                            'Butiran Pekerjaan',
                            style: HenshinTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _requirementsController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.list_alt),
                              hintText: 'Senaraikan butiran yang perlu diberi perhatian',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          if (_requirementsError != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, top: 4),
                              child: Text(_requirementsError!, style: TextStyle(color: Colors.red, fontSize: 13)),
                            ),
                          const SizedBox(height: 18),
                          // Location
                          Text(
                            'Lokasi',
                            style: HenshinTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.location_on_outlined),
                              hintText: 'Masukkan lokasi anda',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          if (_locationError != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, top: 4),
                              child: Text(_locationError!, style: TextStyle(color: Colors.red, fontSize: 13)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: FFButtonWidget(
                    onPressed: navigateToSummary,
                    text: 'Pasang Iklan',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56,
                      color: HenshinTheme.primaryColor,
                      textStyle: HenshinTheme.subtitle2.override(
                        fontFamily: 'NatoSansKhmer',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        useGoogleFonts: false,
                      ),
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: 28,
                      elevation: 4,
                    ),
                  ),
                ),
                // Center(
                //   child: Text(
                //     'Anda tidak akan dicaj sekarang',
                //     style: HenshinTheme.bodyText1.override(
                //       fontFamily: 'NatoSansKhmer',
                //       color: const Color(0xCF303030),
                //       useGoogleFonts: false,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
