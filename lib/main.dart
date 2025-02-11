import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kashmeer_milk/FireBase/firebase_options.dart';
import 'package:kashmeer_milk/Splash Screen/splash_screen.dart';
import 'package:kashmeer_milk/functions.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Funs()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kashmeer Milk',
        home: SplashScreen(),
      ),
    );
  }
}
