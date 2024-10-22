import 'package:flutter/material.dart';
import 'package:henshin/common/henshin_animations.dart';
import 'package:henshin/home_page.dart';

class SplashWidget extends StatefulWidget {
  const SplashWidget({Key? key}) : super(key: key);

  @override
  _SplashWidgetState createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> with TickerProviderStateMixin {
  late AnimationInfo _animationInfo;

  @override
  void initState() {
    super.initState();
    _animationInfo = AnimationInfo(
      curve: Curves.easeInOut,
      trigger: AnimationTrigger.onPageLoad,
      duration: 1500, // Increased duration for visibility
      delay: 0,
      fadeIn: true,
      initialOpacity: 0,
      finalOpacity: 1,
    );
    createAnimation(_animationInfo, this);
    _animationInfo.animationController?.forward().then((_) {
      // Navigate to HomePage after animation completes
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/app_launcher_icon.png',
              width: 100,
              height: 100,
            ).animated([_animationInfo]),
            const SizedBox(height: 20),
            Text(
              'Henshin App',
              style: Theme.of(context).textTheme.headlineMedium,
            ).animated([_animationInfo]),
          ],
        ),
      ),
    );
  }
}
