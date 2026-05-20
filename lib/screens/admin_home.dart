import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {

  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final rateController = TextEditingController();
  
  List<dynamic> bikes = []; 

  @override
  void initState() {
    super.initState();
    getBikes();
  }


  void getBikes() async {
    final data = await Supabase.instance.client
        .from('bikes')
        .select()
        .order('id', ascending: false);
    
    setState(() {
      bikes = data;
    });
  }


  void addBike() async {
    await Supabase.instance.client.from('bikes').insert({
      'brand': brandController.text,
      'model': modelController.text,
      'hourly_rate': double.parse(rateController.text),
    });
    

    brandController.clear();
    modelController.clear();
    rateController.clear();
    getBikes(); 
  }


  void deleteBike(int id) async {
    await Supabase.instance.client.from('bikes').delete().eq('id', id);
    getBikes(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yönetici Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: getBikes,
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: brandController, decoration: const InputDecoration(labelText: 'Marka')),
            TextField(controller: modelController, decoration: const InputDecoration(labelText: 'Model')),
            TextField(controller: rateController, decoration: const InputDecoration(labelText: 'Saatlik Ücret')),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addBike,
              child: const Text('Bisiklet Ekle'),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: bikes.length,
                itemBuilder: (context, index) {
                  final bike = bikes[index];
                  bool available = bike['is_available'];

                  return ListTile(
                    title: Text('${bike['brand']} - ${bike['model']}'),
                    subtitle: Text('Ücret: ${bike['hourly_rate']} TL - ${available ? "Müsait" : "Kirada"}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteBike(bike['id']),
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