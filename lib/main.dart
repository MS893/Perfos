import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'performance_logic.dart';
import 'storage_service.dart';

/// Point d'entrée principal de l'application Flutter.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PerfosApp());
}

/// Point d'entrée de l'application.
class PerfosApp extends StatefulWidget {
  const PerfosApp({super.key});

  @override
  State<PerfosApp> createState() => PerfosAppState();

  /// Récupère l'état de l'application depuis le contexte.
  static PerfosAppState of(BuildContext context) =>
      context.findAncestorStateOfType<PerfosAppState>()!;
}

class PerfosAppState extends State<PerfosApp> {
  /// Mode de thème actuel de l'application.
  ThemeMode _themeMode = ThemeMode.light;

  /// Service de stockage pour la persistence des données.
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  /// Charge le mode de thème sauvegardé depuis le stockage.
  Future<void> _loadTheme() async {
    final mode = await _storage.getThemeMode();
    setState(() {
      _themeMode = mode == 'dark' ? ThemeMode.dark : ThemeMode.light;
    });
  }

  /// Met à jour le mode de thème et le sauvegarde.
  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    _storage.setThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perfos Décollage & Atterrissage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: const PerformanceCalculator(),
    );
  }
}

/// Écran principal contenant le formulaire de saisie et les résultats de l'avion sélectionné.
class PerformanceCalculator extends StatefulWidget {
  const PerformanceCalculator({super.key});

  @override
  State<PerformanceCalculator> createState() => _PerformanceCalculatorState();
}

/// Gestion du formulaire de saisie et des résultats de performance.
class _PerformanceCalculatorState extends State<PerformanceCalculator> {
  /// Service de stockage pour les avions et les paramètres.
  final StorageService _storage = StorageService();
  
  /// Contrôleurs pour les champs de saisie numérique.
  final TextEditingController _altitudeController = TextEditingController(text: '0');
  final TextEditingController _tempController = TextEditingController(text: '15');
  final TextEditingController _massController = TextEditingController(text: '900');
  final TextEditingController _windController = TextEditingController(text: '0');
  
  /// État des sélections du formulaire.
  String _runwayType = 'Dur';
  String _surfaceState = 'Sèche';
  String _pilotLevel = 'Expérimenté';
  bool _isLargeText = false;

  /// Liste des avions disponibles localement.
  List<Aircraft> _availableAircrafts = [];

  /// L'avion actuellement sélectionné pour le calcul.
  Aircraft? _selectedAircraft;

