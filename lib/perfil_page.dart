import 'package:flutter/material.dart';
import 'package:cancherito/app_theme.dart';
import 'package:cancherito/auth_service.dart';
import 'package:cancherito/database_helper.dart';
import 'package:cancherito/models.dart';
import 'package:cancherito/widgets.dart';

class _MedioPago {
  final String marca;
  final String terminacion;
  final Color c1;
  final Color c2;
  const _MedioPago(this.marca, this.terminacion, this.c1, this.c2);
}

// Datos de ejemplo (demo). No se guardan números reales de tarjetas.
const _medios = [
  _MedioPago('VISA', '•••• 4242', Color(0xFF1E2A8A), Color(0xFF3B47C4)),
  _MedioPago('Mastercard', '•••• 8810', Color(0xFF8F2A14), Color(0xFFD1581F)),
];

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _db = DatabaseHelper();
  final _auth = AuthService();

  String? _nombreGuardado;
  Set<String> _deportesFav = {};
  Set<String> _canchasFav = {};
  int _pago = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Set<String> _aSet(String csv) => csv.split(',').where((e) => e.isNotEmpty).toSet();

  Future<void> _cargar() async {
    final n = await _db.getAjuste('nombre');
    final d = await _db.getAjuste('deportes_fav') ?? 'futbol,padel';
    final c = await _db.getAjuste('canchas_fav') ?? 'a1,p2';
    final p = await _db.getAjuste('medio_pago') ?? '0';
    if (!mounted) return;
    setState(() {
      _nombreGuardado = n;
      _deportesFav = _aSet(d);
      _canchasFav = _aSet(c);
      _pago = int.tryParse(p) ?? 0;
    });
  }

  String get _nombre {
    final guardado = _nombreGuardado;
    if (guardado != null && guardado.isNotEmpty) return guardado;
    final u = _auth.currentUser;
    final dn = u?.displayName;
    if (dn != null && dn.isNotEmpty) return dn;
    final mail = u?.email;
    if (mail != null && mail.contains('@')) {
      final base = mail.split('@').first.replaceAll(RegExp(r'[._]+'), ' ').trim();
      if (base.isNotEmpty) {
        return base
            .split(' ')
            .map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1))
            .join(' ');
      }
    }
    return 'Sofia Reyes';
  }

  String get _email => _auth.currentUser?.email ?? 'sofia.reyes@email.com';

  Future<void> _editarNombre() async {
    final ctrl = TextEditingController(text: _nombre);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Paleta.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Editar nombre'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            filled: true,
            fillColor: Paleta.card2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    final texto = ctrl.text.trim();
    if (ok != true || texto.isEmpty) return;
    await _db.setAjuste('nombre', texto);
    if (!mounted) return;
    setState(() => _nombreGuardado = texto);
  }

  Future<void> _toggleDeporte(Deporte d) async {
    setState(() {
      if (!_deportesFav.remove(d.name)) _deportesFav.add(d.name);
    });
    await _db.setAjuste('deportes_fav', _deportesFav.join(','));
  }

  Future<void> _toggleCancha(Cancha c) async {
    setState(() {
      if (!_canchasFav.remove(c.id)) _canchasFav.add(c.id);
    });
    await _db.setAjuste('canchas_fav', _canchasFav.join(','));
  }

  Future<void> _elegirPago(int i) async {
    setState(() => _pago = i);
    await _db.setAjuste('medio_pago', '$i');
  }

  Future<void> _salir() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    // AuthGate detecta el cierre de sesión y muestra el login.
  }

  // ---- UI ----
  Widget _cabecera() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Paleta.primario, width: 1.5),
              ),
              child: Avatar(nombre: _nombre, size: 86),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Paleta.verde,
                  shape: BoxShape.circle,
                  border: Border.all(color: Paleta.bg, width: 2.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _editarNombre,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _nombre,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.edit_outlined, size: 16, color: Paleta.tenue),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(_email, style: const TextStyle(color: Paleta.apagado, fontSize: 13)),
        const SizedBox(height: 12),
        const ChipTag(texto: 'Premium · desde Ene 2023', color: Paleta.primario),
      ],
    );
  }

  Widget _chipDeporte(Deporte d) {
    final fav = _deportesFav.contains(d.name);
    final color = fav ? d.color : Paleta.apagado;
    return GestureDetector(
      onTap: () => _toggleDeporte(d),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: fav ? d.color.withAlpha(30) : Paleta.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: fav ? d.color.withAlpha(110) : Paleta.borde),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(d.emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text(
              d.nombre,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            if (fav) ...[
              const SizedBox(width: 4),
              Icon(Icons.star_rounded, size: 13, color: color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _canchasFavoritas() {
    final favs = Catalogo.canchas.where((c) => _canchasFav.contains(c.id));
    final resto = Catalogo.canchas.where((c) => !_canchasFav.contains(c.id));
    final lista = [...favs, ...resto];

    return Container(
      decoration: cardDeco(radius: 20),
      child: Column(
        children: [
          for (var i = 0; i < lista.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Paleta.borde),
            InkWell(
              onTap: () => _toggleCancha(lista[i]),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(lista[i].deporte.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lista[i].nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      _canchasFav.contains(lista[i].id)
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: _canchasFav.contains(lista[i].id)
                          ? Paleta.estrella
                          : Paleta.tenue,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tarjetaPago(int i) {
    final m = _medios[i];
    final sel = _pago == i;
    return GestureDetector(
      onTap: () => _elegirPago(i),
      child: Container(
        width: 250,
        margin: EdgeInsets.only(right: i == _medios.length - 1 ? 0 : 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [m.c1, m.c2],
          ),
          border: Border.all(
            color: sel ? Colors.white : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(28),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        m.marca,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      if (sel)
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(60),
                          ),
                          child: const Icon(Icons.check_rounded,
                              size: 14, color: Colors.white),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    m.terminacion,
                    style: estiloMono(size: 17, peso: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _nombre.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        _cabecera(),
        const SizedBox(height: 28),
        const TituloSeccion('Deportes favoritos'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [for (final d in Deporte.values) _chipDeporte(d)],
        ),
        const SizedBox(height: 28),
        const TituloSeccion('Canchas favoritas'),
        const SizedBox(height: 12),
        _canchasFavoritas(),
        const SizedBox(height: 28),
        const TituloSeccion('Mis medios de pago'),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [for (var i = 0; i < _medios.length; i++) _tarjetaPago(i)],
          ),
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Paleta.peligro,
            side: BorderSide(color: Paleta.peligro.withAlpha(90)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Cerrar sesión'),
          onPressed: _salir,
        ),
      ],
    );
  }
}