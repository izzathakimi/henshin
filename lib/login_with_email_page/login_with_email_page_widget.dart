import '../common/Henshin_theme.dart';
import '../common/Henshin_widgets.dart';
import '../signup_with_email_page/signup_with_email_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../common/henshin_util.dart';
import '../home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginWithEmailPageWidget extends StatefulWidget {
  const LoginWithEmailPageWidget({super.key});

  @override
  LoginWithEmailPageWidgetState createState() =>
      LoginWithEmailPageWidgetState();
}

class LoginWithEmailPageWidgetState extends State<LoginWithEmailPageWidget> {
  TextEditingController? textController1;
  TextEditingController? textController2;
  late bool passwordVisibility;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    textController1 = TextEditingController();
    textController2 = TextEditingController();
    passwordVisibility = false;
  }

  Future<void> _signIn() async {
    if (formKey.currentState!.validate()) {
      try {
        showSnackbar(context, 'Signing in...', loading: true);
        
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: textController1!.text,
          password: textController2!.text,
        );

        if (userCredential.user != null) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          showSnackbar(context, 'No user found for that email.');
        } else if (e.code == 'wrong-password') {
          showSnackbar(context, 'Wrong password provided for that user.');
        } else {
          showSnackbar(context, 'Error: ${e.message}');
        }
      } catch (e) {
        showSnackbar(context, 'An error occurred. Please try again.');
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
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 80), // Adjust this value as needed
              Text(
                'Henshin.',
                style: GoogleFonts.ubuntu(
                  color: Colors.white,
                  fontSize: 48, // Increased from 40 to 48
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(32, 32, 32, 0),
                      child: Text(
                        'Transform your career with Henshin!',
                        textAlign: TextAlign.center,
                        style: HenshinTheme.title2,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
                    child: Text(
                      'Sign in to continue.',
                      style: HenshinTheme.bodyText1.override(
                        fontFamily: 'NatoSansKhmer',
                        color: const Color(0xCB303030),
                        useGoogleFonts: false,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(32, 45, 32, 0),
                child: TextFormField(
                  controller: textController1,
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: 'Email Address',
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
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                padding: const EdgeInsetsDirectional.fromSTEB(32, 16, 32, 0),
                child: TextFormField(
                  controller: textController2,
                  obscureText: !passwordVisibility,
                  decoration: InputDecoration(
                    hintText: 'Password',
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
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    suffixIcon: InkWell(
                      onTap: () => setState(
                        () => passwordVisibility = !passwordVisibility,
                      ),
                      child: Icon(
                        passwordVisibility
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
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center, // Changed from MainAxisAlignment.end
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0), // Removed right padding
                    child: Text(
                      'Forgot Password?',
                      style: HenshinTheme.bodyText1.override(
                        fontFamily: 'NatoSansKhmer',
                        color: Colors.white,
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
                      padding: const EdgeInsetsDirectional.fromSTEB(32, 32, 32, 0),
                      child: FFButtonWidget(
                        onPressed: _signIn,
                        text: 'Sign In',
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
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(32, 0, 0, 0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: 2,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEEEEE),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                    child: Text(
                      'or',
                      style: HenshinTheme.bodyText1,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 32, 0),
                      child: Container(
                        width: 100,
                        height: 2,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEEEEE),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(32, 4, 32, 4),
                      child: Container(
                        width: 100,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(36),
                          border: Border.all(
                            color: const Color(0x3F313131),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                'assets/images/google_icon.svg',
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                              child: Text(
                                'Continue with Google',
                                style: HenshinTheme.subtitle2.override(
                                  fontFamily: 'NatoSansKhmer',
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  useGoogleFonts: false,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                      padding: const EdgeInsetsDirectional.fromSTEB(32, 4, 32, 4),
                      child: Container(
                        width: 100,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.apple,
                              color: Colors.white,
                              size: 24,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                              child: Text(
                                'Continue with Apple',
                                style: HenshinTheme.subtitle2.override(
                                  fontFamily: 'NatoSansKhmer',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  useGoogleFonts: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 25, 16, 32),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: HenshinTheme.bodyText1,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                      child: InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupWithEmailPageWidget(),
                            ),
                          );
                        },
                        child: Text(
                          'Create Account',
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
            ],
          ),
        ),
      ),
    );
  }
}
