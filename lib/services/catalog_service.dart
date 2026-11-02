import 'dart:convert';
import 'package:http/http.dart' as http;

class CatalogService {
  // Remplacez par votre URL GitHub Pages réelle
  static const String jsonUrl = 'https://<votre-username>.github.io/<votre-repo>/index.json';

  Future<List<dynamic>> fetchCatalog() async {
    final response = await http.get(Uri.parse(jsonUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['items'] ?? [];
    } else {
      throw Exception('Impossible de charger le catalogue (Code : ${response.statusCode})');
    }
  }
}
