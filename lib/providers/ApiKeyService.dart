import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyService {
  static const String _key = 'apiKey';
  
  static Future<String> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? '';
  }

  static Future<void> saveApiKey(String newKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, newKey);
  }
}