  /// Indique si les données sont en cours de chargement.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _altitudeController.addListener(() => setState(() {}));
    _tempController.addListener(() => setState(() {}));
    _massController.addListener(() => setState(() {}));
    _windController.addListener(() => setState(() {}));
  }

  /// Charge les avions et les paramètres utilisateur depuis le stockage local.
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final aircrafts = await _storage.getAircrafts();
    final selectedName = await _storage.getSelectedAircraft();
    final pilotLevel = await _storage.getPilotLevel();
    
    setState(() {
      _availableAircrafts = aircrafts;
      _pilotLevel = pilotLevel;
      if (aircrafts.isNotEmpty) {
        if (selectedName != null) {
          _selectedAircraft = aircrafts.firstWhere(
            (a) => a.name == selectedName,
            orElse: () => aircrafts.first,
          );
        } else {
          _selectedAircraft = aircrafts.first;
        }
      } else {
        _selectedAircraft = null;
      }
      _isLoading = false;
    });
  }

  /// Ouvre une URL dans un navigateur externe.
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  /// Affiche la boîte de dialogue "À propos" de l'application.
  void _showAboutDialog() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String version = packageInfo.version;
    String description =
        "Application de calcul de performances de décollage et d'atterrissage.";
    String support = "Support";
    String supportUrl =
        "https://ms893.github.io/MesApplications/pages/suggestions.html";

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos'),
        content: RichText(
          text: TextSpan(
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
            children: [
              TextSpan(text: "$appName v$version\n\n"),
              TextSpan(text: "$description\n"),
              const TextSpan(text: "© 2026 SkyDev\n\n"),
              TextSpan(text: "$support : "),
              TextSpan(
                text: supportUrl,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _launchURL(supportUrl),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Télécharge les données d'un avion depuis le catalogue en ligne.
  Future<void> _downloadAircraft(String fileName) async {
    final url = 'https://ms893.github.io/MesApplications/assets/perfos/$fileName';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aircraft = Aircraft.fromJson(data);
        await _storage.saveAircraft(aircraft);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Avion ${aircraft.name} ajouté !')));
        }
      } else {
        throw Exception('Erreur de téléchargement (${response.statusCode})');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  /// Formate le nom du fichier JSON en un nom d'avion lisible.
  String _formatAircraftName(String fileName) {
    return fileName.replaceAll('.json', '').replaceAll('_', ' ').toUpperCase();
  }

  /// Récupère la liste des fichiers d'avions disponibles sur le dépôt GitHub.
  Future<List<String>> _getOnlineCatalog() async {
    try {
      final response = await http.get(Uri.parse('https://api.github.com/repos/ms893/MesApplications/contents/assets/perfos'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .where((item) => item['type'] == 'file' && item['name'].toString().endsWith('.json'))
            .map((item) => item['name'].toString())
            .toList();
      }
    } catch (e) {
      debugPrint('Erreur lors de la lecture du catalogue en ligne : $e');
    }
    return [];
  }

  /// Affiche le dialogue permettant de choisir et télécharger un nouvel avion.
  void _showDownloadDialog(void Function() onDownloaded) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<String>>(
        future: _getOnlineCatalog(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Lecture du catalogue...'),
                ],
              ),
            );
          }

          final catalog = snapshot.data ?? [];

          return AlertDialog(
            title: const Text('Télécharger un avion'),
            content: SizedBox(
              width: double.maxFinite,
              child: catalog.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Aucun avion trouvé ou erreur de connexion.', textAlign: TextAlign.center),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: catalog.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final fileName = catalog[index];
                        final displayName = _formatAircraftName(fileName);
                        return ListTile(
                          title: Text(displayName),
                          trailing: const Icon(Icons.download),
                          onTap: () async {
                            Navigator.pop(context);
                            await _downloadAircraft(fileName);
                            onDownloaded();
                          },
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
            ],
          );
        },
      ),
    );
  }

  /// Affiche le dialogue des paramètres (sélection avion, niveau pilote, thème).
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Paramètres'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sélectionner un avion :', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedAircraft?.name,
                          isExpanded: true,
                          items: _availableAircrafts.map((a) => DropdownMenuItem<String>(
                            value: a.name,
                            child: Text(a.name),
                          )).toList(),
                          onChanged: (val) async {
                            if (val == null) return;
                            await _storage.setSelectedAircraft(val);
                            setDialogState(() {
                              _selectedAircraft = _availableAircrafts.firstWhere((ac) => ac.name == val);
                            });
                            setState(() {}); // Update main screen
                          },
                        ),
                      ),
                    ),
                  ),
                  if (_selectedAircraft != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Supprimer cet avion',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Supprimer l\'avion ?'),
                            content: Text('Voulez-vous vraiment supprimer l\'avion "${_selectedAircraft!.name}" de la mémoire locale ?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await _storage.deleteAircraft(_selectedAircraft!.name);
                          await _loadData(); // Recharger la liste depuis le storage
                          setDialogState(() {}); // Rafraîchir le dialog
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Niveau du pilote :', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _pilotLevel,
                    isExpanded: true,
                    items: ['Expérimenté (+20%)', 'Débutant (+40%)'].map((v) => DropdownMenuItem(
                      value: v.contains('Exp') ? 'Expérimenté' : 'Débutant',
                      child: Text(v),
                    )).toList(),
                    onChanged: (val) async {
                      if (val == null) return;
                      await _storage.setPilotLevel(val);
                      setDialogState(() => _pilotLevel = val);
                      setState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Thème :', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ThemeMode>(
                    value: PerfosApp.of(context)._themeMode,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Clair')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Sombre')),
                    ],
                    onChanged: (mode) {
                      if (mode == null) return;
                      PerfosApp.of(context).setThemeMode(mode);
                      setDialogState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showDownloadDialog(() => setDialogState(() {})),
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Télécharger de nouveaux avions'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    double? altitude = double.tryParse(_altitudeController.text);
    double? temp = double.tryParse(_tempController.text);
    double? mass = double.tryParse(_massController.text);
    double? wind = double.tryParse(_windController.text);

    String deltaISAText = "--";
    if (altitude != null && temp != null) {
      double isaTemp = 15 - (2 * altitude / 1000);
      double deltaISA = temp - isaTemp;
      deltaISAText = "ISA ${deltaISA >= 0 ? '+' : ''}${deltaISA.toStringAsFixed(1)}°C";
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedAircraft != null ? 'Perfos : ${_selectedAircraft!.name}' : 'Calcul des Performances'),
        actions: [
          IconButton(
            icon: Icon(_isLargeText ? Icons.text_decrease : Icons.text_increase, size: 32),
            onPressed: () => setState(() => _isLargeText = !_isLargeText),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 32),
            onSelected: (value) {
              switch (value) {
                case 'settings': _showSettingsDialog(); break;
                case 'about': _showAboutDialog(); break;
                case 'mesapplications': _launchURL('https://ms893.github.io/MesApplications/'); break;
                case 'donate': _launchURL('https://ko-fi.com/skydev_13'); break;
                case 'share': SharePlus.instance.share(ShareParams(text: 'Découvrez Perfos !')); break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'settings', child: ListTile(leading: Icon(Icons.settings), title: Text('Paramètres'))),
              const PopupMenuItem(value: 'about', child: ListTile(leading: Icon(Icons.help_outline), title: Text('À propos'))),
              const PopupMenuItem(value: 'mesapplications', child: ListTile(leading: Icon(Icons.apps), title: Text('Mes applications'))),
              const PopupMenuItem(value: 'donate', child: ListTile(leading: Icon(Icons.card_giftcard), title: Text('Faire un don'))),
              const PopupMenuItem(value: 'share', child: ListTile(leading: Icon(Icons.share), title: Text('Partager'))),
            ],
          ),
        ],
      ),
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_isLargeText ? 1.12 : 1.0)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 7,
                color: isDark ? Colors.red.shade900.withValues(alpha: 0.2) : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _altitudeController, decoration: const InputDecoration(labelText: 'Altitude (ft)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                          const SizedBox(width: 10),
                          Expanded(child: TextField(controller: _tempController, decoration: const InputDecoration(labelText: 'Température (°C)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Align(alignment: Alignment.centerRight, child: Text('Atmosphère : $deltaISAText', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontStyle: FontStyle.italic))),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _massController, decoration: const InputDecoration(labelText: 'Masse (kg)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                          const SizedBox(width: 10),
                          Expanded(child: TextField(controller: _windController, decoration: const InputDecoration(labelText: 'Vent Face(+) / Arr(-) (kt)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text('Piste :'),
                          DropdownButton<String>(value: _runwayType, items: ['Dur', 'Herbe'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (val) => setState(() => _runwayType = val!)),
                          const Text('État :'),
                          DropdownButton<String>(value: _surfaceState, items: ['Sèche', 'Mouillée'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (val) => setState(() => _surfaceState = val!)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: _selectedAircraft == null
                ? const Center(child: Text('Aucun avion sélectionné. Allez dans les paramètres.'))
                : PlaneResultView(
                    planeName: _selectedAircraft!.name,
                    aircraft: _selectedAircraft,
                    altitude: altitude,
                    temp: temp,
                    mass: mass,
                    wind: wind,
                    runwayType: _runwayType,
                    surfaceState: _surfaceState,
                    pilotLevel: _pilotLevel,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Affiche les résultats de performance calculés pour un avion spécifique.
class PlaneResultView extends StatelessWidget {
  /// Nom de l'avion.
  final String planeName;

  /// Données de l'avion utilisé pour le calcul.
  final Aircraft? aircraft;

  /// Altitude en pieds.
  final double? altitude;

  /// Température en degrés Celsius.
  final double? temp;

  /// Masse de l'avion en kg.
  final double? mass;

  /// Composante de vent (positif = face, négatif = arrière).
  final double? wind;

  /// Type de piste (Dur / Herbe).
  final String runwayType;

  /// État de la surface (Sèche / Mouillée).
  final String surfaceState;

  /// Niveau d'expérience du pilote.
  final String pilotLevel;

  const PlaneResultView({
    super.key,
    required this.planeName,
    this.aircraft,
    this.altitude,
    this.temp,
    this.mass,
    this.wind,
    required this.runwayType,
    required this.surfaceState,
    required this.pilotLevel,
  });

  @override
  Widget build(BuildContext context) {
    if (aircraft == null || altitude == null || temp == null || mass == null || wind == null) {
      return const Center(child: Text('Données manquantes ou invalides.'));
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    PerformanceResult takeoffRes = aircraft!.getTakeoffPerformance(altitude!, temp!, mass!, runwayType);
    double windFactorTakeoff = aircraft!.calculateWindFactorTakeoff(wind!);
    double toRoll = takeoffRes.entry.roll * windFactorTakeoff;
    double toDist = takeoffRes.entry.distance * windFactorTakeoff;

    PerformanceResult landingRes = aircraft!.landing.calculate(altitude!, temp!, mass!);
    double windFactorLanding = aircraft!.calculateWindFactorLanding(wind!);
    double ldRoll = landingRes.entry.roll * windFactorLanding;
    double ldDist = landingRes.entry.distance * windFactorLanding;

    if (surfaceState == 'Mouillée') {
      toRoll *= 1.10; toDist *= 1.10; ldRoll *= 1.10; ldDist *= 1.10;
    }

    double safetyFactor = pilotLevel == 'Débutant' ? 1.40 : 1.20;
    double toDistSafety = toDist * safetyFactor;
    double ldDistSafety = ldDist * safetyFactor;

    CalculationStatus finalStatus = _getWorstStatus([takeoffRes.status, landingRes.status, aircraft!.getWindStatus(wind!)]);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            if (finalStatus == CalculationStatus.noData) 
              const Padding(padding: EdgeInsets.all(20.0), child: Text('Données non disponibles.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)))
            else ...[
              if (finalStatus != CalculationStatus.exact) _buildStatusWarning(finalStatus) else const SizedBox(height: 16),
              _buildSectionTitle('DÉCOLLAGE (Passage 15m)'),
              _buildResultRow(context, 'Roulement', toRoll, isDark ? Colors.blue.shade900.withValues(alpha: 0.3) : Colors.blue.shade50),
              _buildDualResultRow(context, 'Distance Totale', toDistSafety, toDist, isDark ? Colors.blue.shade800.withValues(alpha: 0.4) : Colors.blue.shade100),
              const SizedBox(height: 12),
              _buildSectionTitle('ATTERRISSAGE (Passage 15m)'),
              _buildResultRow(context, 'Roulement', ldRoll, isDark ? Colors.green.shade900.withValues(alpha: 0.3) : Colors.green.shade50),
              _buildDualResultRow(context, 'Distance Totale', ldDistSafety, ldDist, isDark ? Colors.green.shade800.withValues(alpha: 0.4) : Colors.green.shade100),
              const SizedBox(height: 20),
              _buildInfoCard(context, windFactorTakeoff, windFactorLanding),
            ]
          ],
        ),
      ),
    );
  }

  /// Construit un titre de section stylisé.
  Widget _buildSectionTitle(String title) => Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)));

  /// Détermine le statut de calcul le plus critique parmi une liste de statuts.
  CalculationStatus _getWorstStatus(List<CalculationStatus> statuses) {
    if (statuses.contains(CalculationStatus.noData)) return CalculationStatus.noData;
    if (statuses.contains(CalculationStatus.extrapolated)) return CalculationStatus.extrapolated;
    if (statuses.contains(CalculationStatus.interpolated)) return CalculationStatus.interpolated;
    return CalculationStatus.exact;
  }

  /// Affiche un avertissement si les résultats sont interpolés ou extrapolés.
  Widget _buildStatusWarning(CalculationStatus status) {
    bool isExtrapolated = status == CalculationStatus.extrapolated;
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: isExtrapolated ? Colors.red.shade50.withValues(alpha: 0.1) : Colors.orange.shade50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: isExtrapolated ? Colors.red : Colors.orange)),
      child: Row(
        children: [
          Icon(isExtrapolated ? Icons.warning_amber_rounded : Icons.info_outline, color: isExtrapolated ? Colors.red : Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(isExtrapolated ? 'EXTRAPOLATION : résultats calculés et imprécis.' : 'Note : Valeurs interpolées.', style: TextStyle(color: isExtrapolated ? Colors.red : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }

  /// Construit une ligne affichant un seul résultat (ex: Roulement).
  Widget _buildResultRow(BuildContext context, String label, double value, Color bgColor) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 13)),
      Container(width: 90, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white10)), child: Text('${value.toStringAsFixed(0)} m', style: const TextStyle(fontSize: 16))),
    ]),
  );

  /// Construit une ligne affichant la distance avec sécurité et la distance brute.
  Widget _buildDualResultRow(BuildContext context, String label, double safetyValue, double tableValue, Color tableBgColor) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: Row(children: [
      Expanded(flex: 3, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
      Container(width: 90, padding: const EdgeInsets.symmetric(vertical: 4), decoration: BoxDecoration(color: Colors.orange.shade900.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.orange.shade700.withValues(alpha: 0.5))), child: Center(child: Text('${safetyValue.toStringAsFixed(0)} m*', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange)))),
      const SizedBox(width: 12),
      Container(width: 90, padding: const EdgeInsets.symmetric(vertical: 4), decoration: BoxDecoration(color: tableBgColor, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white10)), child: Center(child: Text('${tableValue.toStringAsFixed(0)} m', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)))),
    ]),
  );

  /// Affiche une carte récapitulative des facteurs de correction appliqués.
  Widget _buildInfoCard(BuildContext context, double wfTO, double wfLD) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? Colors.amber.shade900.withValues(alpha: 0.1) : Colors.amber.shade50,
      child: Padding(padding: const EdgeInsets.all(10.0), child: Column(children: [
        const Text('Notes et Corrections :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '(*) Distance majorée de ${(pilotLevel == 'Débutant' ? 40 : 20)}% (Pilote $pilotLevel)',
          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.deepOrange),
        ),
        const SizedBox(height: 8),
        Text('• Vent TO: x${wfTO.toStringAsFixed(2)} | LD: x${wfLD.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
        if (surfaceState == 'Mouillée') const Text('• Piste Mouillée : +10% (Valeur estimée)', style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontStyle: FontStyle.italic)),
      ])),
    );
  }
}
