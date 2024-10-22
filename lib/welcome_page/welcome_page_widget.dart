import 'package:flutter/material.dart';
import '../common/henshin_theme.dart';
import '../join_page/join_page_widget.dart';
import '../login_with_email_page/login_with_email_page_widget.dart';

class WelcomePageWidget extends StatelessWidget {
  const WelcomePageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Henshin',
              style: HenshinTheme.title1,
            ),
            const SizedBox(height: 20),
            Text(
              'Job and Freelancing Marketplace',
              style: HenshinTheme.bodyText1,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JoinPageWidget()),
                );
              },
              child: const Text('Join Henshin'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginWithEmailPageWidget()),
                );
              },
              child: const Text('Already have an account? Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
