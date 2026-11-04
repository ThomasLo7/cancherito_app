import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cancherito/amigos_page.dart';
import 'package:cancherito/app_theme.dart';
import 'package:cancherito/home_page.dart';
import 'package:cancherito/perfil_page.dart';
import 'package:cancherito/reservas_page.dart';

/// Contiene las 4 pestañas y la barra inferior.
/// La pestaña Home tiene su propio Navigator para que el detalle de la cancha
/// y la confirmación se vean con la barra inferior visible (como en el diseño).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final _homeNav = GlobalKey<NavigatorState>();

  void _onTap(int i) {
    // Tocar Home estando en Home vuelve al calendario.
    if (i == 0 && _index == 0) {
      _homeNav.currentState?.popUntil((r) => r.isFirst);
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final nav = _homeNav.currentState;
        if (_index == 0 && nav != null && nav.canPop()) {
          nav.pop();
          return;
        }
        if (_index != 0) {
          setState(() => _index = 0);
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: Paleta.bg,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _index,
            children: [
              Navigator(
                key: _homeNav,
                onGenerateRoute: (settings) => MaterialPageRoute(
                  builder: (_) => const HomePage(),
                  settings: settings,
                ),
              ),
              const AmigosPage(),
              const ReservasPage(),
              const PerfilPage(),
            ],
          ),
        ),
        bottomNavigationBar: _BarraNav(index: _index, onTap: _onTap),
      ),
    );
  }
}

class _BarraNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BarraNav({required this.index, required this.onTap});

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.group_outlined, 'Amigos'),
    (Icons.monitor_heart_outlined, 'Reservas'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Paleta.bg,
        border: Border(top: BorderSide(color: Paleta.borde)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: _item(i == index, _items[i].$1, _items[i].$2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(bool activo, IconData icono, String etiqueta) {
    final color = activo ? Paleta.primario : Paleta.tenue;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: activo ? Paleta.primarioSuave : Colors.transparent,
            boxShadow: activo
                ? [
                    BoxShadow(
                      color: Paleta.primario.withAlpha(70),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          child: Icon(icono, size: 22, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          etiqueta,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}