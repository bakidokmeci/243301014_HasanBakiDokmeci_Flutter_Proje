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

  void _fetchBikes() async {
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
        title: const Text('Yönetici Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (!mounted) return;
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
            TextField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Marka'),
            ),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(labelText: 'Model'),
            ),
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
                    child: const Text('Yeni Bisiklet Ekle'),
                  ),
            const Divider(height: 32),
            const Text(
              'Mevcut Bisikletler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _bikes.isEmpty
                  ? const Center(child: Text('Henüz bisiklet eklenmemiş.'))
                  : ListView.builder(
                      itemCount: _bikes.length,
                      itemBuilder: (context, index) {
                        final bike = _bikes[index];
                        return Card(
                          child: ListTile(
                            title: Text('${bike['brand']} - ${bike['model']}'),
                            subtitle: Text('Saatlik: ${bike['hourly_rate']} TL'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteBike(bike['id']),
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