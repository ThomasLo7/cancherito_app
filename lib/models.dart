import 'package:flutter/material.dart';
import 'package:cancherito/app_theme.dart';

// ---------------------------------------------------------------------------
// DEPORTES
// ---------------------------------------------------------------------------
enum Deporte { futbol, basquetbol, tenis, padel, voleibol }

extension DeporteX on Deporte {
  String get nombre => switch (this) {
        Deporte.futbol => 'Fútbol',
        Deporte.basquetbol => 'Básquetbol',
        Deporte.tenis => 'Tenis',
        Deporte.padel => 'Pádel',
        Deporte.voleibol => 'Voleibol',
      };

  String get emoji => switch (this) {
        Deporte.futbol => '⚽',
        Deporte.basquetbol => '🏀',
        Deporte.tenis => '🎾',
        Deporte.padel => '🏓',
        Deporte.voleibol => '🏐',
      };

  Color get color => switch (this) {
        Deporte.futbol => const Color(0xFF34D399),
        Deporte.basquetbol => const Color(0xFFF97316),
        Deporte.tenis => const Color(0xFFFACC15),
        Deporte.padel => const Color(0xFF8B8DF8),
        Deporte.voleibol => const Color(0xFF38BDF8),
      };
}

Deporte deporteDesde(String n) => Deporte.values
    .firstWhere((d) => d.name == n, orElse: () => Deporte.futbol);

// ---------------------------------------------------------------------------
// CANCHA (catálogo fijo)
// ---------------------------------------------------------------------------
class Cancha {
  final String id;
  final String nombre;
  final Deporte deporte;
  final String superficie;
  final int capacidad;
  final double precio; // por hora
  final double rating;
  final List<int> dias; // DateTime.weekday: 1 = lunes ... 7 = domingo
  final List<String> horarios;

  /// Opcional: URL de una foto real. Si es null se dibuja la cancha.
  final String? imageUrl;

  const Cancha({
    required this.id,
    required this.nombre,
    required this.deporte,
    required this.superficie,
    required this.capacidad,
    required this.precio,
    required this.rating,
    required this.dias,
    required this.horarios,
    this.imageUrl,
  });
}

class Catalogo {
  Catalogo._();

  // Días con cancha: martes (2), jueves (4) y sábado (6).
  static const canchas = <Cancha>[
    Cancha(
      id: 'a1', nombre: 'Cancha A1', deporte: Deporte.futbol,
      superficie: 'Pasto sintético', capacidad: 10, precio: 350, rating: 4.8,
      dias: [2, 6], horarios: ['08:00', '10:00', '17:00', '19:00', '20:00'],
    ),
    Cancha(
      id: 'a2', nombre: 'Cancha A2', deporte: Deporte.futbol,
      superficie: 'Pasto sintético', capacidad: 10, precio: 300, rating: 4.5,
      dias: [6], horarios: ['09:00', '11:00', '16:00', '18:00'],
    ),
    Cancha(
      id: 'a3', nombre: 'Cancha A3', deporte: Deporte.futbol,
      superficie: 'Pasto sintético', capacidad: 10, precio: 320, rating: 4.7,
      dias: [4, 6], horarios: ['08:00', '10:00', '15:00', '17:00', '19:00'],
    ),
    Cancha(
      id: 'b2', nombre: 'Cancha B2', deporte: Deporte.basquetbol,
      superficie: 'Parquet', capacidad: 10, precio: 200, rating: 4.5,
      dias: [2], horarios: ['09:00', '11:00', '16:00', '18:00'],
    ),
    Cancha(
      id: 't1', nombre: 'Cancha Tenis 1', deporte: Deporte.tenis,
      superficie: 'Arcilla', capacidad: 4, precio: 140, rating: 4.6,
      dias: [2, 6], horarios: ['07:00', '09:00', '16:00', '18:00'],
    ),
    Cancha(
      id: 't2', nombre: 'Cancha Tenis 2', deporte: Deporte.tenis,
      superficie: 'Cemento', capacidad: 4, precio: 150, rating: 4.4,
      dias: [4, 6], horarios: ['07:00', '09:00', '16:00', '18:00'],
    ),
    Cancha(
      id: 'p2', nombre: 'Cancha Pádel 2', deporte: Deporte.padel,
      superficie: 'Cristal', capacidad: 4, precio: 260, rating: 4.9,
      dias: [2, 6], horarios: ['09:00', '11:00', '17:00', '19:00'],
    ),
    Cancha(
      id: 'v1', nombre: 'Cancha Voleibol 1', deporte: Deporte.voleibol,
      superficie: 'Arena', capacidad: 12, precio: 180, rating: 4.3,
      dias: [6], horarios: ['10:00', '12:00', '16:00'],
    ),
  ];

