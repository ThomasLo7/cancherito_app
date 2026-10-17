import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cancherito',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // ALMACENAMIENTO PERSISTENTE EN MEMORIA
  // Usamos una lista/mapa estático para que no se borre al reconstruir la pantalla
  static Map<String, String> registeredUsers = {};
  
  bool isLoggedIn = false;

  void register() async {
    final result = await Navigator.pushNamed(context, '/register');
    if (result != null && result is Map<String, String>) {
      setState(() {
        // Guardamos las credenciales en nuestro mapa de usuarios
        registeredUsers[result['email']!] = result['password']!;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Registro exitoso! Ya puedes iniciar sesión.')),
      );
    }
  }

  void login() {
    final enteredEmail = emailController.text.trim();
    final enteredPassword = passwordController.text.trim();

    // Verificamos si el correo existe y la contraseña coincide
    if (registeredUsers.containsKey(enteredEmail) &&
        registeredUsers[enteredEmail] == enteredPassword) {
      setState(() {
        isLoggedIn = true;
      });
    } else if (!registeredUsers.containsKey(enteredEmail)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error de inicio de sesión'),
            content: Text('Este correo no está registrado. Por favor regístrate primero.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error de inicio de sesión'),
            content: Text('Contraseña incorrecta. Verifica tus datos.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

  void logout() {
    setState(() {
      isLoggedIn = false;
      emailController.clear();
      passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return HelloWorldScreen(onLogout: logout);
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Inicio de Sesión o Registro'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'images/cancherito.jpg',
                  width: 300,
                  height: 300,
                ),
                SizedBox(height: 20),
                Container(
                  width: 300,
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  width: 300,
                  child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: 200,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: login,
                    child: Text('Iniciar Sesión'),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 350,
                  height: 45,
                  child: TextButton(
                    onPressed: register,
                    child: Text('¿No tienes una cuenta? Regístrate aquí.'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController registerEmailController = TextEditingController();
    TextEditingController registerPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 300,
                child: TextField(
                  controller: registerEmailController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: 300,
                child: TextField(
                  controller: registerPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final registerEmail = registerEmailController.text;
                  final registerPassword = registerPasswordController.text;
                  if (registerEmail.isNotEmpty && registerPassword.isNotEmpty) {
                    final result = {
                      'email': registerEmail,
                      'password': registerPassword
                    };
                    Navigator.pop(context, result);
                  }
                },
                child: Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelloWorldScreen extends StatelessWidget {
  final VoidCallback onLogout;

  HelloWorldScreen({required this.onLogout});

  Future<void> _abrirUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el enlace: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menú Principal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                padding: EdgeInsets.all(10),
                children: [
                  InkWell(
                    onTap: () => _abrirUrl('https://www.youtube.com'),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('images/yt.png', fit: BoxFit.cover),
                    ),
                  ),
                  InkWell(
                    onTap: () => _abrirUrl('https://www.spotify.com'),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('images/spotify.jpg', fit: BoxFit.cover),
                    ),
                  ),
                  InkWell(
                    onTap: () => _abrirUrl('https://www.instagram.com'),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('images/instagram.png', fit: BoxFit.cover),
                    ),
                  ),
                  InkWell(
                    onTap: () => _abrirUrl('https://www.whatsapp.com'),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('images/whatsapp.jpg', fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: onLogout, // Ejecuta la función de cierre de sesión
                child: Text('Cerrar Sesión'),
              ),
            )
          ],
        ),
      ),
    );
  }
}