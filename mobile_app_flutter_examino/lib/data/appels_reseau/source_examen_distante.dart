import 'package:dio/dio.dart';
import '../../configuration/connexion_api/client_reseau.dart';
import '../models/modele_examen.dart';

class SourceExamenDistante {
  final Dio _dio;

  SourceExamenDistante({required String token})
      : _dio = DioClient(token: token).dio;

  Future<Map<String, List<ModeleExamen>>> getExamensDashboard({String? recherche}) async {
    final res = await _dio.get(
      'examens-dashboard',
      queryParameters: recherche != null && recherche.isNotEmpty
          ? {'recherche': recherche}
          : null,
    );

    return {
      'recents': (res.data['recents'] as List)
          .map((e) => ModeleExamen.fromJson(e))
          .toList(),
      'avenir': (res.data['avenir'] as List)
          .map((e) => ModeleExamen.fromJson(e))
          .toList(),
    };
  }

  Future<List<ModeleExamen>> getListByEndpoint(String endpoint) async {
    final res = await _dio.get(endpoint);

    return (res.data as List)
        .map((e) => ModeleExamen.fromJson(e))
        .toList();
  }

    Future<Map<String, dynamic>> getCorrection(int id) async {
    try {
      final res = await _dio.get('correction/$id');
      return res.data; // Retourne le JSON complet (titre, questions, etc.)
    } catch (e) {
      print("Erreur API Correction: $e");
      if (e is DioException) {
        print("Détails serveur: ${e.response?.data}");
      }
      throw Exception('Erreur lors du chargement de la correction');
    }
  }

  Future<bool> envoyerReclamation(int idExamen, String message) async {
  try {
    final response = await _dio.post('reclamations', data: {
      'id_examen': idExamen,
      'message': message,
    });
    return response.statusCode == 200;
  } catch (e) { return false; }
}
}