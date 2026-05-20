import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  String rol = 'customer';
  bool kayitModu = false;

  void islemiYap() async {

    if (emailField.text.isEmpty || passwordField.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun!')),
      );
      return;
    }

    try {
      final auth = Supabase.instance.client.auth;
      if (kayitModu) {
        await auth.signUp(email: emailField.text, password: passwordField.text, data: {'role': rol});
        setState(() => kayitModu = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayıt başarılı! Giriş yapabilirsiniz.')),
        );
      } else {
        final res = await auth.signInWithPassword(email: emailField.text, password: passwordField.text);
        String gelenRol = res.user?.userMetadata?['role'] ?? 'customer';
        
        if (gelenRol == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminHome()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CustomerHome()));
        }
      }
    } catch (hata) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${hata.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey, // Hafif gri arka plan
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(Icons.directions_bike_rounded, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 10),
              Text(
                kayitModu ? 'Yeni Hesap Oluştur' : 'Bisiklet Kiralama',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 30),


              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailField,
                        decoration: const InputDecoration(
                          labelText: 'E-posta',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordField,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Şifre',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (kayitModu) ...[
                        const SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          value: rol,
                          decoration: const InputDecoration(
                            labelText: 'Kullanıcı Tipi',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'customer', child: Text('Müşteri (Müşteri Hesabı)')),
                            DropdownMenuItem(value: 'admin', child: Text('Yönetici (Admin)')),
                          ],
                          onChanged: (val) => setState(() => rol = val!),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: islemiYap,
                          child: Text(kayitModu ? 'Kaydol' : 'Giriş Yap'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() => kayitModu = !kayitModu),
                child: Text(kayitModu ? 'Zaten hesabım var? Giriş Yap' : 'Hesabınız yok mu? Kaydolun'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}