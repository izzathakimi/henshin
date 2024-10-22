import '../common/henshin_theme.dart';
import '../common/henshin_widgets.dart';
import 'package:flutter/material.dart';

class VerifyAccountPageWidget extends StatefulWidget {
  const VerifyAccountPageWidget({super.key});

  @override
  _VerifyAccountPageWidgetState createState() =>
      _VerifyAccountPageWidgetState();
}

class _VerifyAccountPageWidgetState extends State<VerifyAccountPageWidget> {
  TextEditingController? textController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
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
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                child: Text(
                  'Verify Account',
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
                    'Enter the code or click on the link received via e-mail, to confirm your account.',
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
                      controller: textController,
                      obscureText: false,
                      decoration: InputDecoration(
                        hintText: 'Enter OPT code',
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
                      ),
                      style: HenshinTheme.bodyText1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 45, 16, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                  child: Text(
                    'Didn\'t recieve?',
                    style: HenshinTheme.bodyText1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                  child: Text(
                    'Resend code',
                    style: HenshinTheme.bodyText1.override(
                      fontFamily: 'NatoSansKhmer',
                      color: HenshinTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      useGoogleFonts: false,
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
                    text: 'Verify Code',
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
    );
  }
}
