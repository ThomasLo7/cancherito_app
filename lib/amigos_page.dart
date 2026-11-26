import 'package:flutter/material.dart';
import 'package:cancherito/app_theme.dart';
import 'package:cancherito/database_helper.dart';
import 'package:cancherito/models.dart';
import 'package:cancherito/widgets.dart';

class AmigosPage extends StatefulWidget {
  const AmigosPage({super.key});

  @override
  State<AmigosPage> createState() => _AmigosPageState();
}

class _AmigosPageState extends State<AmigosPage> {
  final _db = DatabaseHelper();
  List<Grupo> _grupos = [];

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
    final g = await _db.getGrupos();
    if (!mounted) return;
    setState(() => _grupos = g);
  }

  String _horaActual() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _nuevoGrupo() async {
    final nombre = TextEditingController();
    var dep = Deporte.futbol;

    final crear = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: Paleta.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Nuevo grupo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nombre,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Nombre del grupo',
                  filled: true,
                  fillColor: Paleta.card2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final d in Deporte.values)
                    ChoiceChip(
                      label: Text('${d.emoji} ${d.nombre}'),
                      selected: dep == d,
                      selectedColor: d.color.withAlpha(60),
                      onSelected: (_) => setD(() => dep = d),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );

    final texto = nombre.text.trim();
    if (crear != true) return;
    if (texto.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un nombre para el grupo')),
      );
      return;
    }
    await _db.insertGrupo(
      Grupo(
        nombre: texto,
        deporte: dep,
        ultimoMensaje: 'Grupo creado. ¡Invita a tus amigos!',
        hora: _horaActual(),
        miembros: const ['Tú'],
      ),
    );
  }

  Future<void> _abrirGrupo(Grupo g) async {
    if (g.noLeidos > 0 && g.id != null) await _db.marcarLeido(g.id!);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Paleta.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    g.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SportChip(deporte: g.deporte),
              ],
            ),
            if (g.proximaTexto != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 13, color: Paleta.apagado),
                  const SizedBox(width: 6),
                  Text(
                    'Próximo partido: ${g.proximaTexto}',
                    style: const TextStyle(color: Paleta.apagado, fontSize: 13),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            const TituloSeccion('Miembros'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                for (final m in g.miembros)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Avatar(nombre: m, size: 40),
                      const SizedBox(height: 4),
                      Text(
                        m,
                        style: const TextStyle(color: Paleta.apagado, fontSize: 11),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Paleta.peligro,
                  side: BorderSide(color: Paleta.peligro.withAlpha(90)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Eliminar grupo'),
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (g.id != null) await _db.deleteGrupo(g.id!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cluster(List<String> m) {
    final n = m.isEmpty ? <String>['?'] : m;
    const pos = [Offset(0, 0), Offset(22, 6), Offset(8, 24)];
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        children: [
          for (var i = 0; i < n.length && i < 3; i++)
            Positioned(
              left: pos[i].dx,
              top: pos[i].dy,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Paleta.card, width: 2),
                ),
                child: Avatar(nombre: n[i], size: 30),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tarjeta(Grupo g) {
    return GestureDetector(
      onTap: () => _abrirGrupo(g),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: cardDeco(radius: 20),
        child: Row(
          children: [
            _cluster(g.miembros),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          g.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChipTag(texto: g.deporte.emoji, color: g.deporte.color, size: 11),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    g.ultimoMensaje,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Paleta.apagado, fontSize: 12.5),
                  ),
                  if (g.proximaTexto != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 11, color: Paleta.tenue),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            g.proximaTexto!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Paleta.tenue, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  g.hora,
                  style: const TextStyle(color: Paleta.apagado, fontSize: 11),
                ),
                const SizedBox(height: 8),
                if (g.noLeidos > 0)
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Paleta.primario,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${g.noLeidos}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Paleta.verdeSuave,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 14, color: Paleta.verde),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
                    'Mis grupos',
                    style: TextStyle(color: Paleta.apagado, fontSize: 13),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Amigos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Paleta.primario,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Nuevo grupo',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              onPressed: _nuevoGrupo,
            ),
          ],
        ),
        const SizedBox(height: 20),
        for (final g in _grupos) _tarjeta(g),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Crea un grupo para coordinar tu reserva con amigos',
            textAlign: TextAlign.center,
            style: TextStyle(color: Paleta.tenue, fontSize: 12),
          ),
        ),
      ],
    );
  }
}