import 'package:flutter/material.dart';
import '../common/Henshin_theme.dart';
import '../common/Henshin_widgets.dart';
import '../home_page.dart'; // Import homepage widget

class RequestSummaryWidget extends StatelessWidget {
  final double price;
  final List<String> requirements;
  final String description; // Add this line

  const RequestSummaryWidget({
    Key? key,
    required this.price,
    required this.requirements,
    required this.description, // This line is already present
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Summary'),
        backgroundColor: HenshinTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price:',
              style: HenshinTheme.title3,
            ),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: HenshinTheme.bodyText1,
            ),
            SizedBox(height: 20),
            Text(
              'Requirements:',
              style: HenshinTheme.title3,
            ),
            ...requirements.map((req) => Padding(
              padding: EdgeInsets.only(left: 16, top: 8),
              child: Text('• $req', style: HenshinTheme.bodyText1),
            )),
            SizedBox(height: 40),
            Center(
              child: FFButtonWidget(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (Route<dynamic> route) => false,
                  );
                },
                text: 'Finish',
                options: FFButtonOptions(
                  width: 200,
                  height: 50,
                  color: HenshinTheme.primaryColor,
                  textStyle: HenshinTheme.subtitle2.override(
                    fontFamily: 'NatoSansKhmer',
                    color: Colors.white,
                    useGoogleFonts: false,
                  ),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
