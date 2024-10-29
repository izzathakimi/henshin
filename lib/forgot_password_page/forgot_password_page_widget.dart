import '../common/Henshin_theme.dart';
import '../common/Henshin_widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPageWidget extends StatefulWidget {
  const ForgotPasswordPageWidget({super.key});

  @override
  ForgotPasswordPageWidgetState createState() =>
      ForgotPasswordPageWidgetState();
}

class ForgotPasswordPageWidgetState extends State<ForgotPasswordPageWidget> {
  TextEditingController? textController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  Future<void> checkEmail(String email) async {
    try {
      List<String> signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      setState(() {
        errorMessage =
            signInMethods.isEmpty ? 'Tiada akaun wujud dengan e-mel ini' : null;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'invalid-email') {
          errorMessage = 'Format e-mel tidak sah';
        } else {
          errorMessage = 'Sila masukkan e-mel yang sah';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
          stops: [0, 1],
          begin: AlignmentDirectional(0.87, -1),
          end: AlignmentDirectional(-0.87, 1),
        ),
      ),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                  child: Text(
                    'Lupa Kata Laluan',
                    style: HenshinTheme.bodyText1.override(
                      fontFamily: 'NatoSansKhmer',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      useGoogleFonts: false,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16, 32, 16, 0),
                    child: Text(
                      'Masukkan alamat e-mel anda di bawah untuk menerima kod bagi menetapkan kata laluan baru.',
                      textAlign: TextAlign.center,
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
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 32, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(32, 0, 32, 0),
                      child: TextFormField(
                        controller: textController,
                        obscureText: false,
                        onChanged: (value) => checkEmail(value),
                        decoration: InputDecoration(
                          hintText: 'Alamat E-mail',
                          errorText: errorMessage,
                          hintStyle: HenshinTheme.bodyText1.override(
                            fontFamily: 'NatoSansKhmer',
                            color: const Color(0xB3303030),
                            useGoogleFonts: false,
                          ),
                          fillColor:
                              Colors.white, // Set background color to white
                          filled: true, // Enable the fill color
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0x98757575),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0x98757575),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        style: HenshinTheme.bodyText1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(32, 45, 32, 0),
                    child: FFButtonWidget(
                      onPressed: () async {
                        if (textController!.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Sila masukkan e-mel anda')),
                          );
                          return;
                        }

                        if (errorMessage != null) {
                          return;
                        }

                        try {
                          final email = textController!.text.trim();
                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(email: email);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'E-mel tetapan semula kata laluan telah dihantar! Sila semak peti masuk dan folder spam anda.'),
                            ),
                          );
                          Navigator.pop(context);
                        } on FirebaseAuthException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text(e.message ?? 'Ralat telah berlaku')),
                          );
                        }
                      },
                      text: 'Hantar',
                      options: FFButtonOptions(
                        width: 130,
                        height: 45,
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
