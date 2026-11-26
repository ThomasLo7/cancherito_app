import 'package:flutter/material.dart';
import 'package:cancherito/app_theme.dart';
import 'package:cancherito/database_helper.dart';
import 'package:cancherito/models.dart';
import 'package:cancherito/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  final _db = DatabaseHelper();
  List<Reserva> _todas = [];
  Map<String, Grupo> _grupos = {};
  bool _historial = false;

  @override
  void initState() {
    super.initState();
    _cargar();
    _db.cambios.addListener(_cargar);
  }

  @override
  void dispose() {
    _db.cambios.removeListener(_cargar);
    super.dispose();
  }

  Future<void> _cargar() async {
    final r = await _db.getReservas();
    final g = await _db.getGrupos();
    if (!mounted) return;
    setState(() {
      _todas = r;
      _grupos = {for (final x in g) x.nombre: x};
    });
  }

  List<Reserva> get _proximas => _todas.where((r) => r.proxima).toList();
  List<Reserva> get _pasadas =>
      _todas.where((r) => !r.proxima).toList().reversed.toList();

  Future<void> _cancelar(Reserva r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Paleta.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancelar reserva'),
        content: Text(
          '¿Quieres cancelar ${r.canchaNombre} el ${Fechas.larga(r.fecha)} a las ${r.hora}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sí, cancelar',
              style: TextStyle(color: Paleta.peligro),
            ),
          ),
        ],
      ),
    );
    if (ok != true || r.id == null) return;
    await _db.deleteReserva(r.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reserva cancelada')),
    );
  }

  void _verQr(Reserva r) {
    final datos =
        'CANCHERITO|${r.codigo}|${r.canchaNombre}|${Fechas.iso(r.fecha)}|${r.hora}';
    showModalBottomSheet(
      context: context,
      backgroundColor: Paleta.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'QR de acceso',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${r.canchaNombre} · ${Fechas.larga(r.fecha)} · ${r.hora} hrs',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Paleta.apagado, fontSize: 12),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: QrImageView(
                data: datos,
                size: 200,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              r.codigo,
              style: estiloMono(size: 14, color: Paleta.primario, peso: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
    Widget tab(String texto, bool activo, VoidCallback onTap) => Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 11),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: activo ? Paleta.primario : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                texto,
                style: TextStyle(
                  color: activo ? Colors.white : Paleta.apagado,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: cardDeco(radius: 16),
      child: Row(
        children: [
          tab('Próximas (${_proximas.length})', !_historial,
              () => setState(() => _historial = false)),
          tab('Historial', _historial, () => setState(() => _historial = true)),
        ],
      ),
    );
  }

  Widget _info(IconData icono, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 14, color: Paleta.apagado),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(
            color: Paleta.apagado,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _tarjeta(Reserva r) {
    final color = r.deporte.color;
    final grupo = r.grupo == null ? null : _grupos[r.grupo];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: cardDeco(radius: 20, borde: color.withAlpha(70)),
      child: Column(
        children: [
          Container(
            color: color.withAlpha(24),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Text(r.deporte.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.deporte.nombre,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                ChipTag(
                  texto: r.proxima ? 'Próxima' : 'Completada',
                  color: r.proxima ? Paleta.verde : Paleta.apagado,
                  size: 11,
                ),
                const SizedBox(width: 8),
                Text(
                  r.codigo,
                  style: estiloMono(
                    size: 10,
                    color: Paleta.apagado,
                    peso: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.canchaNombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            r.superficie,
                            style: const TextStyle(
                              color: Paleta.apagado,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      dinero(r.total),
                      style: estiloMono(
                        size: 17,
                        color: Paleta.verde,
                        peso: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    _info(Icons.calendar_today_rounded, Fechas.larga(r.fecha)),
                    _info(
                      Icons.schedule_rounded,
                      '${r.hora} – ${horaFin(r.hora)} hrs',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (grupo != null) ...[
                      AvatarStack(nombres: grupo.miembros, size: 26),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          grupo.nombre,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Paleta.apagado,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ] else
                      _info(Icons.person_outline_rounded, 'Reserva individual'),
                    const Spacer(),
                    if (r.proxima)
                      GestureDetector(
                        onTap: () => _cancelar(r),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Paleta.peligro,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (r.proxima) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        backgroundColor: color.withAlpha(24),
                        side: BorderSide(color: color.withAlpha(110)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                      label: const Text(
                        'Ver QR de acceso',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => _verQr(r),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: cardDeco(radius: 24),
      child: Column(
        children: [
          const Icon(Icons.event_note_rounded, color: Paleta.tenue, size: 36),
          const SizedBox(height: 12),
          Text(
            _historial
                ? 'Aún no tienes reservas completadas.'
                : 'No tienes reservas próximas.\nReserva una cancha desde Home.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Paleta.apagado, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = _historial ? _pasadas : _proximas;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text(
          'Tu agenda',
          style: TextStyle(color: Paleta.apagado, fontSize: 13),
        ),
        const SizedBox(height: 2),
        const Text(
          'Reservas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        _tabs(),
        const SizedBox(height: 16),
        if (lista.isEmpty) _vacio() else for (final r in lista) _tarjeta(r),
      ],
    );
  }
}