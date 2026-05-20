import 'package:supabase_flutter/supabase_flutter.dart';

class LogService {
  static Future<void> logAction(String action) async {
    final user = Supabase.instance.client.auth.currentUser;
    try {
      await Supabase.instance.client.from('logs').insert({
        'user_email': user?.email ?? 'Bilinmeyen Kullanıcı',
        'action': action,
      });
    } catch (e) {
      print('Log hatası: $e');
    }
  }
}