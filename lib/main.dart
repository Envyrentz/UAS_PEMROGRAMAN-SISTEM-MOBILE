import 'package:flutter/material.dart';
import 'package:flutter_application_kopi_questionmark/screens/about.dart';
import 'package:flutter_application_kopi_questionmark/screens/landing.dart';
import 'package:provider/provider.dart';
import './providers/user_provider.dart'; // Import the file where UserProvider is defined
import './screens/home.dart';
import './screens/login.dart'; // Import your login page
import './screens/register.dart'; // Import your register page

void main() async {
    // Initialize Flutter app
  WidgetsFlutterBinding.ensureInitialized();

  // Create an instance of UserProvider
  UserProvider userProvider = UserProvider();

  // Check authentication status before running the app
  await userProvider.checkAuthStatus();

  // Run the app
   runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(), // Provide the UserProvider here
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/landing',
        routes: {
          '/landing': (context) => const LandingPage(),
          '/about': (context) => const AboutPage(),
          '/': (context) => const MyHomePage(title: 'IFPost'),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
        },
      ),
    );
  }
}
