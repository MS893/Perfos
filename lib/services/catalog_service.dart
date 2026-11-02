import 'dart:convert';
import 'package:http/http.dart' as http;

class CatalogService {
  Future<List<dynamic>> fetchCatalog() async {
    // Ajout d'un timestamp pour éviter le cache
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = 'https://api.github.com/repos/ms893/MesApplications/contents/assets/perfos?t=$timestamp';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/vnd.github.v3+json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // On transforme la liste des fichiers GitHub en objets exploitables par votre interface
      return data
          .where((item) => item['type'] == 'file' && item['name'].toString().endsWith('.json'))
          .map((item) {
        String fileName = item['name'].toString();
        String displayName = fileName.replaceAll('.json', '').replaceAll('_', ' ').toUpperCase();
        return {
          'title': displayName,
          'description': 'Fichier de configuration avion',
          'version': '1.0',
          'url': item['download_url'], // Lien brut pour récupérer le JSON de l'avion
        };
      })
          .toList();
    } else {
      throw Exception('Impossible de charger le catalogue (Code : ${response.statusCode})');
    }
  }
}
