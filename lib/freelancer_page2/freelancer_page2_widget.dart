import '../common/Henshin_theme.dart';
import '../common/Henshin_widgets.dart';
import 'package:flutter/material.dart';

class FreelancerPage2Widget extends StatefulWidget {
  const FreelancerPage2Widget({super.key});

  @override
  _FreelancerPage2WidgetState createState() => _FreelancerPage2WidgetState();
}

class _FreelancerPage2WidgetState extends State<FreelancerPage2Widget> {
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
                            'Link Account (3 of 4 steps)',
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
                              'Social Media',
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
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                          child: Text(
                            'Facebook',
                            style: HenshinTheme.title3,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0x4C303030),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(10, 3, 10, 3),
                              child: Text(
                                'Connect',
                                style: HenshinTheme.bodyText1,
                              ),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                          child: Text(
                            'Google',
                            style: HenshinTheme.title3,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0x4C303030),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(10, 3, 10, 3),
                              child: Text(
                                'Connect',
                                style: HenshinTheme.bodyText1,
                              ),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                          child: Text(
                            'Behance',
                            style: HenshinTheme.title3,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0x4C303030),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(10, 3, 10, 3),
                              child: Text(
                                'Connect',
                                style: HenshinTheme.bodyText1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                              'Personal Website',
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
                            controller: textController,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'eg. www.bongthorn.dev',
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
                                      text: 'Finish',
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
