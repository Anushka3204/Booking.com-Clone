import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:booking/core/routes.dart';
import 'package:booking/screens/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import './screens/profile.dart'; // Import profile page here.
import './screens/BookingFormScreen.dart'; // Import MyBookings screen
import './screens/mybookings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Booking Clone',
      theme: ThemeData(
        useMaterial3: true, // Enables Material 3
        colorScheme: ColorScheme.fromSeed(
            seedColor:
                const Color.fromARGB(255, 28, 96, 198)), // Uses deep blue theme
        scaffoldBackgroundColor:
            const Color.fromARGB(255, 255, 255, 255), // Sets background color
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      initialRoute: Routes.splash,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
