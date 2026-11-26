import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cancherito/app_theme.dart';
import 'package:cancherito/firebase_options.dart';
import 'package:cancherito/home_shell.dart';
import 'package:cancherito/login_page.dart';
import 'package:cancherito/notification_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Configurado con FlutterFire para Android (proyecto prueba-sqlite-crypto).
  // Si la inicialización falla, AuthGate muestra LoginPage con un aviso.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService().init();
  } catch (_) {
    // Ignorado a propósito: ver AuthGate.
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cancherito',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Paleta.bg,
        colorScheme: const ColorScheme.dark(
          primary: Paleta.primario,
          secondary: Paleta.verde,
          surface: Paleta.card,
        ),
        snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      ),
      home: const AuthGate(),
    );
  }
}

/// Si hay sesión activa entra a la app, si no al login.
/// Si Firebase no inicializó, muestra LoginPage con un aviso.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      Firebase.app();
    } catch (_) {
      return const _LoginSinFirebase();
    }
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Paleta.primario)),
          );
        }
        if (snap.hasData) return const HomeShell();
        return const LoginPage();
      },
    );
  }
}

/// Muestra LoginPage cuando Firebase no está disponible e informa la
/// limitación una sola vez. No simula autenticación.
class _LoginSinFirebase extends StatefulWidget {
  const _LoginSinFirebase();

  @override
  State<_LoginSinFirebase> createState() => _LoginSinFirebaseState();
}

class _LoginSinFirebaseState extends State<_LoginSinFirebase> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Firebase no configurado (falta google-services.json). '
            'El inicio de sesión no funcionará hasta configurarlo.',
          ),
          duration: Duration(seconds: 6),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}