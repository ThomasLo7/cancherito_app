import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// Modelo de Datos para una Reserva
class Reserva {
  final String id;
  final String canchaNombre;
  final String deporte;
  final String precio;
  final DateTime fecha;
  final TimeOfDay hora;
  final String userEmail;

  Reserva({
    required this.id,
    required this.canchaNombre,
    required this.deporte,
    required this.precio,
    required this.fecha,
    required this.hora,
    required this.userEmail,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cancherito',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
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

  static Map<String, String> registeredUsers = {};
  // Almacenamiento central de reservas en memoria
  static List<Reserva> globalReservations = [];

  bool isLoggedIn = false;
  String currentUserEmail = '';

  void register() async {
    final result = await Navigator.pushNamed(context, '/register');
    if (result != null && result is Map<String, String>) {
      setState(() {
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

    if (registeredUsers.containsKey(enteredEmail) &&
        registeredUsers[enteredEmail] == enteredPassword) {
      setState(() {
        isLoggedIn = true;
        currentUserEmail = enteredEmail;
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
      currentUserEmail = '';
      emailController.clear();
      passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return HelloWorldScreen(
        userEmail: currentUserEmail,
        onLogout: logout,
        reservations: globalReservations,
      );
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
                  width: 280,
                  height: 280,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.sports_soccer, size: 100, color: Colors.green),
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

// MENÚ PRINCIPAL
class HelloWorldScreen extends StatefulWidget {
  final String userEmail;
  final VoidCallback onLogout;
  final List<Reserva> reservations;

  HelloWorldScreen({
    required this.userEmail,
    required this.onLogout,
    required this.reservations,
  });

  @override
  _HelloWorldScreenState createState() => _HelloWorldScreenState();
}

class _HelloWorldScreenState extends State<HelloWorldScreen> {
  @override
  Widget build(BuildContext context) {
    final userReservationsCount = widget.reservations
        .where((r) => r.userEmail == widget.userEmail)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Menú Principal - Cancherito'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: Icon(Icons.account_circle, size: 36),
              tooltip: 'Ver Perfil',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      userEmail: widget.userEmail,
                      onLogout: widget.onLogout,
                      reservations: widget.reservations,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '¡Hola de nuevo!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.userEmail,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 25),
            Text(
              '¿Qué deseas hacer hoy?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 15),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuCard(
                    context,
                    title: 'Ver Canchas Disponibles',
                    subtitle: 'Sintéticas, Fútbol 5, Baloncesto y más',
                    icon: Icons.sports_soccer,
                    color: Colors.green,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CanchasScreen(
                            userEmail: widget.userEmail,
                            reservations: widget.reservations,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    title: 'Mis Reservas ($userReservationsCount)',
                    subtitle: 'Revisa tus horarios y canchas apartadas',
                    icon: Icons.calendar_today,
                    color: Colors.orange,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MisReservasScreen(
                            userEmail: widget.userEmail,
                            reservations: widget.reservations,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    title: 'Mi Perfil',
                    subtitle: 'Gestiona tus datos de cuenta y sesión',
                    icon: Icons.person,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            userEmail: widget.userEmail,
                            onLogout: widget.onLogout,
                            reservations: widget.reservations,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 13)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

// LISTA DE CANCHAS CON OPCIÓN DE RESERVA
class CanchasScreen extends StatelessWidget {
  final String userEmail;
  final List<Reserva> reservations;

  CanchasScreen({required this.userEmail, required this.reservations});

  final List<Map<String, String>> canchas = [
    {
      'nombre': 'Cancha Sintética La Amistad',
      'deporte': 'Fútbol 5 / Sintética',
      'precio': '\$60.000 / hora',
      'ubicacion': 'Calle 36 # 15-20',
      'imagen': 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=600&auto=format&fit=crop&q=60',
    },
    {
      'nombre': 'Coliseo Deportivo Central',
      'deporte': 'Baloncesto / Voleibol',
      'precio': '\$45.000 / hora',
      'ubicacion': 'Carrera 27 # 45-10',
      'imagen': 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=600&auto=format&fit=crop&q=60',
    },
    {
      'nombre': 'Cancha de Grama Natural El Campín',
      'deporte': 'Fútbol 8 / Grama',
      'precio': '\$90.000 / hora',
      'ubicacion': 'Av. Quebradaseca # 12-05',
      'imagen': 'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=600&auto=format&fit=crop&q=60',
    },
    {
      'nombre': 'Arena Pádel & Tenis',
      'deporte': 'Pádel / Tenis',
      'precio': '\$70.000 / hora',
      'ubicacion': 'Anillo Vial Km 2',
      'imagen': 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=600&auto=format&fit=crop&q=60',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escenarios Deportivos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: canchas.length,
          itemBuilder: (context, index) {
            final cancha = canchas[index];
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(
                      cancha['imagen']!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 160,
                        color: Colors.grey[300],
                        child: Icon(Icons.sports_soccer, size: 60, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                cancha['nombre']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                cancha['precio']!,
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.sports, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(cancha['deporte']!, style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(cancha['ubicacion']!, style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FormularioReservaScreen(
                                    cancha: cancha,
                                    userEmail: userEmail,
                                    reservations: reservations,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: Icon(Icons.calendar_month, color: Colors.white),
                            label: Text(
                              'Reservar Cancha',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// NUEVA PANTALLA: FORMULARIO DE SELECCIÓN DE FECHA Y HORA
class FormularioReservaScreen extends StatefulWidget {
  final Map<String, String> cancha;
  final String userEmail;
  final List<Reserva> reservations;

  FormularioReservaScreen({
    required this.cancha,
    required this.userEmail,
    required this.reservations,
  });

  @override
  _FormularioReservaScreenState createState() => _FormularioReservaScreenState();
}

class _FormularioReservaScreenState extends State<FormularioReservaScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _confirmarReserva() {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona la fecha y la hora.')),
      );
      return;
    }

    final nuevaReserva = Reserva(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      canchaNombre: widget.cancha['nombre']!,
      deporte: widget.cancha['deporte']!,
      precio: widget.cancha['precio']!,
      fecha: selectedDate!,
      hora: selectedTime!,
      userEmail: widget.userEmail,
    );

    setState(() {
      widget.reservations.add(nuevaReserva);
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Reserva Confirmada!'),
          content: Text(
            'Has reservado ${widget.cancha['nombre']} para el '
            '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} a las '
            '${selectedTime!.format(context)}.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.of(context).pop(); // Regresa a la lista
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agendar Reserva'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.cancha['nombre']!,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              widget.cancha['deporte']!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 25),
            Text(
              'Selecciona la fecha y la hora de tu partido:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 15),
            Card(
              child: ListTile(
                leading: Icon(Icons.calendar_month, color: Colors.green),
                title: Text(
                  selectedDate == null
                      ? 'Seleccionar Fecha'
                      : 'Fecha: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                ),
                trailing: Icon(Icons.edit),
                onTap: () => _selectDate(context),
              ),
            ),
            SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: Icon(Icons.access_time, color: Colors.green),
                title: Text(
                  selectedTime == null
                      ? 'Seleccionar Hora de Inicio'
                      : 'Hora: ${selectedTime!.format(context)}',
                ),
                trailing: Icon(Icons.edit),
                onTap: () => _selectTime(context),
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _confirmarReserva,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.check_circle, color: Colors.white),
                label: Text(
                  'Confirmar Reserva',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PANTALLA: MIS RESERVAS
class MisReservasScreen extends StatefulWidget {
  final String userEmail;
  final List<Reserva> reservations;

  MisReservasScreen({required this.userEmail, required this.reservations});

  @override
  _MisReservasScreenState createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  @override
  Widget build(BuildContext context) {
    final myReservations = widget.reservations
        .where((r) => r.userEmail == widget.userEmail)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Reservas'),
      ),
      body: myReservations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey),
                  SizedBox(height: 15),
                  Text(
                    'Aún no tienes reservas activas',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: myReservations.length,
              itemBuilder: (context, index) {
                final r = myReservations[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Icon(Icons.sports_soccer, color: Colors.green[800]),
                    ),
                    title: Text(r.canchaNombre, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${r.deporte}\n'
                      'Fecha: ${r.fecha.day}/${r.fecha.month}/${r.fecha.year} - ${r.hora.format(context)}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: 'Cancelar Reserva',
                      onPressed: () {
                        setState(() {
                          widget.reservations.removeWhere((item) => item.id == r.id);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Reserva cancelada correctamente.')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// PANTALLA: PERFIL DE USUARIO
class ProfileScreen extends StatelessWidget {
  final String userEmail;
  final VoidCallback onLogout;
  final List<Reserva> reservations;

  ProfileScreen({
    required this.userEmail,
    required this.onLogout,
    required this.reservations,
  });

  @override
  Widget build(BuildContext context) {
    final myReservationsCount =
        reservations.where((r) => r.userEmail == userEmail).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Correo Electrónico:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            SizedBox(height: 5),
            Text(
              userEmail,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            Divider(),
            ListTile(
              leading: Icon(Icons.sports_soccer, color: Colors.green),
              title: Text('Mis Reservas ($myReservationsCount)'),
              subtitle: Text('Historial de canchas reservadas'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MisReservasScreen(
                      userEmail: userEmail,
                      reservations: reservations,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.blue),
              title: Text('Configuración de cuenta'),
              subtitle: Text('Cambiar contraseña o datos'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Configuración próximamente.')),
                );
              },
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onLogout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}