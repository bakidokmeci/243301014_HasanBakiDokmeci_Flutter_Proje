import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  List<dynamic> bilesList = []; 

  @override
  void initState() {
    super.initState();
    loadBikes();
  }

  void loadBikes() async {
    final data = await Supabase.instance.client.from('bikes').select();
    setState(() {
      bilesList = data;
    });
  }

  void rentBike(int id, bool currentStatus) async {
    await Supabase.instance.client
        .from('bikes')
        .update({'is_available': !currentStatus})
        .eq('id', id);
    
    loadBikes(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Müşteri Ekranı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: bilesList.length,
        itemBuilder: (context, index) {
          final bike = bilesList[index];
          bool isAvail = bike['is_available'];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.directions_bike),
              title: Text('${bike['brand']} - ${bike['model']}'),
              subtitle: Text('Saatlik: ${bike['hourly_rate']} TL'),
              trailing: ElevatedButton(
                onPressed: () => rentBike(bike['id'], isAvail),
                child: Text(isAvail ? 'Kirala' : 'Teslim Et'),
              ),
            ),
          );
        },
      ),
    );
  }
}