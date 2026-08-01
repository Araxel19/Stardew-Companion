import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'theme/stardew_theme.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StardewCompanionApp());
}

class StardewCompanionApp extends StatelessWidget {
  const StardewCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppStateProvider(),
      child: Consumer<AppStateProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Stardew Companion',
            debugShowCheckedModeBanner: false,
            theme: StardewTheme.getTheme(provider.themeMode),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
