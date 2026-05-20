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
  
  String secilenRol = 'customer'; 
  bool kayitModu = false; 


  void islemiYap() async {
    final supabase = Supabase.instance.client;

    if (kayitModu) {

      await supabase.auth.signUp(
        email: emailField.text,
        password: passwordField.text,
        data: {'role': secilenRol}, 
      );
      

      setState(() {
        kayitModu = false;
      });
    } else {
      // Öğrenci Usulü Giriş Yapma İşlemi
      final cevap = await supabase.auth.signInWithPassword(
        email: emailField.text,
        password: passwordField.text,
      );


      final rol = cevap.user?.userMetadata?['role'] ?? 'customer';


      if (rol == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHome()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CustomerHome()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kayitModu ? 'Hesap Oluştur' : 'Sisteme Giriş'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailField,
                decoration: const InputDecoration(labelText: 'E-posta Adresiniz'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordField,
                decoration: const InputDecoration(labelText: 'Şifreniz'),
                obscureText: true, 
              ),

              if (kayitModu) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: secilenRol,
                  items: const [
                    DropdownMenuItem(value: 'customer', child: Text('Müşteri Hesabı')),
                    DropdownMenuItem(value: 'admin', child: Text('Yönetici Hesabı')),
                  ],
                  onChanged: (deger) {
                    setState(() {
                      secilenRol = deger!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Kullanıcı Tipi Seçin'),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: islemiYap,
                child: Text(kayitModu ? 'Kayıt İşlemini Tamamla' : 'Giriş Yap'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    kayitModu = !kayitModu;
                  });
                },
                child: Text(kayitModu
                    ? 'Zaten hesabım var, Giriş Yap'
                    : 'Hesabınız yok mu? Yeni Hesap Açın'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}