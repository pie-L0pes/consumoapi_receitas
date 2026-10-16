
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LivroReceitasApp());
}

class LivroReceitasApp extends StatelessWidget {
  const LivroReceitasApp({super.key});

  ThemeData criarTema(Brightness brilho) {
    final escuro = brilho == Brightness.dark;

    final cores = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 182, 55, 157),
      brightness: brilho,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brilho,
      colorScheme: cores,
      scaffoldBackgroundColor: escuro
          ? const Color.fromARGB(255, 23, 21, 23)
          : const Color.fromARGB(255, 254, 244, 255),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        color: cores.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cores.primaryContainer,
        foregroundColor: cores.onPrimaryContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Caderno de Receitas',
      theme: criarTema(Brightness.light),
      darkTheme: criarTema(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animacao;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    animacao = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    );

    controller.forward();

    iniciarApp();
  }

  Future<void> iniciarApp() async {
    await Future.delayed(const Duration(milliseconds: 1900));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: controller,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.75,
                end: 1,
              ).animate(animacao),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 92,
                    color: cores.primary,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Caderno de Receitas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sabores que merecem ser guardados',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
