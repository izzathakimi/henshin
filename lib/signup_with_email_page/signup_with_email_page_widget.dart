import '../common/Henshin_theme.dart';
import '../common/Henshin_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../common/henshin_util.dart';
import '../home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../freelancer_page/frelancer_page_widget.dart';
import '../login_with_email_page/login_with_email_page_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupWithEmailPageWidget extends StatefulWidget {
  const SignupWithEmailPageWidget({super.key});

  @override
  SignupWithEmailPageWidgetState createState() => SignupWithEmailPageWidgetState();
}

class SignupWithEmailPageWidgetState extends State<SignupWithEmailPageWidget> {
  TextEditingController? textController1;
  TextEditingController? textController2;
  TextEditingController? textController3;
  late bool passwordVisibility1;
  late bool passwordVisibility2;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    textController1 = TextEditingController();
    textController2 = TextEditingController();
    textController3 = TextEditingController();
    passwordVisibility1 = false;
    passwordVisibility2 = false;
  }

  Future<void> _createAccount() async {
    if (formKey.currentState!.validate()) {
      if (textController2?.text != textController3?.text) {
        showSnackbar(context, 'Kata laluan tidak sepadan');
        return;
      }

      try {
        showSnackbar(context, 'Mencipta akaun...', loading: true);

        // Create the user account
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: textController1!.text,
          password: textController2!.text,
        );

        if (userCredential.user != null) {
          // Create user document in Firestore with role
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'email': textController1!.text,
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
            'isSuspended': false,
          });

          // Navigate to freelancer page
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const FreelancerPageWidget()),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          showSnackbar(context, 'Kata laluan yang diberikan terlalu lemah.');
        } else if (e.code == 'email-already-in-use') {
          showSnackbar(context, 'Akaun sudah wujud untuk email tersebut.');
        } else {
          showSnackbar(context, 'Error: ${e.message}');
        }
      } catch (e) {
        showSnackbar(context, 'Ralat telah berlaku. Sila cuba lagi.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Scaffold(
        key: scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: InkWell(
            onTap: () async {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.keyboard_arrow_left,
              color: Colors.white,
              size: 24,
            ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  32, 32, 32, 0),
                              child: Text(
                                'Sertai komuniti kami hari ini',
                                textAlign: TextAlign.center,
                                style: HenshinTheme.bodyText1.override(
                                  fontFamily: 'NatoSansKhmer',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  useGoogleFonts: false,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 4, 16, 0),
                            child: Text(
                              'Cipta akaun untuk meneruskan.',
                              style: HenshinTheme.bodyText1.override(
                                fontFamily: 'NatoSansKhmer',
                                color: const Color(0xCD303030),
                                useGoogleFonts: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(32, 45, 32, 0),
                        child: TextFormField(
                          controller: textController1,
                          obscureText: false,
                          decoration: InputDecoration(
                            hintText: 'Alamat Emel',
                            hintStyle: HenshinTheme.bodyText1.override(
                              fontFamily: 'NatoSansKhmer',
                              color: Colors.grey[400],
                              useGoogleFonts: false,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                          ),
                          style: HenshinTheme.bodyText1.override(
                            fontFamily: 'NatoSansKhmer',
                            color: Colors.black87,
                            useGoogleFonts: false,
                          ),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(32, 16, 32, 0),
                        child: TextFormField(
                          controller: textController2,
                          obscureText: !passwordVisibility1,
                          decoration: InputDecoration(
                            hintText: 'Kata Laluan',
                            hintStyle: HenshinTheme.bodyText1.override(
                              fontFamily: 'NatoSansKhmer',
                              color: Colors.grey[400],
                              useGoogleFonts: false,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            suffixIcon: InkWell(
                              onTap: () => setState(() =>
                                  passwordVisibility1 = !passwordVisibility1),
                              child: Icon(
                                passwordVisibility1
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey[400],
                                size: 22,
                              ),
                            ),
                          ),
                          style: HenshinTheme.bodyText1.override(
                            fontFamily: 'NatoSansKhmer',
                            color: Colors.black87,
                            useGoogleFonts: false,
                          ),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(32, 16, 32, 0),
                        child: TextFormField(
                          controller: textController3,
                          obscureText: !passwordVisibility2,
                          decoration: InputDecoration(
                            hintText: 'Sahkan Kata Laluan',
                            hintStyle: HenshinTheme.bodyText1.override(
                              fontFamily: 'NatoSansKhmer',
                              color: Colors.grey[400],
                              useGoogleFonts: false,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            suffixIcon: InkWell(
                              onTap: () => setState(() =>
                                  passwordVisibility2 = !passwordVisibility2),
                              child: Icon(
                                passwordVisibility2
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey[400],
                                size: 22,
                              ),
                            ),
                          ),
                          style: HenshinTheme.bodyText1.override(
                            fontFamily: 'NatoSansKhmer',
                            color: Colors.black87,
                            useGoogleFonts: false,
                          ),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Perlu diisi';
                            }
                            return null;
                          },
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  32, 32, 32, 0),
                              child: FFButtonWidget(
                                onPressed: _createAccount,
                                text: 'Cipta Akaun',
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
                                  borderRadius: 36,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                'Dengan mencipta akaun, anda bersetuju dengan Terma Perkhidmatan dan Dasar Privasi kami.',
                                textAlign: TextAlign.center,
                                style: HenshinTheme.bodyText1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(16, 25, 16, 32),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sudah mempunyai akaun?',
                              style: HenshinTheme.bodyText1,
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  4, 0, 0, 0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginWithEmailPageWidget(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Log Masuk',
                                  style: HenshinTheme.bodyText1.override(
                                    fontFamily: 'NatoSansKhmer',
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    useGoogleFonts: false,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    textController1?.dispose();
    textController2?.dispose();
    textController3?.dispose();
    super.dispose();
  }
}
