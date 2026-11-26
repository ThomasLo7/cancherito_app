import 'package:flutter/material.dart';

/// Colores del diseño de Cancherito (tema oscuro + lavanda).
class Paleta {
  Paleta._();
  static const bg = Color(0xFF0B0B14);
  static const card = Color(0xFF13131E);
  static const card2 = Color(0xFF1B1B29);
  static const borde = Color(0xFF252535);
  static const primario = Color(0xFF8B8DF8);
  static const primarioSuave = Color(0xFF1E1F3D);
  static const enPrimario = Color(0xFF12122A); // texto sobre botones lavanda
  static const verde = Color(0xFF34D399);
  static const verdeSuave = Color(0xFF10261E);
  static const apagado = Color(0xFF8A8AA0);
  static const tenue = Color(0xFF4B4B5F);
  static const peligro = Color(0xFFF87171);
  static const estrella = Color(0xFFFBBF24);
}

const String kMono = 'monospace';

/// Si quieres ver el calendario EXACTAMENTE como en el diseño (septiembre 2026,
/// hoy = jueves 3), cambia null por DateTime(2026, 9, 3).
/// Déjalo en null para usar la fecha real del teléfono.
final DateTime? kHoyFijo = null;

class Fechas {
  Fechas._();

  static const meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];
  static const mesesCortos = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];
  static const diasLargos = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];
  static const diasCortos = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  /// Hoy a las 00:00 (o la fecha fija de [kHoyFijo]).
  static DateTime get hoy {
    final n = kHoyFijo ?? DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static DateTime masDias(DateTime d, int n) =>
      DateTime(d.year, d.month, d.day + n);

  static bool mismo(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _d2(int n) => n.toString().padLeft(2, '0');

  /// 2026-09-24
  static String iso(DateTime d) => '${d.year}-${_d2(d.month)}-${_d2(d.day)}';

  static DateTime parse(String s) {
    final p = s.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  /// 24/09/2026
  static String dmy(DateTime d) => '${_d2(d.day)}/${_d2(d.month)}/${d.year}';

  /// Jueves 24 Sep 2026
  static String larga(DateTime d) =>
      '${diasLargos[d.weekday - 1]} ${d.day} ${mesesCortos[d.month - 1]} ${d.year}';

  /// Jue 24 Sep
  static String corta(DateTime d) =>
      '${diasCortos[d.weekday - 1]} ${d.day} ${mesesCortos[d.month - 1]}';

  /// 24 de Septiembre
  static String diaMes(DateTime d) => '${d.day} de ${meses[d.month - 1]}';
}

/// $320  (o $336.00 si [decimales] es true o el valor no es entero)
String dinero(double v, {bool decimales = false}) {
  final conDecimales = decimales || v != v.roundToDouble();
  return '\$${v.toStringAsFixed(conDecimales ? 2 : 0)}';
}

/// '10:00' -> '11:00'
String horaFin(String hora) {
  final h = int.parse(hora.substring(0, 2)) + 1;
  return '${h.toString().padLeft(2, '0')}:${hora.substring(3)}';
}

TextStyle estiloMono({
  double size = 14,
  Color color = Colors.white,
  FontWeight peso = FontWeight.w600,
}) =>
    TextStyle(fontFamily: kMono, fontSize: size, color: color, fontWeight: peso);

BoxDecoration cardDeco({double radius = 20, Color? borde, Color? fondo}) {
  return BoxDecoration(
    color: fondo ?? Paleta.card,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borde ?? Paleta.borde),
  );
}