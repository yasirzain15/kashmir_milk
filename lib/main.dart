import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:kashmeer_milk/FireBase/firebase_options.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:kashmeer_milk/Splash Screen/splash_screen.dart';
import 'package:kashmeer_milk/functions.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('customers');
  Hive.registerAdapter(CustomerAdapter());

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
