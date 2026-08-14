// C:/Users/CH/StudioProjects/Perfos/lib/storage_service.dart

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'performance_logic.dart';

/// Service gérant le stockage persistant de l'application via SQLite.
/// Permet de sauvegarder les avions téléchargés et les préférences utilisateur.
class StorageService {
  static Database? _database;

  /// Accesseur asynchrone pour la base de données.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Initialise la base de données SQLite et crée les tables si nécessaire.
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'perfos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE aircrafts (
            id TEXT PRIMARY KEY,
            name TEXT,
            data TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
    );
  }

  /// Sauvegarde ou met à jour les données d'un avion en base de données.
  Future<void> saveAircraft(Aircraft aircraft) async {
    final db = await database;
    await db.insert(
      'aircrafts',
      {
        'id': aircraft.name,
        'name': aircraft.name,
        'data': jsonEncode(aircraft.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupère la liste de tous les avions enregistrés localement.
  Future<List<Aircraft>> getAircrafts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('aircrafts');
    
    List<Aircraft> result = [];
    for (var map in maps) {
      result.add(Aircraft.fromJson(jsonDecode(map['data'])));
    }
    
    return result;
  }
  
  /// Enregistre une valeur dans la table des paramètres.
  Future<void> _saveSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Récupère une valeur depuis la table des paramètres.
  Future<String?> _getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isNotEmpty) return maps.first['value'] as String?;
    return null;
  }

  /// Enregistre le nom de l'avion sélectionné par l'utilisateur.
  Future<void> setSelectedAircraft(String name) async {
    await _saveSetting('selected_aircraft', name);
  }
  
  /// Récupère le nom de l'avion sélectionné.
  Future<String?> getSelectedAircraft() async {
    return await _getSetting('selected_aircraft');
  }

  /// Enregistre le niveau d'expérience du pilote.
  Future<void> setPilotLevel(String level) async {
    await _saveSetting('pilot_level', level);
  }

  /// Récupère le niveau d'expérience du pilote (valeur par défaut : 'Expérimenté').
  Future<String> getPilotLevel() async {
    return (await _getSetting('pilot_level')) ?? 'Expérimenté';
  }

  /// Supprime un avion de la base de données locale.
  Future<void> deleteAircraft(String name) async {
    final db = await database;
    await db.delete('aircrafts', where: 'id = ?', whereArgs: [name]);
  }

  /// Enregistre le mode de thème choisi (light/dark).
  Future<void> setThemeMode(String mode) async {
    await _saveSetting('theme_mode', mode);
  }

  /// Récupère le mode de thème enregistré (valeur par défaut : 'light').
  Future<String> getThemeMode() async {
    return (await _getSetting('theme_mode')) ?? 'light';
  }

  /// Enregistre si le texte doit être affiché en grand.
  Future<void> setIsLargeText(bool isLarge) async {
    await _saveSetting('is_large_text', isLarge ? '1' : '0');
  }

  /// Récupère si le texte doit être affiché en grand (valeur par défaut : false).
  Future<bool> getIsLargeText() async {
    return (await _getSetting('is_large_text')) == '1';
  }
}
