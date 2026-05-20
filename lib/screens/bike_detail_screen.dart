import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/log_service.dart';

class BikeDetailScreen extends StatefulWidget {
  final dynamic bike;
  const BikeDetailScreen({super.key, required this.bike});

  @override
  State<BikeDetailScreen> createState() => _BikeDetailScreenState();
}

class _BikeDetailScreenState extends State<BikeDetailScreen> {
  late bool isAvailable;

  @override
  void initState() {
    super.initState();
    isAvailable = widget.bike['is_available'] ?? true;
  }

  void toggleRent() async {
    try {
      await Supabase.instance.client
          .from('bikes')
          .update({'is_available': !isAvailable})
          .eq('id', widget.bike['id']);
      
      String islem = !isAvailable ? "Teslim Edildi" : "Kiralandi";
      await LogService.logAction('${widget.bike['brand']} ${widget.bike['model']} bisikleti $islem.');

      setState(() {
        isAvailable = !isAvailable;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Islem basariyla gerceklestirildi: $islem')),
      );
    } catch (e) {
      print('Kiralama hatasi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.bike['brand']} Detayi')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Icon(Icons.directions_bike, size: 120, color: Colors.blueAccent)),
            const SizedBox(height: 30),
            Text('Marka: ${widget.bike['brand']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Model: ${widget.bike['model']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Saatlik Ucret: ${widget.bike['hourly_rate']} TL', style: const TextStyle(fontSize: 18, color: Colors.green)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Durum: ', style: TextStyle(fontSize: 18)),
                Text(
                  isAvailable ? 'Musait' : 'Kirada',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isAvailable ? Colors.green : Colors.orange),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAvailable ? Colors.green : Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: toggleRent,
                child: Text(isAvailable ? 'Bisikleti Kirala' : 'Bisikleti Teslim Et'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}