  static Cancha? porId(String id) {
    for (final c in canchas) {
      if (c.id == id) return c;
    }
    return null;
  }

  static List<Cancha> disponiblesEn(DateTime d) =>
      canchas.where((c) => c.dias.contains(d.weekday)).toList();
}

// ---------------------------------------------------------------------------
// RESERVA (SQLite)
// ---------------------------------------------------------------------------
class Reserva {
  final int? id;
  final String canchaId;
  final String canchaNombre;
  final Deporte deporte;
  final String superficie;
  final DateTime fecha;
  final String hora; // '10:00'
  final double total;
  final String? grupo; // nombre del grupo, null = reserva individual

  Reserva({
    this.id,
    required this.canchaId,
    required this.canchaNombre,
    required this.deporte,
    required this.superficie,
    required this.fecha,
    required this.hora,
    required this.total,
    this.grupo,
  });

  Reserva conId(int nuevoId) => Reserva(
        id: nuevoId,
        canchaId: canchaId,
        canchaNombre: canchaNombre,
        deporte: deporte,
        superficie: superficie,
        fecha: fecha,
        hora: hora,
        total: total,
        grupo: grupo,
      );

  /// RSV-2026-0001
  String get codigo =>
      'RSV-${fecha.year}-${(id ?? 0).toString().padLeft(4, '0')}';

  bool get proxima => !fecha.isBefore(Fechas.hoy);

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'cancha_id': canchaId,
        'cancha_nombre': canchaNombre,
        'deporte': deporte.name,
        'superficie': superficie,
        'fecha': Fechas.iso(fecha),
        'hora': hora,
        'total': total,
        'grupo': grupo,
      };

  factory Reserva.fromMap(Map<String, dynamic> m) => Reserva(
        id: m['id'] as int?,
        canchaId: m['cancha_id'] as String,
        canchaNombre: m['cancha_nombre'] as String,
        deporte: deporteDesde(m['deporte'] as String),
        superficie: (m['superficie'] ?? '') as String,
        fecha: Fechas.parse(m['fecha'] as String),
        hora: m['hora'] as String,
        total: (m['total'] as num).toDouble(),
        grupo: m['grupo'] as String?,
      );
}

// ---------------------------------------------------------------------------
// GRUPO DE AMIGOS (SQLite)
// ---------------------------------------------------------------------------
class Grupo {
  final int? id;
  final String nombre;
  final Deporte deporte;
  final String ultimoMensaje;
  final String hora; // '10:42' o 'Ayer'
  final int noLeidos;
  final DateTime? proximaFecha;
  final String? proximaHora;
  final List<String> miembros;

  Grupo({
    this.id,
    required this.nombre,
    required this.deporte,
    required this.ultimoMensaje,
    required this.hora,
    this.noLeidos = 0,
    this.proximaFecha,
    this.proximaHora,
    this.miembros = const [],
  });

  /// 'Vie 5 Sep · 19:00 hrs'
  String? get proximaTexto => proximaFecha == null
      ? null
      : '${Fechas.corta(proximaFecha!)} · ${proximaHora ?? ''} hrs';

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'nombre': nombre,
        'deporte': deporte.name,
        'ultimo_mensaje': ultimoMensaje,
        'hora': hora,
        'no_leidos': noLeidos,
        'proxima_fecha':
            proximaFecha == null ? null : Fechas.iso(proximaFecha!),
        'proxima_hora': proximaHora,
        'miembros': miembros.join(','),
      };

  factory Grupo.fromMap(Map<String, dynamic> m) => Grupo(
        id: m['id'] as int?,
        nombre: (m['nombre'] ?? '') as String,
        deporte: deporteDesde((m['deporte'] ?? 'futbol') as String),
        ultimoMensaje: (m['ultimo_mensaje'] ?? '') as String,
        hora: (m['hora'] ?? '') as String,
        noLeidos: (m['no_leidos'] ?? 0) as int,
        proximaFecha: m['proxima_fecha'] == null
            ? null
            : Fechas.parse(m['proxima_fecha'] as String),
        proximaHora: m['proxima_hora'] as String?,
        miembros: ((m['miembros'] ?? '') as String)
            .split(',')
            .where((e) => e.isNotEmpty)
            .toList(),
      );
}