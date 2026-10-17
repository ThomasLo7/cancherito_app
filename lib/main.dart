import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

// Modelo de Datos para una Reserva
class Reserva {
  final String id;
  final String canchaNombre;
  final String deporte;
  final String precio;
  final String fechaStr; // Formato YYYY-MM-DD
  final String horaSlot; // Ejemplo: "08:00 AM - 09:00 AM"
  final String userEmail;

  Reserva({
    required this.id,
    required this.canchaNombre,
    required this.deporte,
    required this.precio,
    required this.fechaStr,
    required this.horaSlot,
    required this.userEmail,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'canchaNombre': canchaNombre,
        'deporte': deporte,
        'precio': precio,
        'fechaStr': fechaStr,
        'horaSlot': horaSlot,
        'userEmail': userEmail,
      };

  factory Reserva.fromJson(Map<String, dynamic> json) => Reserva(
        id: json['id'],
        canchaNombre: json['canchaNombre'],
        deporte: json['deporte'],
        precio: json['precio'],
        fechaStr: json['fechaStr'],
        horaSlot: json['horaSlot'],
        userEmail: json['userEmail'],
      );
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

  Map<String, String> registeredUsers = {};
  List<Reserva> globalReservations = [];

  bool isLoggedIn = false;
  String currentUserEmail = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromStorage();
  }

  // Cargar usuarios y reservas desde SharedPreferences (Base de Datos Local)
  Future<void> _loadDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar Usuarios
    final usersString = prefs.getString('registered_users');
    if (usersString != null) {
      Map<String, dynamic> decoded = jsonDecode(usersString);
      registeredUsers = decoded.map((key, value) => MapEntry(key, value.toString()));
    }

    // Cargar Reservas
    final reservationsString = prefs.getString('global_reservations');
    if (reservationsString != null) {
      List<dynamic> decodedList = jsonDecode(reservationsString);
      globalReservations = decodedList.map((item) => Reserva.fromJson(item)).toList();
    }

    // Cargar Sesión Activa
    final activeEmail = prefs.getString('active_user');
    if (activeEmail != null && activeEmail.isNotEmpty) {
      isLoggedIn = true;
      currentUserEmail = activeEmail;
    }

