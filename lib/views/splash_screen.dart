import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/stardew_theme.dart';
import 'home_screen.dart';

/// Pantalla de Splash Animada para la carga inicial de la aplicación.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Esperar a que la animación y la carga inicial de datos concluyan
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context, listen: false);
    final appVersion = provider.appVersion;

    return Scaffold(
      backgroundColor: StardewColors.background,
      body: Stack(
        children: [
          // Fondo con resplandor central
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    StardewColors.primaryGold.withAlpha(40),
                    StardewColors.iridiumPurple.withAlpha(20),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Contenido principal animado
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo de la App
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: StardewColors.cardBackground,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: StardewColors.primaryGold.withAlpha(80),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(color: StardewColors.primaryGold, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.star_half,
                            color: StardewColors.primaryGold,
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Título de la App
                    const Text(
                      'Stardew Companion',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: StardewColors.primaryGold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtítulo
                    const Text(
                      'Tu asistente de granja & perfección',
                      style: TextStyle(
                        fontSize: 13,
                        color: StardewColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Indicador de Carga Estilo Stardew
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(StardewColors.primaryGold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Versión en el pie de página
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'v$appVersion',
                style: const TextStyle(
                  color: StardewColors.iridiumPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
