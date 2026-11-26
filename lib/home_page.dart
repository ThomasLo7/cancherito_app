import 'package:flutter/material.dart';
import 'package:cancherito/app_theme.dart';
import 'package:cancherito/cancha_detail_page.dart';
import 'package:cancherito/database_helper.dart';
import 'package:cancherito/models.dart';
import 'package:cancherito/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _db = DatabaseHelper();
  late DateTime _mes; // primer día del mes visible
  DateTime? _sel;
  Set<String> _ocupadas = {};

  @override
  void initState() {
    super.initState();
    final h = Fechas.hoy;
    _mes = DateTime(h.year, h.month);
    _db.cambios.addListener(_cargarOcupadas);
  }

  @override
  void dispose() {
    _db.cambios.removeListener(_cargarOcupadas);
    super.dispose();
  }

  // ---- lógica ----
  bool _disponible(DateTime d) {
    final hoy = Fechas.hoy;
    if (d.isBefore(hoy)) return false;
    if (d.difference(hoy).inDays > 60) return false; // se reserva hasta 60 días antes
    return Catalogo.disponiblesEn(d).isNotEmpty;
  }

  Future<void> _cargarOcupadas() async {
    final s = _sel;
    if (s == null) return;
    final o = await _db.ocupadasDelDia(Fechas.iso(s));
    if (!mounted) return;
    setState(() => _ocupadas = o);
  }

  int _libres(Cancha c) =>
      c.horarios.where((h) => !_ocupadas.contains('${c.id}|$h')).length;

  bool get _puedeAtras {
    final h = Fechas.hoy;
    return _mes.isAfter(DateTime(h.year, h.month));
  }

  bool get _puedeAdelante {
    final limite = Fechas.masDias(Fechas.hoy, 60);
    return !DateTime(_mes.year, _mes.month + 1).isAfter(limite);
  }

  void _cambiarMes(int delta) =>
      setState(() => _mes = DateTime(_mes.year, _mes.month + delta));

  int get _fechasDisp {
    final n = DateTime(_mes.year, _mes.month + 1, 0).day;
    var c = 0;
    for (var i = 1; i <= n; i++) {
      if (_disponible(DateTime(_mes.year, _mes.month, i))) c++;
    }
    return c;
  }

  Future<void> _abrir(Cancha c) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CanchaDetailPage(cancha: c, fecha: _sel!),
      ),
    );
    _cargarOcupadas();
  }

  // ---- UI ----
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reserva tu espacio',
                    style: TextStyle(color: Paleta.apagado, fontSize: 13),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Canchas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Paleta.primarioSuave,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Paleta.primario.withAlpha(90)),
              ),
              child: Text(
                '$_fechasDisp fechas disp.',
                style: const TextStyle(
                  color: Paleta.primario,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _calendario(),
        const SizedBox(height: 14),
        _leyenda(),
        const SizedBox(height: 16),
        if (_sel == null) _vacio() else ..._listaCanchas(),
      ],
    );
  }

  Widget _calendario() {
    final offset = DateTime(_mes.year, _mes.month, 1).weekday % 7; // domingo = 0
    final diasMes = DateTime(_mes.year, _mes.month + 1, 0).day;
    final filas = ((offset + diasMes) / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDeco(radius: 24),
      child: Column(
        children: [
          Row(
            children: [
              _flecha(
                Icons.chevron_left_rounded,
                _puedeAtras ? () => _cambiarMes(-1) : null,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${Fechas.meses[_mes.month - 1]} ${_mes.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              _flecha(
                Icons.chevron_right_rounded,
                _puedeAdelante ? () => _cambiarMes(1) : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final d in ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa'])
                Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        color: Paleta.tenue,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (var f = 0; f < filas; f++)
            Row(
              children: [
                for (var c = 0; c < 7; c++)
                  Expanded(child: _celda(f * 7 + c - offset + 1, diasMes)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _flecha(IconData icono, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Paleta.card2,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icono,
          size: 20,
          color: onTap == null ? Paleta.tenue : Colors.white,
        ),
      ),
    );
  }

  Widget _celda(int dia, int diasMes) {
    if (dia < 1 || dia > diasMes) return const SizedBox(height: 54);

    final d = DateTime(_mes.year, _mes.month, dia);
    final disp = _disponible(d);
    final esHoy = Fechas.mismo(d, Fechas.hoy);
    final sel = _sel != null && Fechas.mismo(d, _sel!);
    final deportes = disp
        ? Catalogo.disponiblesEn(d).map((c) => c.deporte).toSet().take(4).toList()
        : <Deporte>[];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disp
          ? () {
              setState(() => _sel = d);
              _cargarOcupadas();
            }
          : null,
      child: Container(
        height: 50,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: sel ? Paleta.primario : (esHoy ? Paleta.primarioSuave : null),
          borderRadius: BorderRadius.circular(14),
          border: esHoy && !sel
              ? Border.all(color: Paleta.primario.withAlpha(120))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dia',
              style: TextStyle(
                fontSize: 15,
                fontWeight: disp ? FontWeight.bold : FontWeight.w500,
                color: disp ? Colors.white : Paleta.tenue,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final dep in deportes)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: sel ? Colors.white : dep.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leyenda() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final d in Deporte.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: d.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(
                '${d.emoji} ${d.nombre}',
                style: const TextStyle(color: Paleta.apagado, fontSize: 11),
              ),
            ],
          ),
      ],
    );
  }

  Widget _vacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: cardDeco(radius: 24),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Paleta.primarioSuave,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Paleta.primario,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Toca una fecha para ver\nlas canchas disponibles',
            textAlign: TextAlign.center,
            style: TextStyle(color: Paleta.apagado, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  List<Widget> _listaCanchas() {
    final s = _sel!;
    final canchas =
        Catalogo.disponiblesEn(s).where((c) => _libres(c) > 0).toList();
    return [
      Text(
        Fechas.diaMes(s),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        canchas.length == 1
            ? '1 cancha disponible'
            : '${canchas.length} canchas disponibles',
        style: const TextStyle(color: Paleta.apagado, fontSize: 12),
      ),
      const SizedBox(height: 14),
      if (canchas.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: cardDeco(radius: 20),
          child: const Text(
            'Ya no quedan horarios para este día.\nElige otra fecha.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Paleta.apagado, fontSize: 13, height: 1.4),
          ),
        )
      else
        for (final c in canchas) _tarjeta(c),
    ];
  }

  Widget _dato(IconData icono, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 13, color: Paleta.tenue),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(color: Paleta.apagado, fontSize: 12)),
      ],
    );
  }

  Widget _tarjeta(Cancha c) {
    final libres = _libres(c);
    return GestureDetector(
      onTap: () => _abrir(c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: cardDeco(radius: 20),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            CanchaArt(
              deporte: c.deporte,
              imageUrl: c.imageUrl,
              height: 100,
              radius: BorderRadius.zero,
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    right: 10,
                    child: RatingChip(rating: c.rating),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 10,
                    child: SportChip(deporte: c.deporte),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              c.superficie,
                              style: const TextStyle(
                                color: Paleta.apagado,
                                fontSize: 12,
                              ),
                            ),
                            _dato(Icons.group_outlined, '${c.capacidad} pers.'),
                            _dato(
                              Icons.schedule_rounded,
                              libres == 1 ? '1 horario' : '$libres horarios',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${dinero(c.precio)}/hr',
                    style: estiloMono(
                      size: 15,
                      color: Paleta.verde,
                      peso: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}