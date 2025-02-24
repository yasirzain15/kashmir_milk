import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kashmeer_milk/FireBase/firebase_options.dart';
import 'package:kashmeer_milk/Login/signup_screen.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:kashmeer_milk/Splash Screen/splash_screen.dart';
import 'package:kashmeer_milk/functions.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CustomerAdapter());
  await Hive.openBox<Customer>('customers');
  await Hive.openBox<Customer>('CSV customers');

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
