import '../common/Henshin_theme.dart';
import '../common/Henshin_widgets.dart';
import 'package:flutter/material.dart';

class RequestServicePage3Widget extends StatefulWidget {
  const RequestServicePage3Widget({super.key});

  @override
  _RequestServicePage3WidgetState createState() =>
      _RequestServicePage3WidgetState();
}

class _RequestServicePage3WidgetState extends State<RequestServicePage3Widget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

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
                            'Request Service',
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
                            'Package & Pricing (2 of 2 steps)',
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
                              'Choose Package',
                              style: HenshinTheme.bodyText1.override(
                                fontFamily: 'NatoSansKhmer',
                                fontSize: 16,
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
                              const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0x66757575),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16, 16, 16, 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          16, 0, 0, 0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Standard',
                                            style: HenshinTheme.bodyText1
                                                .override(
                                              fontFamily: 'NatoSansKhmer',
                                              color: const Color(0xCC000000),
                                              fontWeight: FontWeight.bold,
                                              useGoogleFonts: false,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        '125\$',
                                        style:
                                            HenshinTheme.subtitle2.override(
                                          fontFamily: 'NatoSansKhmer',
                                          color: const Color(0xE5000000),
                                          useGoogleFonts: false,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Colors.black,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                              const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: HenshinTheme.primaryColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0x66757575),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16, 16, 16, 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 25,
                                    height: 25,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEEEEEE),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_outlined,
                                      color: HenshinTheme.primaryColor,
                                      size: 22,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          16, 0, 0, 0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Most Popular',
                                            style: HenshinTheme.bodyText1
                                                .override(
                                              fontFamily: 'NatoSansKhmer',
                                              color: const Color(0xFF46E447),
                                              fontWeight: FontWeight.bold,
                                              useGoogleFonts: false,
                                            ),
                                          ),
                                          Text(
                                            'Premium',
                                            style: HenshinTheme.bodyText1
                                                .override(
                                              fontFamily: 'NatoSansKhmer',
                                              color: const Color(0xE5FFFFFF),
                                              fontWeight: FontWeight.bold,
                                              useGoogleFonts: false,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        '375\$',
                                        style:
                                            HenshinTheme.subtitle2.override(
                                          fontFamily: 'NatoSansKhmer',
                                          color: const Color(0xFFF2F7FE),
                                          useGoogleFonts: false,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Color(0xE5FFFFFF),
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0x66757575),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16, 16, 16, 16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            16, 0, 0, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Business',
                                              style: HenshinTheme.bodyText1
                                                  .override(
                                                fontFamily: 'NatoSansKhmer',
                                                color: const Color(0xCC000000),
                                                fontWeight: FontWeight.bold,
                                                useGoogleFonts: false,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          '500\$',
                                          style: HenshinTheme.subtitle2
                                              .override(
                                            fontFamily: 'NatoSansKhmer',
                                            color: const Color(0xE5000000),
                                            useGoogleFonts: false,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.keyboard_arrow_right,
                                          color: Colors.black,
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
                                        16, 0, 16, 16),
                                    child: FFButtonWidget(
                                      onPressed: () {
                                        print('Button pressed ...');
                                      },
                                      text: 'Proceed to Pay',
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
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16, 0, 16, 32),
                                  child: Text(
                                    'You won\'t be charged now',
                                    textAlign: TextAlign.center,
                                    style: HenshinTheme.bodyText1.override(
                                      fontFamily: 'NatoSansKhmer',
                                      color: const Color(0xCF303030),
                                      useGoogleFonts: false,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
