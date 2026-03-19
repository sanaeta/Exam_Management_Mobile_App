import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

 Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'), 
        headers: {'Content-Type': 'application/json'}, 
        body: jsonEncode({'email': email, 'password': password})
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        // 1. On stocke le token
        await prefs.setString('token', data['token']);
        
        // 2. On stocke le nom et prénom (Ajouté pour le dynamisme)
        if (data['user'] != null) {
          await prefs.setString('user_nom', data['user']['nom']);
          await prefs.setString('user_prenom', data['user']['prenom']);
        }
        
        return true;
      }
      return false;
    } catch (e) { return false; }
  }
  Future<bool> register(String nom, String prenom, String email, String password, int filiereId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'), 
        headers: {'Content-Type': 'application/json'}, 
        body: jsonEncode({'nom': nom, 'prenom': prenom, 'email': email, 'password': password, 'filiere_id': filiereId})
      );
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  Future<List<dynamic>> getFilieres() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/filieres'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) { return []; }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Erreur Profil: $e");
    }
    return null;
  }

  // --- METTRE À JOUR LE PROFIL ---
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}