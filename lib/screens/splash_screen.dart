import 'package:flutter/material.dart';
import '../data/local_dictionary.dart';
import '../utils/constants.dart';
import '../utils/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Chargement du dictionnaire...';

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await LocalDictionary.ensureLoaded();
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Erreur : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.menu_book, size: 72, color: cs.primary),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(AppConstants.appName,
                style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Français ↔ Lingala',
                style: TextStyle(color: cs.onPrimary.withOpacity(0.85))),
            const SizedBox(height: 36),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: cs.onPrimary),
            ),
            const SizedBox(height: 16),
            Text(_status,
                style: TextStyle(color: cs.onPrimary.withOpacity(0.85))),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text('© ${AppConstants.designer}',
                  style: TextStyle(
                      color: cs.onPrimary.withOpacity(0.7), fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
