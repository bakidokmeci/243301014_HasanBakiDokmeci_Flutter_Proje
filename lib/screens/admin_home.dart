import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _rateController = TextEditingController();
  List<dynamic> _bikes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBikes();
  }

  Future<void> _fetchBikes() async {
    try {
      final data = await Supabase.instance.client
          .from('bikes')
          .select()
          .order('id', ascending: false);
      if (mounted) {
        setState(() {
          _bikes = data;
        });
      }
    } catch (error) {
      _showSnackBar('Veri çekme hatası: ${error.toString()}');
    }
  }

  void _addBike() async {
    if (_brandController.text.isEmpty || _modelController.text.isEmpty || _rateController.text.isEmpty) {
      _showSnackBar('Lütfen tüm alanları doldurun');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('bikes').insert({
        'brand': _brandController.text.trim(),
        'model': _modelController.text.trim(),
        'hourly_rate': double.parse(_rateController.text.trim()),
      });
      
      _brandController.clear();
      _modelController.clear();
      _rateController.clear();
      _fetchBikes();
      _showSnackBar('Bisiklet başarıyla eklendi');
    } catch (error) {
      _showSnackBar('Ekleme hatası: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteBike(int id) async {
    try {
      await Supabase.instance.client.from('bikes').delete().eq('id', id);
      _fetchBikes();
      _showSnackBar('Bisiklet silindi');
    } catch (error) {
      _showSnackBar('Silme hatası: ${error.toString()}');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yönetici Paneli', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo, // Daha profesyonel bir renk
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchBikes,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (!mounted) return; // Mavi uyarıyı çözen kritik satır
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
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Yeni Bisiklet Ekle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    TextField(controller: _brandController, decoration: const InputDecoration(labelText: 'Marka')),
                    TextField(controller: _modelController, decoration: const InputDecoration(labelText: 'Model')),
                    TextField(
                      controller: _rateController,
                      decoration: const InputDecoration(labelText: 'Saatlik Ücret (TL)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _addBike,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                            child: const Text('Bisikleti Sisteme Kaydet'),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sistemdeki Mevcut Bisikletler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _bikes.isEmpty
                  ? const Center(child: Text('Henüz bisiklet eklenmemiş.'))
                  : RefreshIndicator(
                      onRefresh: _fetchBikes,
                      child: ListView.builder(
                        itemCount: _bikes.length,
                        itemBuilder: (context, index) {
                          final bike = _bikes[index];
                          final bool isAvailable = bike['is_available'] ?? true;

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isAvailable ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                child: Icon(Icons.directions_bike, color: isAvailable ? Colors.green : Colors.red),
                              ),
                              title: Text('${bike['brand']} - ${bike['model']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    Text('${bike['hourly_rate']} TL/Saat', style: const TextStyle(color: Colors.grey)),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isAvailable ? Colors.green : Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isAvailable ? 'Müsait' : 'Kirada',
                                        style: TextStyle(color: isAvailable ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _deleteBike(bike['id']),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}