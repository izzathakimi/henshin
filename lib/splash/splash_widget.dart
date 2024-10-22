import '../common/henshin_animations.dart';
import '../common/henshin_theme.dart';
import '../welcome_page/welcome_page_widget.dart';
import 'package:flutter/material.dart';

class SplashWidget extends StatefulWidget {
  const SplashWidget({super.key});

  @override
  _SplashWidgetState createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget>
    with TickerProviderStateMixin {
  final animationsMap = {
    'containerOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      duration: 1000,
      delay: 1000,
      fadeIn: true,
    ),
    'columnOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      duration: 100,
      fadeIn: true,
    ),
    'imageOnPageLoadAnimation': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      duration: 600,
      delay: 1100,
      fadeIn: true,
      scale: 0.4,
    ),
    'textOnPageLoadAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      duration: 600,
      delay: 1100,
      fadeIn: true,
      slideOffset: const Offset(0, -70),
    ),
    'textOnPageLoadAnimation2': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      duration: 600,
      delay: 1100,
      fadeIn: true,
      slideOffset: const Offset(0, -100),
    ),
  };
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    startPageLoadAnimations(
      animationsMap.values
          .where((anim) => anim.trigger == AnimationTrigger.onPageLoad),
      this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFF1E2429),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WelcomePageWidget(),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/shot-cropped-1576957517751.png',
                width: 140,
                height: 140,
                fit: BoxFit.fitHeight,
              ).animated([animationsMap['imageOnPageLoadAnimation']]),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                child: Text(
                  'henshin',
                  style: HenshinTheme.title1.override(
                    fontFamily: 'NatoSansKhmer',
                    color: const Color(0xFF313131),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    useGoogleFonts: false,
                  ),
                ).animated([animationsMap['textOnPageLoadAnimation1']]),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 120),
                child: Text(
                  'Job and Freelancing Marketplace !',
                  style: HenshinTheme.bodyText1.override(
                    fontFamily: 'NatoSansKhmer',
                    color: const Color(0xBF696969),
                    useGoogleFonts: false,
                  ),
                ).animated([animationsMap['textOnPageLoadAnimation2']]),
              ),
            ],
          ),
        ).animated([animationsMap['columnOnPageLoadAnimation']]),
      ).animated([animationsMap['containerOnPageLoadAnimation']]),
    );
  }
}
