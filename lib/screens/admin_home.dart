import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/log_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});
  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final marka = TextEditingController();
  final model = TextEditingController();
  final ucret = TextEditingController();
  List<dynamic> liste = [];

  @override
  void initState() {
    super.initState();
    verileriGetir();
  }

  void verileriGetir() async {
    try {
      final res = await Supabase.instance.client.from('bikes').select().order('id', ascending: false);
      setState(() => liste = res);
    } catch (e) {
      print("Veri cekme hatasi: $e");
    }
  }

  void ekle() async {
    if (marka.text.isEmpty || model.text.isEmpty || ucret.text.isEmpty) return;
    try {
      await Supabase.instance.client.from('bikes').insert({
        'brand': marka.text,
        'model': model.text,
        'hourly_rate': double.parse(ucret.text),
      });
      await LogService.logAction('Admin yeni bisiklet ekledi: ${marka.text} - ${model.text}');
      marka.clear();
      model.clear();
      ucret.clear();
      verileriGetir();
    } catch (hata) {
      print("Ekleme hatasi: $hata");
    }
  }

  void sil(int id, String bMarka, String bModel) async {
    try {
      await Supabase.instance.client.from('bikes').delete().eq('id', id);
      await LogService.logAction('Admin bisiklet sildi: $bMarka - $bModel');
      verileriGetir();
    } catch (hata) {
      print("Silme hatasi: $hata");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yonetici Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: verileriGetir),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: marka, decoration: const InputDecoration(labelText: 'Marka', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: model, decoration: const InputDecoration(labelText: 'Model', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: ucret, decoration: const InputDecoration(labelText: 'Saatlik Ucret', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: ekle,
                child: const Text('Yeni Bisiklet Ekle'),
              ),
            ),
            const Divider(height: 30),
            Expanded(
              child: liste.isEmpty
                  ? const Center(child: Text('Henuz bisiklet eklenmedi.'))
                  : ListView.builder(
                      itemCount: liste.length,
                      itemBuilder: (context, i) {
                        bool durum = liste[i]['is_available'] ?? true;
                        return Card(
                          child: ListTile(
                            title: Text('${liste[i]['brand']} - ${liste[i]['model']}'),
                            subtitle: Text('${liste[i]['hourly_rate']} TL - ${durum ? "Musait" : "Kirada"}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => sil(liste[i]['id'], liste[i]['brand'], liste[i]['model']),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}