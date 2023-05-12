import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:switchonkitchenscreen/sign_in_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key, required this.screen}) : super(key: key);
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SigninScreen();
        }
        return screen;
      },
    );
  }
}
