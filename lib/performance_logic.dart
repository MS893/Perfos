/// État du calcul de performance.
enum CalculationStatus {
  exact,        // Valeur trouvée directement dans les tables
  interpolated, // Valeur calculée par interpolation entre deux points
  extrapolated, // Valeur calculée en dehors des limites des tables (donnée indicative)
  noData        // Aucune donnée disponible pour ce calcul
}

/// Représente un couple (roulement au sol, distance de passage des 50ft/15m).
class PerformanceEntry {
  final double roll;     // Distance de roulement au sol
  final double distance; // Distance totale pour franchir un obstacle de 50ft
  PerformanceEntry(this.roll, this.distance);

  Map<String, dynamic> toJson() => {'roll': roll, 'distance': distance};
  factory PerformanceEntry.fromJson(Map<String, dynamic> json) =>
      PerformanceEntry(json['roll'].toDouble(), json['distance'].toDouble());
}

/// Résultat d'un calcul incluant les valeurs de performance et la fiabilité du calcul.
class PerformanceResult {
  final PerformanceEntry entry;
  final CalculationStatus status;
  PerformanceResult(this.entry, this.status);
}

/// Classe de base abstraite définissant le comportement commun à tous les types d'avions.
abstract class Aircraft {
  /// Nom de l'avion.
  final String name;

  /// Performances à l'atterrissage.
  final AircraftPerformance landing;

  Aircraft({required this.name, required this.landing});

  /// Calcule les performances au décollage en fonction des conditions.
  PerformanceResult getTakeoffPerformance(double altitude, double temp, double mass, String runwayType);

  /// Calcule le facteur de correction pour le vent au décollage.
  double calculateWindFactorTakeoff(double wind);

  /// Calcule le facteur de correction pour le vent à l'atterrissage.
  double calculateWindFactorLanding(double wind);

  /// Détermine si le vent saisi est dans les limites des tables ou s'il s'agit d'une extrapolation.
  CalculationStatus getWindStatus(double wind) {
    return (wind >= 0 && wind <= 30) ? CalculationStatus.exact : CalculationStatus.extrapolated;
  }

  Map<String, dynamic> toJson();

  factory Aircraft.fromJson(Map<String, dynamic> json) {
    String type = json['type'] ?? 'coeff';
    if (type == 'multi') {
      return AircraftWithMultiTables.fromJson(json);
    }
    return AircraftWithCoeff.fromJson(json);
  }
}

class AircraftWithCoeff extends Aircraft {
  final AircraftPerformance takeoffTable;
  final double grassFactor;

  AircraftWithCoeff({
    required super.name,
    required this.takeoffTable,
    required super.landing,
    this.grassFactor = 1.15,
  });

  @override
  PerformanceResult getTakeoffPerformance(double altitude, double temp, double mass, String runwayType) {
    PerformanceResult res = takeoffTable.calculate(altitude, temp, mass);
    if (res.status == CalculationStatus.noData) return res;
    if (runwayType == 'Herbe') {
      return PerformanceResult(
        PerformanceEntry(res.entry.roll * grassFactor, res.entry.distance * grassFactor),
        res.status,
      );
    }
    return res;
  }

  @override
  double calculateWindFactorTakeoff(double wind) {
    if (wind >= 0) {
      if (wind <= 10) return landing.interpolate(wind, 0, 1.0, 10, 0.85);
      if (wind <= 20) return landing.interpolate(wind, 10, 0.85, 20, 0.65);
      return landing.interpolate(wind, 20, 0.65, 30, 0.55);
    }
    return 1.0 + (wind.abs() / 2.0) * 0.10;
  }

  @override
  double calculateWindFactorLanding(double wind) {
    if (wind >= 0) {
      if (wind <= 10) return landing.interpolate(wind, 0, 1.0, 10, 0.78);
      if (wind <= 20) return landing.interpolate(wind, 10, 0.78, 20, 0.63);
      return landing.interpolate(wind, 20, 0.63, 30, 0.52);
    }
    return 1.0 + (wind.abs() / 2.0) * 0.10;
  }

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': 'coeff',
    'grassFactor': grassFactor,
    'takeoffTable': takeoffTable.toJson(),
    'landing': landing.toJson(),
  };

  factory AircraftWithCoeff.fromJson(Map<String, dynamic> json) => AircraftWithCoeff(
    name: json['name'],
    takeoffTable: AircraftPerformance.fromJson(json['takeoffTable']),
    landing: AircraftPerformance.fromJson(json['landing']),
    grassFactor: json['grassFactor']?.toDouble() ?? 1.15,
  );
}

