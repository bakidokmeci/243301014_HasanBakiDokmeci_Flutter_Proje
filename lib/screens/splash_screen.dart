import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'admin_home.dart';
import 'customer_home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    gitmeyeHazirlan();
  }

  void gitmeyeHazirlan() {
    Future.delayed(const Duration(seconds: 2), () {
      final oturum = Supabase.instance.client.auth.currentSession;
      if (oturum != null) {
        final kullanici = Supabase.instance.client.auth.currentUser;
        final rol = kullanici?.userMetadata?['role'] ?? 'customer';
        if (rol == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminHome()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CustomerHome()));
        }
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_bike, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Bisiklet Kiralama',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}