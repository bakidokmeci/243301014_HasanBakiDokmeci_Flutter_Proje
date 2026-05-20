import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});
  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  List<dynamic> bisikletler = [];

  @override
  void initState() {
    super.initState();
    listele();
  }

  void listele() async {
    try {
      final res = await Supabase.instance.client.from('bikes').select();
      setState(() => bisikletler = res);
    } catch (e) {
      print("Listeleme hatası: $e");
    }
  }

  void kiralaDurdur(int id, bool durum) async {
    try {
      await Supabase.instance.client.from('bikes').update({'is_available': !durum}).eq('id', id);
      listele();
    } catch (hata) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('İşlem başarısız: $hata')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Müşteri Ekranı'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: listele),
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
        padding: const EdgeInsets.all(8.0),
        child: bisikletler.isEmpty
          ? const Center(child: Text('Sistemde kiralık bisiklet bulunamadı.'))
          : ListView.builder(
              itemCount: bisikletler.length,
              itemBuilder: (context, i) {
                bool durum = bisikletler[i]['is_available'] ?? true;
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.directions_bike, color: durum ? Colors.green : Colors.orange),
                    title: Text('${bisikletler[i]['brand']} - ${bisikletler[i]['model']}'),
                    subtitle: Text('Saatlik: ${bisikletler[i]['hourly_rate']} TL'),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: durum ? Colors.green : Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => kiralaDurdur(bisikletler[i]['id'], durum),
                      child: Text(durum ? 'Kirala' : 'Teslim Et'),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}