class AircraftWithMultiTables extends Aircraft {
  final AircraftPerformance takeoffDur;
  final AircraftPerformance takeoffHerbe;

  AircraftWithMultiTables({
    required super.name,
    required this.takeoffDur,
    required this.takeoffHerbe,
    required super.landing,
  });

  @override
  PerformanceResult getTakeoffPerformance(double altitude, double temp, double mass, String runwayType) {
    if (runwayType == 'Herbe') {
      return takeoffHerbe.calculate(altitude, temp, mass);
    }
    return takeoffDur.calculate(altitude, temp, mass);
  }

  @override
  double calculateWindFactorTakeoff(double wind) {
    if (wind >= 0) {
      if (wind <= 10) return landing.interpolate(wind, 0, 1.0, 10, 0.78);
      if (wind <= 20) return landing.interpolate(wind, 10, 0.78, 20, 0.63);
      return landing.interpolate(wind, 20, 0.63, 30, 0.52);
    }
    return 1.0 + (wind.abs() / 2.0) * 0.10;
  }

  @override
  double calculateWindFactorLanding(double wind) {
    if (wind >= 0) {
      if (wind <= 10) return landing.interpolate(wind, 0, 1.0, 10, 0.78);
      if (wind <= 20) return landing.interpolate(wind, 10, 0.78, 20, 0.63);
      return landing.interpolate(wind, 20, 0.63, 30, 0.52);
    }
    return 1.0 + (wind.abs() / 2.0) * 0.10;
  }

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': 'multi',
    'takeoffDur': takeoffDur.toJson(),
    'takeoffHerbe': takeoffHerbe.toJson(),
    'landing': landing.toJson(),
  };

  factory AircraftWithMultiTables.fromJson(Map<String, dynamic> json) => AircraftWithMultiTables(
    name: json['name'],
    takeoffDur: AircraftPerformance.fromJson(json['takeoffDur']),
    takeoffHerbe: AircraftPerformance.fromJson(json['takeoffHerbe']),
    landing: AircraftPerformance.fromJson(json['landing']),
  );
}

/// Modèle de calcul pour les performances d'un avion.
/// Permet l'interpolation et l'extrapolation à partir d'une structure de données tridimensionnelle (Altitude, Température ISA, Masse).
class AircraftPerformance {
  /// Données brutes organisées par : Altitude -> Delta ISA -> Masse -> Performance.
  final Map<double, Map<double, Map<double, PerformanceEntry>>> data;
  AircraftPerformance(this.data);

  /// Indique si la table de performance est vide.
  bool get isEmpty => data.isEmpty;

  /// Effectue une interpolation linéaire entre deux points.
  double interpolate(double x, double x0, double y0, double x1, double y1) {
    if (x1 == x0) return y0;
    return y0 + (x - x0) * (y1 - y0) / (x1 - x0);
  }

  MapEntry<List<double>, CalculationStatus> _getBoundsAndStatus(List<double> sortedValues, double target) {
    if (sortedValues.isEmpty) return const MapEntry([0, 0], CalculationStatus.noData);
    if (sortedValues.contains(target)) return MapEntry([target, target], CalculationStatus.exact);
    if (target < sortedValues.first || target > sortedValues.last) {
      if (sortedValues.length < 2) return MapEntry([sortedValues[0], sortedValues[0]], CalculationStatus.extrapolated);
      return target < sortedValues.first
          ? MapEntry([sortedValues[0], sortedValues[1]], CalculationStatus.extrapolated)
          : MapEntry([sortedValues[sortedValues.length - 2], sortedValues[sortedValues.length - 1]], CalculationStatus.extrapolated);
    }
    int idx = sortedValues.indexWhere((v) => v >= target);
    return MapEntry([sortedValues[idx - 1], sortedValues[idx]], CalculationStatus.interpolated);
  }

