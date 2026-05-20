import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'bike_detail_screen.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});
  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  List<dynamic> bikesList = [];

  @override
  void initState() {
    super.initState();
    loadBikes();
  }

  void loadBikes() async {
    try {
      final data = await Supabase.instance.client.from('bikes').select().order('id', ascending: false);
      setState(() {
        bikesList = data;
      });
    } catch (e) {
      print('Veri çekme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Musteri Ekrani'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => loadBikes(),
        child: bikesList.isEmpty
            ? const Center(child: Text('Kayitli bisiklet bulunamadi.'))
            : ListView.builder(
                itemCount: bikesList.length,
                itemBuilder: (context, index) {
                  final bike = bikesList[index];
                  bool isAvail = bike['is_available'] ?? true;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.directions_bike, color: Colors.blue),
                      title: Text('${bike['brand']} - ${bike['model']}'),
                      subtitle: Text('Saatlik: ${bike['hourly_rate']} TL'),
                      trailing: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isAvail ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isAvail ? 'Musait' : 'Kirada',
                          style: TextStyle(color: isAvail ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BikeDetailScreen(bike: bike),
                          ),
                        );
                        loadBikes();
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}