import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/Henshin_theme.dart';

class CreateAdmin extends StatefulWidget {
  const CreateAdmin({Key? key}) : super(key: key);

  @override
  CreateAdminState createState() => CreateAdminState();
}

class CreateAdminState extends State<CreateAdmin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminCodeController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _passwordVisibility = false;
  bool _adminCodeVisibility = false;

  Future<void> _createAdmin() async {
    if (_formKey.currentState!.validate()) {
      // Verify admin creation code
      if (_adminCodeController.text != 'henshin') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kod pentadbir tidak sah')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Create the user account
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Create admin document in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailController.text,
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Akaun pentadbir berjaya dicipta')),
          );
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Ralat telah berlaku';
        if (e.code == 'weak-password') {
          message = 'Kata laluan yang diberikan terlalu lemah';
        } else if (e.code == 'email-already-in-use') {
          message = 'Akaun sudah wujud untuk email tersebut';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ralat telah berlaku')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                      padding: const EdgeInsetsDirectional.fromSTEB(32, 32, 32, 0),
                      child: Text(
                        'Cipta Akaun Pentadbir',
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
                      child: Text(
                        'Isi maklumat di bawah untuk mencipta akaun pentadbir.',
                        style: HenshinTheme.bodyText1.override(
                          fontFamily: 'NatoSansKhmer',
                          color: const Color(0xCD303030),
                          useGoogleFonts: false,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(32, 45, 32, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Alamat Emel',
                          hintStyle: HenshinTheme.bodyText1.override(
                            fontFamily: 'NatoSansKhmer',
                            color: Colors.grey[400],
                            useGoogleFonts: false,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_passwordVisibility,
                        decoration: InputDecoration(
                          hintText: 'Kata Laluan',
                          hintStyle: HenshinTheme.bodyText1.override(
                            fontFamily: 'NatoSansKhmer',
                            color: Colors.grey[400],
                            useGoogleFonts: false,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          suffixIcon: InkWell(
                            onTap: () => setState(
                                () => _passwordVisibility = !_passwordVisibility),
                            child: Icon(
                              _passwordVisibility
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _adminCodeController,
                        obscureText: !_adminCodeVisibility,
                        decoration: InputDecoration(
                          hintText: 'Kod Pentadbir',
                          hintStyle: HenshinTheme.bodyText1.override(
                            fontFamily: 'NatoSansKhmer',
                            color: Colors.grey[400],
                            useGoogleFonts: false,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          suffixIcon: InkWell(
                            onTap: () => setState(
                                () => _adminCodeVisibility = !_adminCodeVisibility),
                            child: Icon(
                              _adminCodeVisibility
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
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createAdmin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HenshinTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(36),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Cipta Akaun Pentadbir',
                                  style: HenshinTheme.subtitle2.override(
                                    fontFamily: 'NatoSansKhmer',
                                    color: Colors.white,
                                    useGoogleFonts: false,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }
} 