  /// Calcule les performances (roulement et distance) pour des conditions données.
  /// Gère les interpolations successives sur les 3 axes.
  PerformanceResult calculate(double altitude, double temp, double mass) {
    if (isEmpty) return PerformanceResult(PerformanceEntry(0, 0), CalculationStatus.noData);
    double isaTemp = 15 - (2 * altitude / 1000);
    double deltaISA = temp - isaTemp;
    List<double> alts = data.keys.toList()..sort();
    var aRes = _getBoundsAndStatus(alts, altitude);
    var lowAltRes = _interpolateTemp(aRes.key[0], deltaISA, mass);
    var highAltRes = _interpolateTemp(aRes.key[1], deltaISA, mass);
    return PerformanceResult(
      PerformanceEntry(
        interpolate(altitude, aRes.key[0], lowAltRes.entry.roll, aRes.key[1], highAltRes.entry.roll),
        interpolate(altitude, aRes.key[0], lowAltRes.entry.distance, aRes.key[1], highAltRes.entry.distance),
      ),
      _getWorstStatus([aRes.value, lowAltRes.status, highAltRes.status]),
    );
  }

  PerformanceResult _interpolateTemp(double alt, double deltaISA, double mass) {
    var tempMap = data[alt];
    if (tempMap == null) return PerformanceResult(PerformanceEntry(0, 0), CalculationStatus.noData);
    List<double> deltas = tempMap.keys.toList()..sort();
    var dRes = _getBoundsAndStatus(deltas, deltaISA);
    var lowTempRes = _interpolateMass(alt, dRes.key[0], mass);
    var highTempRes = _interpolateMass(alt, dRes.key[1], mass);
    return PerformanceResult(
      PerformanceEntry(
        interpolate(deltaISA, dRes.key[0], lowTempRes.entry.roll, dRes.key[1], highTempRes.entry.roll),
        interpolate(deltaISA, dRes.key[0], lowTempRes.entry.distance, dRes.key[1], highTempRes.entry.distance),
      ),
      _getWorstStatus([dRes.value, lowTempRes.status, highTempRes.status]),
    );
  }

  PerformanceResult _interpolateMass(double alt, double deltaISA, double mass) {
    var massMap = data[alt]?[deltaISA];
    if (massMap == null) return PerformanceResult(PerformanceEntry(0, 0), CalculationStatus.noData);
    List<double> masses = massMap.keys.toList()..sort();
    var mRes = _getBoundsAndStatus(masses, mass);
    return PerformanceResult(
      PerformanceEntry(
        interpolate(mass, mRes.key[0], massMap[mRes.key[0]]!.roll, mRes.key[1], massMap[mRes.key[1]]!.roll),
        interpolate(mass, mRes.key[0], massMap[mRes.key[0]]!.distance, mRes.key[1], massMap[mRes.key[1]]!.distance),
      ),
      mRes.value,
    );
  }

  CalculationStatus _getWorstStatus(List<CalculationStatus> statuses) {
    if (statuses.contains(CalculationStatus.noData)) return CalculationStatus.noData;
    if (statuses.contains(CalculationStatus.extrapolated)) return CalculationStatus.extrapolated;
    if (statuses.contains(CalculationStatus.interpolated)) return CalculationStatus.interpolated;
    return CalculationStatus.exact;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    data.forEach((alt, tempMap) {
      Map<String, dynamic> temps = {};
      tempMap.forEach((temp, massMap) {
        Map<String, dynamic> masses = {};
        massMap.forEach((mass, entry) {
          masses[mass.toString()] = entry.toJson();
        });
        temps[temp.toString()] = masses;
      });
      json[alt.toString()] = temps;
    });
    return json;
  }

  factory AircraftPerformance.fromJson(Map<String, dynamic> json) {
    Map<double, Map<double, Map<double, PerformanceEntry>>> data = {};
    json.forEach((altStr, tempJson) {
      double alt = double.parse(altStr);
      Map<double, Map<double, PerformanceEntry>> temps = {};
      (tempJson as Map<String, dynamic>).forEach((tempStr, massJson) {
        double temp = double.parse(tempStr);
        Map<double, PerformanceEntry> masses = {};
        (massJson as Map<String, dynamic>).forEach((massStr, entryJson) {
          double mass = double.parse(massStr);
          masses[mass] = PerformanceEntry.fromJson(entryJson);
        });
        temps[temp] = masses;
      });
      data[alt] = temps;
    });
    return AircraftPerformance(data);
  }
}
