import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Importa la librería Flutter
void main() {
  runApp(MyApp()); // Llama a la función runApp para iniciar la aplicación Flutter.
}

class MyApp extends StatelessWidget { // Define una clase llamada MyApp que extiende StatelessWidget.
  @override
  Widget build(BuildContext context) { // Define el método build para construir la interfaz de la aplicación.
    return MaterialApp(
      title: 'Cancherito', // Título de la aplicación.
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, // Configura el tema de la aplicación con un color azul.
      ),
      initialRoute: '/', // Ruta inicial de la aplicación.
      routes: {
        '/': (context) => AuthScreen(), // Define una ruta llamada '/' que muestra AuthScreen.
        '/register': (context) => RegisterScreen(), // Define una ruta llamada '/register' que muestra RegisterScreen.
      },
    );
  }
}

class AuthScreen extends StatefulWidget { // Define una clase llamada AuthScreen que extiende StatefulWidget.
  @override
  _AuthScreenState createState() => _AuthScreenState(); // Crea el estado para AuthScreen.
}

class _AuthScreenState extends State<AuthScreen> { // Define el estado de AuthScreen.
  TextEditingController emailController = TextEditingController(); // Controlador para el campo de correo electrónico.
  TextEditingController passwordController = TextEditingController(); // Controlador para el campo de contraseña.
  bool isRegistered = false; // Variable booleana que indica si el usuario está registrado.
  bool isLoggedIn = false; // Variable booleana que indica si el usuario ha iniciado sesión.
  String? registeredEmail; // Almacena el correo electrónico registrado.
  String? registeredPassword; // Almacena la contraseña registrada.

  void register() async { // Función para registrar un usuario.
    final result = await Navigator.pushNamed(context, '/register'); // Abre la pantalla de registro y espera un resultado.
    if (result != null && result is Map<String, String>) { // Comprueba si se recibió un resultado válido.
      setState(() { // Actualiza el estado de la aplicación.
        isRegistered = true;
        registeredEmail = result['email']; // Almacena el correo electrónico registrado.
        registeredPassword = result['password']; // Almacena la contraseña registrada.
      });
    }
  }

  void login() { // Función para iniciar sesión.
    if (isRegistered) { // Comprueba si el usuario está registrado.
      final enteredEmail = emailController.text; // Obtiene el correo electrónico ingresado.
      final enteredPassword = passwordController.text; // Obtiene la contraseña ingresada.

      if (enteredEmail == registeredEmail && enteredPassword == registeredPassword) { // Comprueba las credenciales.
        setState(() { // Actualiza el estado de la aplicación.
          isLoggedIn = true; // Marca al usuario como autenticado.
        });
      } else { // Credenciales incorrectas, muestra un diálogo de error.
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error de inicio de sesión'),
              content: Text('Credenciales incorrectas. Verifica tu correo y contraseña.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cerrar'),
                ),
              ],
            );
          },
        );
      }
    } else { // El usuario no está registrado, muestra un diálogo de error.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error de inicio de sesión'),
            content: Text('Debes registrarte antes de iniciar sesión.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) { // Método para construir la interfaz de AuthScreen.
    if (isLoggedIn) { // Si el usuario ha iniciado sesión, muestra la pantalla HelloWorldScreen.
      return HelloWorldScreen();
    } else { // Si no ha iniciado sesión, muestra la pantalla de inicio de sesión o registro.
      return Scaffold(
        appBar: AppBar(
          title: Text('Inicio de Sesión o Registro'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'images/cancherito.jpg', // Ruta de la imagen del logo.
                width: 400, // Ancho de la imagen.
                height: 400, // Altura de la imagen.
              ),
              
              SizedBox(height: 20), // Separación entre la imagen y el primer campo

              Container(
                width: 300, // <-- AQUÍ controlas el ancho del TextField
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    border: OutlineInputBorder(), // Opcional: Le da un borde más estético
                  ),
                ),
              ),

              SizedBox(height: 15), // Separación entre los campos de texto

              Container(
                width: 300, // <-- AQUÍ controlas el ancho del TextField
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                     // Opcional: Borde visible
                  ),
                  obscureText: true, // Oculta el texto de la contraseña.
                ),
              ),
              
              SizedBox(height: 30), // Separación antes del botón
              
              SizedBox(
                width: 200, // Ancho del botón
                height: 45, // Alto del botón
                child: ElevatedButton(
                  onPressed: login, // Llama a la función de inicio de sesión.
                  child: Text('Iniciar Sesión'),
                ),
              ),

              SizedBox(
                width: 350, // Ancho del botón
                height: 45,
                child: TextButton(
                  onPressed: register, // Llama a la función de registro.
                  child: Text('¿No tienes una cuenta? Regístrate aquí.'),
              ),
                ),
            ],
          ),
        ),
      );
    }
  }
}

