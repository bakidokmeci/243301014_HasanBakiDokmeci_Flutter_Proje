import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yrdwiusyxudsougbprbs.supabase.co',
    anonKey: 'sb_publishable_drcCcxtnhKEOTSbOse3CiA_z6eO1iCs',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bisiklet Kiralama Sistemi',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Scaffold(
        body: Center(child: Text('Supabase Bağlantısı Hazır!')),
      ),
    );
  }
}