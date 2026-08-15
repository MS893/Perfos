import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfos/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialisation SQLite pour les tests
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('Vérification du chargement de l\'application', (WidgetTester tester) async {
    // 1. Démarrer l'application
    await tester.pumpWidget(const PerfosApp());

    // 2. Laisser les opérations asynchrones (SQLite) s'exécuter
    // runAsync est nécessaire pour que les vrais appels I/O (comme sqflite_ffi) fonctionnent dans le test
    await tester.runAsync(() async {
      int attempts = 0;
      while (attempts < 20) {
        await Future.delayed(const Duration(milliseconds: 200));
        await tester.pump();
        
        // Si le loader a disparu, on a fini
        if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
          break;
        }
        attempts++;
      }
    });

    // 3. Dernier pump pour rafraîchir l'UI après le chargement
    await tester.pump();

    // 4. Vérification finale
    final titleFinder = find.byWidgetPredicate((widget) {
      if (widget is Text && widget.data != null) {
        return widget.data!.contains('Calcul des Performances') || 
               widget.data!.contains('Perfos :');
      }
      return false;
    });

    if (titleFinder.evaluate().isEmpty) {
      print("Diagnostic : Le titre n'est pas trouvé. Contenu actuel de l'écran :");
      debugDumpApp();
    }

    expect(titleFinder, findsOneWidget);
  });
}
