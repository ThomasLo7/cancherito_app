import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:cancherito/app_theme.dart';
import 'package:cancherito/models.dart';
import 'package:sqflite/sqflite.dart';

/// Helper SQLite de Cancherito (singleton).
/// Tablas: reservas, grupos y ajustes (clave/valor para el perfil).
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  factory DatabaseHelper() => instance;

  static Future<Database>? _abriendo;
  static const String dbName = 'cancherito.db';

  /// Las pantallas escuchan este notificador para recargarse cuando
  /// se crea o borra una reserva / un grupo.
  final ValueNotifier<int> cambios = ValueNotifier<int>(0);
  void _notificar() => cambios.value++;

  Future<Database> get database => _abriendo ??= _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), dbName);
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reservas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cancha_id TEXT,
        cancha_nombre TEXT,
        deporte TEXT,
        superficie TEXT,
        fecha TEXT,
        hora TEXT,
        total REAL,
        grupo TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE grupos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        deporte TEXT,
        ultimo_mensaje TEXT,
        hora TEXT,
        no_leidos INTEGER,
        proxima_fecha TEXT,
        proxima_hora TEXT,
        miembros TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE ajustes(
        clave TEXT PRIMARY KEY,
        valor TEXT
      )
    ''');
    await _sembrar(db);
  }

  /// Datos de ejemplo, calculados respecto a "hoy".
  Future<void> _sembrar(Database db) async {
    final hoy = Fechas.hoy;
    String dia(int n) => Fechas.iso(Fechas.masDias(hoy, n));

    final batch = db.batch();

    final reservas = <Map<String, Object?>>[
      {
        'cancha_id': 'a1', 'cancha_nombre': 'Cancha A1', 'deporte': 'futbol',
        'superficie': 'Pasto sintético', 'fecha': dia(2), 'hora': '19:00',
        'total': 350.0, 'grupo': 'Los Cracks FC',
      },
      {
        'cancha_id': 'p2', 'cancha_nombre': 'Cancha Pádel 2', 'deporte': 'padel',
        'superficie': 'Cristal', 'fecha': dia(3), 'hora': '09:00',
        'total': 260.0, 'grupo': 'Pádel Mixto',
      },
      {
        'cancha_id': 't1', 'cancha_nombre': 'Cancha Tenis 1', 'deporte': 'tenis',
        'superficie': 'Arcilla', 'fecha': dia(-9), 'hora': '16:00',
        'total': 140.0, 'grupo': null,
      },
      {
        'cancha_id': 'a3', 'cancha_nombre': 'Cancha A3', 'deporte': 'futbol',
        'superficie': 'Pasto sintético', 'fecha': dia(-16), 'hora': '17:00',
        'total': 320.0, 'grupo': 'Los Cracks FC',
      },
    ];
    for (final r in reservas) {
      batch.insert('reservas', r);
    }

    final grupos = <Map<String, Object?>>[
      {
        'nombre': 'Los Cracks FC', 'deporte': 'futbol',
        'ultimo_mensaje': 'Carlos: ¡Confirmado! Ya pagué mi parte 💪',
        'hora': '10:42', 'no_leidos': 3,
        'proxima_fecha': dia(2), 'proxima_hora': '19:00',
        'miembros': 'Carlos,Ana,Luis,Mateo,Diego',
      },
      {
        'nombre': 'Pádel Mixto', 'deporte': 'padel',
        'ultimo_mensaje': 'Tú: Ahí estaré puntual 👍',
        'hora': 'Ayer', 'no_leidos': 0,
        'proxima_fecha': dia(3), 'proxima_hora': '09:00',
        'miembros': 'Valeria,Andrés,Camila,Tomás',
      },
      {
        'nombre': 'Tenis Dominical', 'deporte': 'tenis',
        'ultimo_mensaje': 'Ana: ¿Confirman o cancelamos? 🤔',
        'hora': '08:05', 'no_leidos': 1,
        'proxima_fecha': dia(4), 'proxima_hora': '07:00',
        'miembros': 'Ana,Pedro,Laura',
      },
    ];
    for (final g in grupos) {
      batch.insert('grupos', g);
    }

    await batch.commit(noResult: true);
  }

  // ---- Reservas ----
  Future<int> insertReserva(Reserva r) async {
    final db = await database;
    final id = await db.insert('reservas', r.toMap());
    _notificar();
    return id;
  }

  Future<List<Reserva>> getReservas() async {
    final db = await database;
    final rows = await db.query('reservas', orderBy: 'fecha ASC, hora ASC');
    return rows.map(Reserva.fromMap).toList();
  }

  Future<int> deleteReserva(int id) async {
    final db = await database;
    final n = await db.delete('reservas', where: 'id = ?', whereArgs: [id]);
    _notificar();
    return n;
  }

  /// Horarios ya reservados ese día, como "canchaId|hora" (ej. "a3|10:00").
  Future<Set<String>> ocupadasDelDia(String fechaIso) async {
    final db = await database;
    final rows = await db.query(
      'reservas',
      columns: ['cancha_id', 'hora'],
      where: 'fecha = ?',
      whereArgs: [fechaIso],
    );
    return rows.map((r) => '${r['cancha_id']}|${r['hora']}').toSet();
  }

  // ---- Grupos ----
  Future<List<Grupo>> getGrupos() async {
    final db = await database;
    final rows = await db.query('grupos', orderBy: 'id ASC');
    return rows.map(Grupo.fromMap).toList();
  }

  Future<int> insertGrupo(Grupo g) async {
    final db = await database;
    final id = await db.insert('grupos', g.toMap());
    _notificar();
    return id;
  }

  Future<void> marcarLeido(int id) async {
    final db = await database;
    await db.update('grupos', {'no_leidos': 0}, where: 'id = ?', whereArgs: [id]);
    _notificar();
  }

  Future<int> deleteGrupo(int id) async {
    final db = await database;
    final n = await db.delete('grupos', where: 'id = ?', whereArgs: [id]);
    _notificar();
    return n;
  }

  // ---- Ajustes del perfil (clave / valor) ----
  Future<String?> getAjuste(String clave) async {
    final db = await database;
    final rows = await db.query(
      'ajustes',
      where: 'clave = ?',
      whereArgs: [clave],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['valor'] as String?;
  }

  Future<void> setAjuste(String clave, String valor) async {
    final db = await database;
    await db.insert(
      'ajustes',
      {'clave': clave, 'valor': valor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}