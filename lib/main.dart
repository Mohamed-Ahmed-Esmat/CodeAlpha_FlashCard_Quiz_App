import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flash_card_quiz_app/pages/home.dart';
import 'package:flash_card_quiz_app/pages/landing_page.dart';
import 'package:flash_card_quiz_app/services/authentication_services.dart';
import 'package:flash_card_quiz_app/widgets/list_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => CardListProvider()),
  ], child: const Home()));
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthenticationService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return const LandingPage();
          } else {
            return const HomePage(); // Remove the null check operator here
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