    setState(() {
      isLoading = false;
    });
  }

  // Guardar Usuarios en Storage
  Future<void> _saveUsersToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registered_users', jsonEncode(registeredUsers));
  }

  // Guardar Reservas en Storage
  Future<void> _saveReservationsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList =
        globalReservations.map((r) => r.toJson()).toList();
    await prefs.setString('global_reservations', jsonEncode(jsonList));
  }

  // Guardar Estado de Sesión
  Future<void> _setActiveUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_user', email);
  }

  void register() async {
    final result = await Navigator.pushNamed(context, '/register');
    if (result != null && result is Map<String, String>) {
      setState(() {
        registeredUsers[result['email']!] = result['password']!;
      });

      await _saveUsersToStorage();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Registro exitoso! Ya puedes iniciar sesión.')),
      );
    }
  }

  void login() async {
    final enteredEmail = emailController.text.trim();
    final enteredPassword = passwordController.text.trim();

    if (registeredUsers.containsKey(enteredEmail) &&
        registeredUsers[enteredEmail] == enteredPassword) {
      await _setActiveUser(enteredEmail);
      setState(() {
        isLoggedIn = true;
        currentUserEmail = enteredEmail;
      });
    } else if (!registeredUsers.containsKey(enteredEmail)) {
      _showErrorDialog('Este correo no está registrado. Por favor regístrate primero.');
    } else {
      _showErrorDialog('Contraseña incorrecta. Verifica tus datos.');
    }
  }

  void logout() async {
    await _setActiveUser('');
    setState(() {
      isLoggedIn = false;
      currentUserEmail = '';
      emailController.clear();
      passwordController.clear();
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error de inicio de sesión'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isLoggedIn) {
      return HelloWorldScreen(
        userEmail: currentUserEmail,
        onLogout: logout,
        reservations: globalReservations,
        onReservationsUpdated: _saveReservationsToStorage,
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text('Inicio de Sesión - Cancherito')),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'images/cancherito.jpg',
                  width: 260,
                  height: 260,
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
                SizedBox(height: 25),
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
      appBar: AppBar(title: Text('Registro')),
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
                  final registerEmail = registerEmailController.text.trim();
                  final registerPassword = registerPasswordController.text.trim();
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
  final VoidCallback onReservationsUpdated;

  HelloWorldScreen({
    required this.userEmail,
    required this.onLogout,
    required this.reservations,
    required this.onReservationsUpdated,
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
                      onReservationsUpdated: widget.onReservationsUpdated,
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
                            onReservationsUpdated: widget.onReservationsUpdated,
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
                            onReservationsUpdated: widget.onReservationsUpdated,
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
                            onReservationsUpdated: widget.onReservationsUpdated,
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

// LISTA DE CANCHAS
class CanchasScreen extends StatelessWidget {
  final String userEmail;
  final List<Reserva> reservations;
  final VoidCallback onReservationsUpdated;

  CanchasScreen({
    required this.userEmail,
    required this.reservations,
    required this.onReservationsUpdated,
  });

  final List<Map<String, dynamic>> canchas = [
    {
      'nombre': 'Cancha Sintética La Amistad',
      'deporte': 'Fútbol 5 / Sintética',
      'precio': '\$60.000 / hora',
      'ubicacion': 'Calle 36 # 15-20',
      'horaApertura': '08:00 AM',
      'horaCierre': '10:00 PM',
      'imagen': 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?w=600&auto=format&fit=crop&q=60',
      'horarios': [
        '08:00 AM - 09:00 AM',
        '09:00 AM - 10:00 AM',
        '10:00 AM - 11:00 AM',
        '02:00 PM - 03:00 PM',
        '03:00 PM - 04:00 PM',
        '04:00 PM - 05:00 PM',
        '06:00 PM - 07:00 PM',
        '07:00 PM - 08:00 PM',
        '08:00 PM - 09:00 PM',
        '09:00 PM - 10:00 PM',
      ]
    },
    {
      'nombre': 'Coliseo Deportivo Central',
      'deporte': 'Baloncesto / Voleibol',
      'precio': '\$45.000 / hora',
      'ubicacion': 'Carrera 27 # 45-10',
      'horaApertura': '07:00 AM',
      'horaCierre': '09:00 PM',
      'imagen': 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=600&auto=format&fit=crop&q=60',
      'horarios': [
        '07:00 AM - 08:00 AM',
        '08:00 AM - 09:00 AM',
        '09:00 AM - 10:00 AM',
        '03:00 PM - 04:00 PM',
        '04:00 PM - 05:00 PM',
        '05:00 PM - 06:00 PM',
        '07:00 PM - 08:00 PM',
        '08:00 PM - 09:00 PM',
      ]
    },
    {
      'nombre': 'Cancha El Campín',
      'deporte': 'Fútbol 8 / Grama',
      'precio': '\$90.000 / hora',
      'ubicacion': 'Av. Quebradaseca # 12-05',
      'horaApertura': '08:00 AM',
      'horaCierre': '08:00 PM',
      'imagen': 'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=600&auto=format&fit=crop&q=60',
      'horarios': [
        '08:00 AM - 09:00 AM',
        '10:00 AM - 11:00 AM',
        '02:00 PM - 03:00 PM',
        '04:00 PM - 05:00 PM',
        '06:00 PM - 07:00 PM',
        '07:00 PM - 08:00 PM',
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escenarios Deportivos')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: canchas.length,
          itemBuilder: (context, index) {
            final cancha = canchas[index];
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text('Horario: ${cancha['horaApertura']} a ${cancha['horaCierre']}',
                                style: TextStyle(color: Colors.grey[700])),
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
                                    onReservationsUpdated: onReservationsUpdated,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: Icon(Icons.calendar_month, color: Colors.white),
                            label: Text('Ver Horarios y Reservar', style: TextStyle(color: Colors.white)),
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

// FORMULARIO DE RESERVA CON HORARIOS ESTABLECIDOS Y BLOQUEO DE OCUPADOS
class FormularioReservaScreen extends StatefulWidget {
  final Map<String, dynamic> cancha;
  final String userEmail;
  final List<Reserva> reservations;
  final VoidCallback onReservationsUpdated;

  FormularioReservaScreen({
    required this.cancha,
    required this.userEmail,
    required this.reservations,
    required this.onReservationsUpdated,
  });

  @override
  _FormularioReservaScreenState createState() => _FormularioReservaScreenState();
}

class _FormularioReservaScreenState extends State<FormularioReservaScreen> {
  DateTime selectedDate = DateTime.now().add(Duration(days: 1));
  String? selectedSlot;

  String get _formattedDateStr =>
      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedSlot = null; // Reiniciar slot seleccionado al cambiar de día
      });
    }
  }

  // Verifica si una hora específica de esta cancha ya fue tomada por ALGUIEN en esa fecha
  bool _isSlotOccupied(String slot) {
    return widget.reservations.any((r) =>
        r.canchaNombre == widget.cancha['nombre'] &&
        r.fechaStr == _formattedDateStr &&
        r.horaSlot == slot);
  }

  void _confirmarReserva() {
    if (selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona un turno u horario disponible.')),
      );
      return;
    }

    final nuevaReserva = Reserva(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      canchaNombre: widget.cancha['nombre']!,
      deporte: widget.cancha['deporte']!,
      precio: widget.cancha['precio']!,
      fechaStr: _formattedDateStr,
      horaSlot: selectedSlot!,
      userEmail: widget.userEmail,
    );

    setState(() {
      widget.reservations.add(nuevaReserva);
    });

    widget.onReservationsUpdated(); // Guardar en SharedPreferences

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Reserva Confirmada!'),
          content: Text(
            'Has reservado ${widget.cancha['nombre']} para el '
            '$_formattedDateStr en el horario $selectedSlot.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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
    final List<String> horariosCancha = widget.cancha['horarios'];

    return Scaffold(
      appBar: AppBar(title: Text('Horarios Disponibles')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.cancha['nombre']!,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Apertura: ${widget.cancha['horaApertura']} - Cierre: ${widget.cancha['horaCierre']}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Icon(Icons.calendar_month, color: Colors.green),
                title: Text('Fecha: $_formattedDateStr'),
                trailing: Icon(Icons.edit_calendar),
                onTap: () => _selectDate(context),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Selecciona un turno disponible:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: horariosCancha.length,
                itemBuilder: (context, index) {
                  final slot = horariosCancha[index];
                  final isOccupied = _isSlotOccupied(slot);
                  final isSelected = selectedSlot == slot;

                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? Colors.green : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      tileColor: isOccupied
                          ? Colors.red.shade50
                          : (isSelected ? Colors.green.shade50 : Colors.white),
                      leading: Icon(
                        isOccupied
                            ? Icons.block
                            : (isSelected ? Icons.check_circle : Icons.access_time),
                        color: isOccupied
                            ? Colors.red
                            : (isSelected ? Colors.green : Colors.grey),
                      ),
                      title: Text(
                        slot,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isOccupied ? Colors.red.shade700 : Colors.black,
                        ),
                      ),
                      trailing: Text(
                        isOccupied ? 'OCUPADO' : (isSelected ? 'SELECCIONADO' : 'LIBRE'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isOccupied ? Colors.red : Colors.green,
                        ),
                      ),
                      onTap: isOccupied
                          ? null // Deshabilitar si está ocupado
                          : () {
                              setState(() {
                                selectedSlot = slot;
                              });
                            },
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: selectedSlot == null ? null : _confirmarReserva,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.check, color: Colors.white),
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
  final VoidCallback onReservationsUpdated;

  MisReservasScreen({
    required this.userEmail,
    required this.reservations,
    required this.onReservationsUpdated,
  });

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
      appBar: AppBar(title: Text('Mis Reservas')),
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
                      'Fecha: ${r.fechaStr} | Horario: ${r.horaSlot}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: 'Cancelar Reserva',
                      onPressed: () {
                        setState(() {
                          widget.reservations.removeWhere((item) => item.id == r.id);
                        });
                        widget.onReservationsUpdated(); // Guardar cambios en el storage local
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
  final VoidCallback onReservationsUpdated;

  ProfileScreen({
    required this.userEmail,
    required this.onLogout,
    required this.reservations,
    required this.onReservationsUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final myReservationsCount =
        reservations.where((r) => r.userEmail == userEmail).length;

    return Scaffold(
      appBar: AppBar(title: Text('Perfil de Usuario')),
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
                      onReservationsUpdated: onReservationsUpdated,
                    ),
                  ),
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