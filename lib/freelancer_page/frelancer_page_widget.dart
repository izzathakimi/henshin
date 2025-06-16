import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../common/Henshin_theme.dart';
import '../common/Henshin_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import '../freelancer_page2/freelancer_page2_widget.dart';
// import '../home_screen/home_screen.dart';  // Import your home screen widget
// import '../home_screen/home_page.dart';  // Import your home page widget
import '../home_page.dart';  // Add this import


class FreelancerPageWidget extends StatefulWidget {
  const FreelancerPageWidget({super.key});

  @override
  FreelancerPageWidgetState createState() => FreelancerPageWidgetState();
}

class FreelancerPageWidgetState extends State<FreelancerPageWidget> {
  TextEditingController? textController1;
  TextEditingController? textController2;
  TextEditingController? textController3;
  TextEditingController? textController4;
  TextEditingController? textController5;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    textController1 = TextEditingController();
    textController2 = TextEditingController();
    textController3 = TextEditingController();
    textController4 = TextEditingController();
    textController5 = TextEditingController();
  }

  Future<void> saveFreelancerInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not signed in')),
      );
      return;
    }

    int? phoneInt;
    try {
      phoneInt = int.parse(textController2!.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombor telefon mesti nombor sahaja')),
      );
      return;
    }

    final freelancerData = {
      'name': textController1!.text,
      'phone number': phoneInt,
      'specialty': textController3!.text,
      'state': textController4!.text,
      'city': textController5!.text,
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(freelancerData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maklumat berjaya disimpan')),
      );

      // Replace the current route with HomePage instead of HomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ralat menyimpan maklumat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   automaticallyImplyLeading: false,
      //   leading: InkWell(
      //     onTap: () async {
      //       Navigator.pop(context);
      //     },
      //     child: const Icon(
      //       Icons.keyboard_arrow_left_outlined,
      //       color: Colors.white,
      //       size: 24,
      //     ),
      //   ),
      //   actions: const [],
      //   centerTitle: true,
      //   elevation: 0,
      // ),
      extendBodyBehindAppBar: true,
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
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(32, 32, 32, 0),
                      child: Text(
                        'Maklumat Peribadi',
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
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(32, 8, 32, 0),
                      child: Text(
                        '',
                        textAlign: TextAlign.center,
                        style: HenshinTheme.bodyText1.override(
                          fontFamily: 'NatoSansKhmer',
                          color: const Color(0x96303030),
                          useGoogleFonts: false,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(32, 32, 32, 0),
                      child: TextFormField(
                        controller: textController1,
                        obscureText: false,
                        decoration: InputDecoration(
                          hintText: 'Nama Penuh',
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
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(32, 16, 32, 0),
                      child: TextFormField(
                        controller: textController2,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'No. Telefon',
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
                        maxLines: 1,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Perlu diisi';
                          }
                          if (!RegExp(r'^\d{9,12}\$').hasMatch(val)) {
                            return 'Nombor telefon tidak sah';
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(32, 16, 32, 0),
                      child: TextFormField(
                        controller: textController3,
                        obscureText: false,
                        decoration: InputDecoration(
                          hintText: 'Kepakaran',
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
                        maxLines: 2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(32, 16, 32, 0),
                      child: TextFormField(
                        controller: textController4,
                        obscureText: false,
                        decoration: InputDecoration(
                          hintText: 'Negeri',
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
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(32, 16, 32, 0),
                      child: TextFormField(
                        controller: textController5,
                        obscureText: false,
                        decoration: InputDecoration(
                          hintText: 'Bandar',
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
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(32, 32, 32, 32),
                            child: FFButtonWidget(
                              onPressed: saveFreelancerInfo,
                              text: 'Simpan',
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
                    Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
