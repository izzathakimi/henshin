import '../common/Henshin_theme.dart';
import '../common/Henshin_widgets.dart';
import 'package:flutter/material.dart';

class ResetPasswordPageWidget extends StatefulWidget {
  const ResetPasswordPageWidget({super.key});

  @override
  ResetPasswordPageWidgetState createState() =>
      ResetPasswordPageWidgetState();
}

class ResetPasswordPageWidgetState extends State<ResetPasswordPageWidget> {
  TextEditingController? textController1;
  late bool passwordVisibility1;
  TextEditingController? textController2;
  late bool passwordVisibility2;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    textController1 = TextEditingController();
    passwordVisibility1 = false;
    textController2 = TextEditingController();
    passwordVisibility2 = false;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Scaffold(
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
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                  child: Text(
                    'Reset Password',
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
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 32, 16, 0),
                    child: Text(
                      'Set up the new password bellow.',
                      textAlign: TextAlign.center,
                      style: HenshinTheme.bodyText1.override(
                        fontFamily: 'NatoSansKhmer',
                        color: const Color(0xCB303030),
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
                      padding: const EdgeInsetsDirectional.fromSTEB(32, 0, 32, 0),
                      child: TextFormField(
                        controller: textController1,
                        obscureText: !passwordVisibility1,
                        decoration: InputDecoration(
                          hintText: 'New Password',
                          hintStyle: HenshinTheme.bodyText1.override(
                            fontFamily: 'NatoSansKhmer',
                            color: const Color(0xB3303030),
                            useGoogleFonts: false,
                          ),
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
                          suffixIcon: InkWell(
                            onTap: () => setState(
                              () => passwordVisibility1 = !passwordVisibility1,
                            ),
                            child: Icon(
                              passwordVisibility1
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xB2757575),
                              size: 20,
                            ),
                          ),
                        ),
                        style: HenshinTheme.bodyText1,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Required';
                          }
                          if (val.length < 6) {
                            return 'Password should greater than 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(32, 0, 32, 0),
                      child: TextFormField(
                        controller: textController2,
                        obscureText: !passwordVisibility2,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: HenshinTheme.bodyText1.override(
                            fontFamily: 'NatoSansKhmer',
                            color: const Color(0xB3303030),
                            useGoogleFonts: false,
                          ),
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
                          suffixIcon: InkWell(
                            onTap: () => setState(
                              () => passwordVisibility2 = !passwordVisibility2,
                            ),
                            child: Icon(
                              passwordVisibility2
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xB2757575),
                              size: 20,
                            ),
                          ),
                        ),
                        style: HenshinTheme.bodyText1,
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Required';
                          }
                          if (val.length < 6) {
                            return 'Password should greater than 6 characters';
                          }
                          return null;
                        },
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
                    padding: const EdgeInsetsDirectional.fromSTEB(32, 45, 32, 0),
                    child: FFButtonWidget(
                      onPressed: () {
                        print('Button pressed ...');
                      },
                      text: 'Finish',
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
