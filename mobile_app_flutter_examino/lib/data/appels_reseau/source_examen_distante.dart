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
}