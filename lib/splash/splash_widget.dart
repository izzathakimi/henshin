import 'package:flutter/material.dart';
import 'package:henshin/common/henshin_animations.dart';
import 'package:henshin/login_with_email_page/login_with_email_page_widget.dart';

class SplashWidget extends StatefulWidget {
  const SplashWidget({super.key});

  @override
  SplashWidgetState createState() => SplashWidgetState();
}

class SplashWidgetState extends State<SplashWidget> with TickerProviderStateMixin {
  late AnimationInfo _animationInfo;

  @override
  void initState() {
    super.initState();
    _animationInfo = AnimationInfo(
      curve: Curves.easeInOut,
      trigger: AnimationTrigger.onPageLoad,
      duration: 1500,
      delay: 0,
      fadeIn: true,
      initialOpacity: 0,
      finalOpacity: 1,
    );
    createAnimation(_animationInfo, this);
    
    _navigateToLogin(); // Separate method for clarity
  }

  void _navigateToLogin() {
    _animationInfo.animationController?.forward().then((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginWithEmailPageWidget()),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _animationInfo.animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final logoSize = screenSize.width < screenSize.height
        ? screenSize.width * 0.7
        : screenSize.height * 0.7;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/images/RuralHubLogo.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
          ).animated([_animationInfo]),
        ),
      ),
    );
  }
}
