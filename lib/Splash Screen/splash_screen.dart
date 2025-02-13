import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kashmeer_milk/Login/login_screen.dart';
import 'package:kashmeer_milk/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashServices splashScreen = SplashServices();
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    splashScreen.isLogIn(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff78c1f3),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image(
                image: AssetImage('assets/splash.png'),
              ),
            ),
            SizedBox(
              height: 35,
            ),
            Text(
              'KASHMIR FRESH MILK',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  color: Color(0xffffffff),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ));
  }
}

class SplashServices {
  void isLogIn(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user != null) {
      Timer(
        Duration(seconds: 3),
        () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
              (route) => false);
        },
      );
    } else {
      Timer(
        Duration(seconds: 3),
        () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false);
        },
      );
    }
  }
}
