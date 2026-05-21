import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/log_service.dart';
import 'admin_home.dart';
import 'customer_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailField = TextEditingController();
  final passwordField = TextEditingController();
  String secilenRol = 'customer';
  bool kayitModu = false;

  void islemiYap() async {
    final supabase = Supabase.instance.client;
    if (emailField.text.isEmpty || passwordField.text.isEmpty) {
      return;
    }

    try {
      if (kayitModu) {
        await supabase.auth.signUp(
          email: emailField.text,
          password: passwordField.text,
          data: {'role': secilenRol},
        );
        await LogService.logAction('Yeni kayit olusturuldu: ${emailField.text} ($secilenRol)');
        setState(() {
          kayitModu = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayit basarili! Giris yapabilirsiniz.')),
        );
      } else {
        final cevap = await supabase.auth.signInWithPassword(
          email: emailField.text,
          password: passwordField.text,
        );
        final rol = cevap.user?.userMetadata?['role'] ?? 'customer';
        await LogService.logAction('Kullanici giris yapti: ${emailField.text}');

        if (rol == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminHome()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CustomerHome()));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata olustu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_bike, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 10),
              Text(
                kayitModu ? 'Yeni Hesap Olustur' : 'Sisteme Giris Yap',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailField,
                        decoration: const InputDecoration(labelText: 'E-posta Adresiniz', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordField,
                        decoration: const InputDecoration(labelText: 'Sifreniz', border: OutlineInputBorder()),
                        obscureText: true,
                      ),
                      if (kayitModu) ...[
                        const SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          value: secilenRol,
                          items: const [
                            DropdownMenuItem(value: 'customer', child: Text('Musteri Hesabi')),
                            DropdownMenuItem(value: 'admin', child: Text('Yonetici Hesabi')),
                          ],
                          onChanged: (deger) {
                            setState(() {
                              secilenRol = deger!;
                            });
                          },
                          decoration: const InputDecoration(labelText: 'Kullanici Tipi Secin', border: OutlineInputBorder()),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: islemiYap,
                          child: Text(kayitModu ? 'Kayit Islemini Tamamla' : 'Giriş Yap'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    kayitModu = !kayitModu;
                  });
                },
                child: Text(kayitModu ? 'Zaten hesabim var, Giris Yap' : 'Hesabiniz yok mu? Yeni Hesap Acin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}