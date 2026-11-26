import 'package:flutter/material.dart';
import 'package:cancherito/app_theme.dart';
import 'package:cancherito/models.dart';

// ---------------------------------------------------------------------------
// CHIPS
// ---------------------------------------------------------------------------
class ChipTag extends StatelessWidget {
  final String texto;
  final Color color;
  final Widget? leading;
  final bool mono;
  final double size;

  const ChipTag({
    super.key,
    required this.texto,
    required this.color,
    this.leading,
    this.mono = false,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(34),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 5)],
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontSize: size,
              fontWeight: FontWeight.w600,
              fontFamily: mono ? kMono : null,
            ),
          ),
        ],
      ),
    );
  }
}

class SportChip extends StatelessWidget {
  final Deporte deporte;
  const SportChip({super.key, required this.deporte});

  @override
  Widget build(BuildContext context) {
    return ChipTag(
      texto: deporte.nombre,
      color: deporte.color,
      leading: Text(deporte.emoji, style: const TextStyle(fontSize: 12)),
    );
  }
}

class RatingChip extends StatelessWidget {
  final double rating;
  const RatingChip({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x99000000),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: Paleta.estrella),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: estiloMono(size: 12, peso: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AVATARES
// ---------------------------------------------------------------------------
class Avatar extends StatelessWidget {
  final String nombre;
  final double size;
  const Avatar({super.key, required this.nombre, this.size = 32});

  static const _colores = [
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF0EA5E9),
    Color(0xFF8B5CF6),
  ];

  @override
  Widget build(BuildContext context) {
    final limpio = nombre.trim();
    final inicial = limpio.isEmpty
        ? '?'
        : String.fromCharCode(limpio.runes.first).toUpperCase();
    final color =
        _colores[limpio.codeUnits.fold<int>(0, (a, b) => a + b) % _colores.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        inicial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}

/// Avatares superpuestos con un "+N" al final.
class AvatarStack extends StatelessWidget {
  final List<String> nombres;
  final int maxVisibles;
  final double size;

  const AvatarStack({
    super.key,
    required this.nombres,
    this.maxVisibles = 4,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final visibles = nombres.take(maxVisibles).toList();
    final extra = nombres.length - visibles.length;
    final total = visibles.length + (extra > 0 ? 1 : 0);
    if (total == 0) return const SizedBox.shrink();

    final paso = size * 0.72;
    Widget conBorde(Widget hijo) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Paleta.card, width: 2),
          ),
          child: hijo,
        );

    return SizedBox(
      width: paso * (total - 1) + size,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < visibles.length; i++)
            Positioned(
              left: i * paso,
              child: conBorde(Avatar(nombre: visibles[i], size: size)),
            ),
          if (extra > 0)
            Positioned(
              left: visibles.length * paso,
              child: conBorde(
                Container(
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Paleta.card2,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '+$extra',
                    style: TextStyle(
                      color: Paleta.apagado,
                      fontSize: size * 0.36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TÍTULO DE SECCIÓN (ej. "DEPORTES FAVORITOS")
// ---------------------------------------------------------------------------
class TituloSeccion extends StatelessWidget {
  final String texto;
  const TituloSeccion(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto.toUpperCase(),
      style: const TextStyle(
        color: Paleta.apagado,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ARTE DE CANCHA (no necesita imágenes en assets)
// ---------------------------------------------------------------------------
class CanchaArt extends StatelessWidget {
  final Deporte deporte;
  final String? imageUrl;
  final double height;
  final BorderRadius radius;
  final Widget? child;

  const CanchaArt({
    super.key,
    required this.deporte,
    required this.height,
    this.imageUrl,
    this.radius = const BorderRadius.all(Radius.circular(20)),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final dibujo = CustomPaint(painter: _CanchaPainter(deporte));
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => dibujo,
              )
            else
              dibujo,
            // Degradado oscuro abajo para que se lea el texto.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xCC000000)],
                  stops: [0.35, 1.0],
                ),
              ),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

class _CanchaPainter extends CustomPainter {
  final Deporte d;
  _CanchaPainter(this.d);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    final (c1, c2) = switch (d) {
      Deporte.futbol => (const Color(0xFF3F8F3A), const Color(0xFF1F5D24)),
      Deporte.basquetbol => (const Color(0xFFC77B30), const Color(0xFF8A4B16)),
      Deporte.tenis => (const Color(0xFF2F6FB5), const Color(0xFF184A85)),
      Deporte.padel => (const Color(0xFF2BA6A4), const Color(0xFF16706F)),
      Deporte.voleibol => (const Color(0xFFE2C275), const Color(0xFFB98F43)),
    };

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c1, c2],
        ).createShader(rect),
    );

    // Franjas suaves (efecto césped / madera).
    final franja = Paint()..color = Colors.white.withAlpha(12);
    for (var i = 0; i < 8; i += 2) {
      canvas.drawRect(Rect.fromLTWH(w / 8 * i, 0, w / 8, h), franja);
    }

    final linea = Paint()
      ..color = Colors.white.withAlpha(210)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final r = Rect.fromLTRB(w * 0.12, h * 0.16, w * 0.88, h * 0.84);

    switch (d) {
      case Deporte.futbol:
        // Línea blanca diagonal, como en la foto del diseño.
        canvas.drawPath(
          Path()
            ..moveTo(w * 0.30, h)
            ..quadraticBezierTo(w * 0.55, h * 0.40, w, h * 0.12),
          Paint()
            ..color = Colors.white.withAlpha(215)
            ..style = PaintingStyle.stroke
            ..strokeWidth = h * 0.09,
        );
      case Deporte.tenis:
      case Deporte.padel:
        canvas.drawRect(r, linea);
        canvas.drawLine(Offset(w / 2, r.top), Offset(w / 2, r.bottom), linea);
        final x1 = r.left + r.width * 0.25;
        final x2 = r.left + r.width * 0.75;
        canvas.drawLine(Offset(x1, r.top), Offset(x1, r.bottom), linea);
        canvas.drawLine(Offset(x2, r.top), Offset(x2, r.bottom), linea);
        canvas.drawLine(Offset(x1, h / 2), Offset(x2, h / 2), linea);
      case Deporte.basquetbol:
        canvas.drawRect(r, linea);
        canvas.drawLine(Offset(w / 2, r.top), Offset(w / 2, r.bottom), linea);
        canvas.drawCircle(Offset(w / 2, h / 2), h * 0.16, linea);
      case Deporte.voleibol:
        canvas.drawRect(r, linea);
        canvas.drawLine(Offset(w / 2, r.top), Offset(w / 2, r.bottom), linea);
        final a1 = r.left + r.width / 3;
        final a2 = r.left + r.width * 2 / 3;
        canvas.drawLine(Offset(a1, r.top), Offset(a1, r.bottom), linea);
        canvas.drawLine(Offset(a2, r.top), Offset(a2, r.bottom), linea);
    }
  }

  @override
  bool shouldRepaint(covariant _CanchaPainter old) => old.d != d;
}