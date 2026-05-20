import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
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
      _showSnackBar('Bisikletler yüklenirken hata oluştu: ${error.toString()}');
    }
  }

  void _toggleRentBike(int id, bool currentStatus) async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client
          .from('bikes')
          .update({'is_available': !currentStatus})
          .eq('id', id);
      
      _fetchBikes();
      _showSnackBar(currentStatus ? 'Bisiklet başarıyla kiralandı!' : 'Bisiklet başarıyla teslim edildi.');
    } catch (error) {
      _showSnackBar('İşlem başarısız: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bisiklet Kiralama', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent, // Müşteri teması rengi
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kiralanabilir Uygun Bisikletler',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _bikes.isEmpty
                  ? const Center(child: Text('Sistemde henüz bisiklet bulunmuyor.'))
                  : ListView.builder(
                      itemCount: _bikes.length,
                      itemBuilder: (context, index) {
                        final bike = _bikes[index];
                        final bool isAvailable = bike['is_available'];

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: isAvailable ? Colors.green : Colors.red,
                                child: Icon(
                                  Icons.directions_bike,
                                  color: isAvailable ? Colors.green : Colors.red,
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                '${bike['brand']} - ${bike['model']}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Saatlik: ${bike['hourly_rate']} TL',
                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                                ),
                              ),
                              trailing: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : ElevatedButton(
                                      onPressed: () => _toggleRentBike(bike['id'], isAvailable),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isAvailable ? Colors.green : Colors.orange,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: Text(
                                        isAvailable ? 'Kirala' : 'Teslim Et',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
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