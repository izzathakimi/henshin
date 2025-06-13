import '../common/Henshin_theme.dart';
import '../common/Henshin_widgets.dart';
import '../signup_with_email_page/signup_with_email_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../common/henshin_util.dart';
import '../home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../forgot_password_page/forgot_password_page_widget.dart';
import '../admin/admin_dashboard.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    textController1 = TextEditingController();
    textController2 = TextEditingController();
    passwordVisibility = false;
  }

  Future<void> _signIn() async {
    print('DEBUG: _signIn called');
    print('DEBUG: Email: \\${textController1?.text}');
    print('DEBUG: Password: (length: \\${textController2?.text.length})');
    if (formKey.currentState!.validate()) {
      try {
        print('DEBUG: Form validated, attempting Firebase signInWithEmailAndPassword');
        showSnackbar(context, 'Sedang log masuk...', loading: true);

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: textController1!.text,
          password: textController2!.text,
        );
        print('DEBUG: signInWithEmailAndPassword success: user=${userCredential.user?.uid}');

        if (userCredential.user != null) {
          print('DEBUG: Fetching user doc from Firestore for uid: \\${userCredential.user!.uid}');
          // Get user role from Firestore
          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();
          print('DEBUG: Firestore userDoc.exists = \\${userDoc.exists}');

          if (userDoc.exists) {
            String role = userDoc.get('role') as String;
            print('DEBUG: User role: \\${role}');
            // Navigate based on role
            if (role == 'admin') {
              print('DEBUG: Navigating to AdminDashboard');
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AdminDashboard()),
                (route) => false,
              );
              print('DEBUG: Navigation to AdminDashboard done');
            } else {
              print('DEBUG: Navigating to HomePage');
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
              print('DEBUG: Navigation to HomePage done');
            }
          } else {
            print('DEBUG: User doc not found in Firestore');
            showSnackbar(context, 'User data not found. Please contact support.');
          }
        }
      } on FirebaseAuthException catch (e) {
        print('DEBUG: FirebaseAuthException: code=\\${e.code}, message=\\${e.message}');
        if (e.code == 'user-not-found') {
          showSnackbar(context, 'No user found for that email.');
        } else if (e.code == 'wrong-password') {
          showSnackbar(context, 'Wrong password provided for that user.');
        } else {
          showSnackbar(context, 'Error: \\${e.message}');
        }
      } catch (e, stack) {
        print('LOGIN ERROR: \\${e}');
        print('STACKTRACE: \\${stack}');
        showSnackbar(context, 'An error occurred: \\${e}');
      }
    } else {
      print('DEBUG: Form validation failed');
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
                'RuralHub.',
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
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(32, 32, 32, 0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Ubah kerjaya anda bersama kami!',
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
                      'Log masuk untuk meneruskan.',
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
                    hintText: 'Alamat Email',
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
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(32, 16, 32, 0),
                child: TextFormField(
                  controller: textController2,
                  obscureText: !passwordVisibility,
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
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                      return 'Perlu diisi';
                    }
                    return null;
                  },
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ForgotPasswordPageWidget(),
                          ),
                        );
                      },
                      child: Text(
                        'Lupa Kata Laluan?',
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
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(32, 32, 32, 0),
                      child: FFButtonWidget(
                        onPressed: _signIn,
                        text: 'Log Masuk',
                        options: FFButtonOptions(
                          width: 130,
                          height: 45,
                          color: HenshinTheme.primaryColor,
                          textStyle: HenshinTheme.subtitle2.override(
                            fontFamily: 'NatoSansKhmer',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 25, 16, 32),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tiada akaun?',
                      style: HenshinTheme.bodyText1,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                      child: InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SignupWithEmailPageWidget(),
                            ),
                          );
                        },
                        child: Text(
                          'Daftar Akaun',
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
