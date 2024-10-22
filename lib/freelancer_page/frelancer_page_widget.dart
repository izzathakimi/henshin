import '../common/Henshin_theme.dart';
import '../common/Henshin_widgets.dart';
import 'package:flutter/material.dart';


class FreelancerPageWidget extends StatefulWidget {
  const FreelancerPageWidget({super.key});

  @override
  _FreelancerPageWidgetState createState() => _FreelancerPageWidgetState();
}

class _FreelancerPageWidgetState extends State<FreelancerPageWidget> {
  TextEditingController? textController1;
  TextEditingController? textController2;
  TextEditingController? textController3;
  TextEditingController? textController4;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    textController1 = TextEditingController();
    textController2 = TextEditingController();
    textController3 = TextEditingController();
    textController4 = TextEditingController();
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 135),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                          child: Text(
                            'Freelancer Information',
                            style: HenshinTheme.title2,
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
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                          child: Text(
                            'Personal (1 of 4 steps)',
                            style: HenshinTheme.bodyText1.override(
                              fontFamily: 'NatoSansKhmer',
                              color: const Color(0x96303030),
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
                                const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                            child: Text(
                              'Name',
                              style: HenshinTheme.bodyText1.override(
                                fontFamily: 'NatoSansKhmer',
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
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                          child: TextFormField(
                            controller: textController1,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'eg. Bong Thorn',
                              hintStyle: HenshinTheme.bodyText1.override(
                                fontFamily: 'NatoSansKhmer',
                                color: const Color(0x98303030),
                                useGoogleFonts: false,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x65757575),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x65757575),
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
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                          child: Text(
                            'About',
                            style: HenshinTheme.bodyText1.override(
                              fontFamily: 'NatoSansKhmer',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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
                              const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                          child: TextFormField(
                            controller: textController2,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText:
                                  'eg. Experience conducting research and some ...',
                              hintStyle: HenshinTheme.bodyText1.override(
                                fontFamily: 'NatoSansKhmer',
                                color: const Color(0x98303030),
                                useGoogleFonts: false,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x65757575),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x65757575),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            style: HenshinTheme.bodyText1,
                            maxLines: 2,
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
                              const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                          child: Text(
                            'Country',
                            style: HenshinTheme.bodyText1.override(
                              fontFamily: 'NatoSansKhmer',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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
                              const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                          child: TextFormField(
                            controller: textController3,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'Cambodia',
                              hintStyle: HenshinTheme.bodyText1.override(
                                fontFamily: 'NatoSansKhmer',
                                color: const Color(0x98303030),
                                useGoogleFonts: false,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x65757575),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x65757575),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              prefixIcon: const Icon(
                                Icons.keyboard_arrow_down,
                              ),
                            ),
                            style: HenshinTheme.bodyText1,
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
                              const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                          child: Text(
                            'Country',
                            style: HenshinTheme.bodyText1.override(
                              fontFamily: 'NatoSansKhmer',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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
                              const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                          child: TextFormField(
                            controller: textController4,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'Phnom Penh',
                              hintStyle: HenshinTheme.bodyText1.override(
                                fontFamily: 'NatoSansKhmer',
                                color: const Color(0x98303030),
                                useGoogleFonts: false,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x65757575),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x65757575),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              prefixIcon: const Icon(
                                Icons.keyboard_arrow_down,
                              ),
                            ),
                            style: HenshinTheme.bodyText1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(-1, 1),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      width: 100,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        16, 0, 16, 32),
                                    child: FFButtonWidget(
                                      onPressed: () {
                                        print('Button pressed ...');
                                      },
                                      text: 'Continue',
                                      options: FFButtonOptions(
                                        width: 130,
                                        height: 45,
                                        color: HenshinTheme.primaryColor,
                                        textStyle:
                                            HenshinTheme.subtitle2.override(
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
