import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kashmeer_milk/FireBase/firebase_options.dart';
import 'package:kashmeer_milk/Models/customer_model.dart';
import 'package:kashmeer_milk/Splash Screen/splash_screen.dart';
import 'package:kashmeer_milk/functions.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(CustomerAdapter());

  try {
    await Future.wait([
      Hive.openBox<Customer>('customers'),
      Hive.openBox<Customer>('CSV_customers'), // Fixed box name
    ]);
  } catch (e) {
    print("Error opening Hive boxes: $e");
  }

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
