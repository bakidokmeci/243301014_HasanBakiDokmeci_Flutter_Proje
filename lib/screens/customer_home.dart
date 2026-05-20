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
      _showSnackBar(currentStatus ? 'Bisiklet başarıyla kiralandı!' : 'Bisiklet teslim edildi.');
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
        title: const Text('Müşteri Bisiklet Kiralama'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kiralanabilir Bisikletler',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
                          child: ListTile(
                            leading: Icon(
                              Icons.directions_bike,
                              color: isAvailable ? Colors.green : Colors.red,
                              size: 36,
                            ),
                            title: Text(
                              '${bike['brand']} - ${bike['model']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Saatlik Ücret: ${bike['hourly_rate']} TL'),
                            trailing: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : ElevatedButton(
                                    onPressed: () => _toggleRentBike(bike['id'], isAvailable),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isAvailable ? Colors.blue : Colors.grey,
                                    ),
                                    child: Text(
                                      isAvailable ? 'Kirala' : 'Teslim Et',
                                      style: const TextStyle(color: Colors.white),
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