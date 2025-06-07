import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'routes/app_routes.dart';
import 'screens/core/content_list_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const StudyBuddyApp());
}

class StudyBuddyApp extends StatelessWidget {
  const StudyBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Study Buddy',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            if (appRoutes.containsKey(settings.name)) {
              return MaterialPageRoute(builder: appRoutes[settings.name]!);
            }
            if (settings.name != null &&
                settings.name!.startsWith('/content/')) {
              final arguments = settings.arguments as Map<String, dynamic>?;
              if (arguments != null &&
                  arguments.containsKey('subject') &&
                  arguments.containsKey('featureType') &&
                  arguments.containsKey('year')) {
                final String subject = arguments['subject'] as String;
                final String featureType = arguments['featureType'] as String;
                final String year = arguments['year'] as String;
                return MaterialPageRoute(
                  builder: (context) => ContentListScreen(
                    subject: subject,
                    featureType: featureType,
                    year: year,
                  ),
                  settings: settings,
                );
              } else {
                return MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text("Navigation Error")),
                    body: Center(
                      child: Text(
                        "Could not load content: Missing arguments for route \\${settings.name}",
                      ),
                    ),
                  ),
                );
              }
            }
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text("Page Not Found")),
                body: Center(
                  child: Text("No route defined for \\${settings.name}"),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
