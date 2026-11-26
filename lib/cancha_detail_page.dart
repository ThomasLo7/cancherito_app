import 'package:flutter/material.dart';
import 'package:cancherito/app_theme.dart';
import 'package:cancherito/confirmacion_page.dart';
import 'package:cancherito/database_helper.dart';
import 'package:cancherito/models.dart';
import 'package:cancherito/widgets.dart';

class CanchaDetailPage extends StatefulWidget {
  final Cancha cancha;
  final DateTime fecha;

  const CanchaDetailPage({super.key, required this.cancha, required this.fecha});

  @override
  State<CanchaDetailPage> createState() => _CanchaDetailPageState();
}

class _CanchaDetailPageState extends State<CanchaDetailPage> {
  final _db = DatabaseHelper();
  Set<String> _ocupadas = {};
  String? _hora;
  bool _guardando = false;

  Cancha get c => widget.cancha;
  double get _cargo => c.precio * 0.05; // cargo de servicio 5 %
  double get _total => c.precio + _cargo;

  List<String> get _libres =>
      c.horarios.where((h) => !_ocupadas.contains('${c.id}|$h')).toList();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final o = await _db.ocupadasDelDia(Fechas.iso(widget.fecha));
    if (!mounted) return;
    setState(() => _ocupadas = o);
  }

  void _aviso(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _reservar() async {
    final hora = _hora;
    if (hora == null || _guardando) return;
    setState(() => _guardando = true);
    try {
      // Verifica de nuevo que nadie haya tomado ese horario.
      final ocupadas = await _db.ocupadasDelDia(Fechas.iso(widget.fecha));
      if (!mounted) return;
      if (ocupadas.contains('${c.id}|$hora')) {
        setState(() {
          _guardando = false;
          _ocupadas = ocupadas;
          _hora = null;
        });
        _aviso('Ese horario ya fue reservado. Elige otro.');
        return;
      }

      final reserva = Reserva(
        canchaId: c.id,
        canchaNombre: c.nombre,
        deporte: c.deporte,
        superficie: c.superficie,
        fecha: widget.fecha,
        hora: hora,
        total: _total,
      );
      final id = await _db.insertReserva(reserva);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ConfirmacionPage(reserva: reserva.conId(id)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      _aviso('No se pudo guardar la reserva: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final libres = _libres;
    final mes = Fechas.meses[widget.fecha.month - 1].toUpperCase();

    return Scaffold(
      backgroundColor: Paleta.bg,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chevron_left_rounded,
                              color: Paleta.primario, size: 22),
                          Text(
                            'Canchas disponibles',
                            style: TextStyle(color: Paleta.primario, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                CanchaArt(
                  deporte: c.deporte,
                  imageUrl: c.imageUrl,
                  height: 150,
                  radius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.nombre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                c.superficie,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RatingChip(rating: c.rating),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SportChip(deporte: c.deporte),
                          ChipTag(
                            texto: '${c.capacidad} personas',
                            color: Paleta.primario,
                            leading: const Icon(
                              Icons.group_rounded,
                              size: 13,
                              color: Paleta.primario,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ChipTag(
                      texto: '${dinero(c.precio)}/hr',
                      color: Paleta.verde,
                      mono: true,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                TituloSeccion('Horarios disponibles · ${widget.fecha.day} $mes'),
                const SizedBox(height: 12),
                if (libres.isEmpty)
                  const Text(
                    'No quedan horarios libres en esta cancha.',
                    style: TextStyle(color: Paleta.apagado, fontSize: 13),
                  )
                else
                  LayoutBuilder(
                    builder: (context, cons) {
                      final w = ((cons.maxWidth - 20) / 3).floorToDouble();
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final h in libres)
                            SizedBox(width: w, child: _slot(h)),
                        ],
                      );
                    },
                  ),
                if (_hora != null) ...[
                  const SizedBox(height: 20),
                  _desglose(),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Paleta.primario,
                  foregroundColor: Paleta.enPrimario,
                  disabledBackgroundColor: Paleta.card2,
                  disabledForegroundColor: Paleta.tenue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: (_hora == null || _guardando) ? null : _reservar,
                child: Text(
                  _guardando
                      ? 'Reservando...'
                      : (_hora == null
                          ? 'Selecciona un horario'
                          : 'Reservar $_hora hrs'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slot(String h) {
    final sel = _hora == h;
    return GestureDetector(
      onTap: () => setState(() => _hora = h),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: sel ? Paleta.primario : Paleta.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? Paleta.primario : Paleta.borde),
        ),
        child: Column(
          children: [
            Text(
              h,
              style: estiloMono(
                size: 16,
                color: sel ? Paleta.enPrimario : Colors.white,
                peso: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '1 hora',
              style: TextStyle(
                fontSize: 11,
                color: sel ? Paleta.enPrimario.withAlpha(180) : Paleta.tenue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fila(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: Paleta.apagado, fontSize: 13)),
          Text(v, style: estiloMono(size: 13, peso: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _desglose() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDeco(radius: 20),
      child: Column(
        children: [
          _fila('Tarifa por hora', dinero(c.precio, decimales: true)),
          _fila('Cargo de servicio', dinero(_cargo, decimales: true)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Paleta.borde),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dinero(_total, decimales: true),
                style: estiloMono(
                  size: 18,
                  color: Paleta.verde,
                  peso: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}