import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/catalog_service.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final CatalogService _catalogService = CatalogService();
  late Future<List<dynamic>> _catalogFuture;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  // Méthode pour charger ou recharger le catalogue
  void _loadCatalog() {
    setState(() {
      _catalogFuture = _catalogService.fetchCatalog();
    });
  }

  Future<void> _launchURL(String? urlString) async {
    if (urlString != null && urlString.isNotEmpty) {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Catalogue'),
        actions: [
          // Bouton de rafraîchissement dans l'AppBar
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser le catalogue',
            onPressed: _loadCatalog, // Relance la récupération des données
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _catalogFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erreur : ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadCatalog,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun élément disponible.'));
          }

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: const Icon(Icons.flight_takeoff, color: Colors.blue),
                title: Text(item['title'] ?? 'Sans titre'),
                subtitle: Text(item['description'] ?? ''),
                trailing: Text(item['version'] != null ? 'v${item['version']}' : ''),
                onTap: () {
                  _launchURL(item['url']);
                },
              );
            },
          );
        },
      ),
    );
  }
}