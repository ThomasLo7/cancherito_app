import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cancherito/app_theme.dart';
import 'package:cancherito/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _error(Object e) {
    final String msg;
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'El correo ya está registrado.';
          break;
        case 'weak-password':
          msg = 'La contraseña debe tener al menos 6 caracteres.';
          break;
        case 'invalid-email':
          msg = 'Correo electrónico no válido.';
          break;
        case 'user-not-found':
          msg = 'No existe una cuenta registrada con este correo.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          msg = 'Correo o contraseña incorrectos.';
          break;
        case 'network-request-failed':
          msg = 'Sin conexión. Revisa tu internet e inténtalo de nuevo.';
          break;
        case 'too-many-requests':
          msg = 'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
          break;
        case 'cancelado':
          msg = e.message ?? 'Inicio con Google cancelado.';
          break;
        default:
          msg = e.message ?? e.code;
      }
    } else {
      msg = e.toString();
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  bool _validateInputs() {
    if (_email.text.trim().isEmpty || _pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return false;
    }
    return true;
  }

  /// Al iniciar sesión, AuthGate detecta el cambio y abre la app solo.
  Future<void> _run(Future Function() fn) async {
    setState(() => _loading = true);
    try {
      await fn();
    } catch (e) {
      _error(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Paleta.primario),
      labelStyle: const TextStyle(color: Paleta.apagado),
      filled: true,
      fillColor: Paleta.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Paleta.borde),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Paleta.borde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Paleta.primario, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Paleta.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: Paleta.primario.withAlpha(90)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'img/logo.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Cancherito',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Reserva las canchas locales de tu ciudad',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Paleta.apagado, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration:
                        _fieldDecoration('Correo electrónico', Icons.email_rounded),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pass,
                    obscureText: _obscure,
                    style: const TextStyle(color: Colors.white),
                    decoration:
                        _fieldDecoration('Contraseña', Icons.key_rounded).copyWith(
                      suffixIcon: IconButton(
                        color: Paleta.apagado,
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Paleta.primario,
                      foregroundColor: Paleta.enPrimario,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _loading
                        ? null
                        : () {
                            if (!_validateInputs()) return;
                            _run(() => _auth.signInEmail(_email.text, _pass.text));
                          },
                    child: Text(
                      _loading ? 'Cargando...' : 'Iniciar sesión',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Paleta.primario,
                      side: const BorderSide(color: Paleta.primario),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _loading
                        ? null
                        : () {
                            if (!_validateInputs()) return;
                            _run(() => _auth.registerEmail(_email.text, _pass.text));
                          },
                    child: const Text('Crear cuenta', style: TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Paleta.card2,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 28,
                      color: Colors.redAccent,
                    ),
                    label: const Text(
                      'Continuar con Google',
                      style: TextStyle(fontSize: 15),
                    ),
                    onPressed:
                        _loading ? null : () => _run(() => _auth.signInWithGoogle()),
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