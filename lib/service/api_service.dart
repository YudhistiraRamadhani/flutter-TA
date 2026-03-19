import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiAuth {
  final String authUrl = 'http://10.0.2.2:8000/api/auth/login';

  Future<String?> getToken(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(authUrl),
        headers: {
          "Accept": "application/json", 
          "Content-Type": "application/json"
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Rupadana ApiService biasanya mengembalikan 'token' atau 'access_token'
        // Cek body response di console untuk memastikan key-nya
        return data['token'] ?? data['access_token']; 
      } else {
        print("Login Gagal: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error Login: $e");
      return null;
    }
  }
}