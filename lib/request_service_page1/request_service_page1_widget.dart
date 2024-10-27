import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../common/Henshin_theme.dart';
import '../common/Henshin_widgets.dart';
import '../request_summary/request_summary_widget.dart';

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

  void navigateToSummary() async {
    double price = double.tryParse(_priceController.text) ?? 0;
    List<String> requirements = _requirementsController.text.split('\n');
    String description = _descriptionController.text; // Retrieve description

    try {
      // Save data to Firestore
      await FirebaseFirestore.instance.collection('service_requests').add({
        'price': price,
        'requirements': requirements,
        'description': description, // Use description here
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Navigate to summary page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RequestSummaryWidget(
            price: price,
            requirements: requirements,
            description: description, // Pass description to summary page
          ),
        ),
      );
    } catch (e) {
      print('Error saving to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () async {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.keyboard_arrow_left_outlined,
            color: Colors.black,
            size: 24,
          ),
        ),
        actions: const [],
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add the "Describe your needs" field
                        Text(
                          'Describe your needs',
                          style: HenshinTheme.bodyText1.override(
                            fontFamily: 'NatoSansKhmer',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            useGoogleFonts: false,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Briefly describe what you need',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Request Service',
                  style: HenshinTheme.title2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Package & Pricing (2 of 2 steps)',
                  style: HenshinTheme.bodyText1.override(
                    fontFamily: 'NatoSansKhmer',
                    color: const Color(0x96303030),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Price',
                              style: HenshinTheme.bodyText1.override(
                                fontFamily: 'NatoSansKhmer',
                                fontWeight: FontWeight.bold,
                                useGoogleFonts: false,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF23AE10),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                  'Ringgit Malaysia',
                                  style: HenshinTheme.bodyText1.override(
                                    fontFamily: 'NatoSansKhmer',
                                    color: Colors.white,
                                    useGoogleFonts: false,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter your desired price',
                            prefixText: '\$',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Requirements',
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
                            hintText: 'List your requirements (one per line)',
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
                  text: 'Proceed to Summary',
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
                  'You won\'t be charged now',
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
    );
  }
}