class RegisterScreen extends StatelessWidget { // Define una clase llamada RegisterScreen que extiende StatelessWidget.
  @override
  Widget build(BuildContext context) { // Método para construir la interfaz de RegisterScreen.
    TextEditingController registerEmailController = TextEditingController(); // Controlador para el correo electrónico de registro.
    TextEditingController registerPasswordController = TextEditingController(); // Controlador para la contraseña de registro.

    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
           Container(
              width: 300, // <-- AQUÍ controlas el ancho del TextField
              child: TextField(
              controller: registerEmailController,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico', 
                border: OutlineInputBorder()),
              ),
            ),

            SizedBox(height: 15),

            Container(
              width: 300, // <-- AQUÍ controlas el ancho del TextField
              child: TextField(
              controller: registerPasswordController,
              decoration: InputDecoration(
                labelText: 'Contraseña', 
                border: OutlineInputBorder()),
              obscureText: true, // Oculta el texto de la contraseña.
              ),
            ),

            SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                final registerEmail = registerEmailController.text; // Obtiene el correo electrónico ingresado.
                final registerPassword = registerPasswordController.text; // Obtiene la contraseña ingresada.
                final result = {'email': registerEmail, 'password': registerPassword}; // Crea un mapa con los datos de registro.
                Navigator.pop(context, result); // Cierra la pantalla de registro y devuelve los datos al estado anterior.
              },
              child: Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}

class HelloWorldScreen extends StatelessWidget { // Define una clase llamada HelloWorldScreen que extiende StatelessWidget.
  Future<void> _abrirUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el enlace: $url');
    }
  }

  @override
  Widget build(BuildContext context) { // Método para construir la interfaz de HelloWorldScreen.
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
                crossAxisCount: 2, // Define 2 columnas
                shrinkWrap: true, // Crucial para que funcione dentro de un Column o ListView
                physics: NeverScrollableScrollPhysics(), // Evita que la grilla tenga su propio scroll
                crossAxisSpacing: 10, // Espacio horizontal entre imágenes
                mainAxisSpacing: 10, // Espacio vertical entre imágenes
                padding: EdgeInsets.all(10), // Margen alrededor de la grilla
                children: [
                
                  // Imagen 1
                  InkWell( // Alto del botón
                    onTap: () => _abrirUrl('https://www.youtube.com'), // URL del sitio 1
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Bordes redondeados opcionales
                      child: Image.asset('images/yt.png', fit: BoxFit.cover),
                    ),
                  ),

                  // Imagen 2
                  InkWell(
                    onTap: () => _abrirUrl('https://www.spotify.com'), // URL del sitio 2
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('images/spotify.jpg', fit: BoxFit.cover),
                    ),
                  ),

                  // Imagen 3
                  InkWell(
                    onTap: () => _abrirUrl('https://www.instagram.com'), // URL del sitio 3
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('images/instagram.png', fit: BoxFit.cover),
                    ),
                  ),

                  // Imagen 4
                  InkWell(
                    onTap: () => _abrirUrl('https://www.whatsapp.com'), // URL del sitio 4
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('images/whatsapp.jpg', fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20), // Margen superior para separar del GridView
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/'); // Vuelve a la pantalla de inicio de sesión
                },
                child: Text('Cerrar Sesión'),
              ),
            )
          ],
        ),
        
      ),
    );
  }
}
