import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:parkquest/pages/about_us.dart';
import 'package:parkquest/pages/add_note.dart';
import 'package:parkquest/pages/find_car.dart';
import 'package:parkquest/pages/location_saved.dart';
import 'package:parkquest/pages/login_page.dart';
import 'package:parkquest/pages/main_page.dart';

Future<void> main() async {
  // CHANGE void main() to Future<void> main() async
  // ADD THESE TWO LINES AT THE START
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Configure Dart `logging` package to print to console
  Logger.root.level = Level.ALL; // capture all levels
  Logger.root.onRecord.listen((record) {
    // Use debugPrint to avoid truncation in Flutter logs
    debugPrint(
      '${record.level.name}: ${record.loggerName}: ${record.time}: ${record.message}',
    );
    if (record.error != null) debugPrint('Error: ${record.error}');
    if (record.stackTrace != null) debugPrint('${record.stackTrace}');
  });

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF0EA5E9),
        secondaryHeaderColor: Color(0xFF00B4D8),

        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Color(0xFF0EA5E9),
          indicatorColor: Color(0xFF90E0EF),
        ),
      ),
      home: MainPage(),
      routes: {
        '/main': (context) => MainPage(),
        '/login': (context) => LoginPage(),
        '/about_us': (context) => AboutUs(),
        '/location_saved': (context) => LocationSaved(),
        '/add_note': (context) => AddNote(),
        '/find_car': (context) => FindCar(),
      },
    );
  }
}
