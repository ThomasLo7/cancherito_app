import 'package:flutter/material.dart';
import 'package:cancherito/app_theme.dart';
import 'package:cancherito/models.dart';

class ConfirmacionPage extends StatelessWidget {
  final Reserva reserva;
  const ConfirmacionPage({super.key, required this.reserva});

  Widget _fila(String k, String v, {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: Paleta.apagado, fontSize: 13)),
          Text(
            v,
            style: mono
                ? estiloMono(size: 13, peso: FontWeight.bold)
                : const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = reserva;
    return Scaffold(
      backgroundColor: Paleta.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Paleta.verdeSuave,
                  shape: BoxShape.circle,
                  border: Border.all(color: Paleta.verde, width: 1.5),
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 42),
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Reserva confirmada!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${r.canchaNombre} · ${r.deporte.nombre}',
                style: const TextStyle(color: Paleta.apagado, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                '${Fechas.diaMes(r.fecha)} · ${r.hora} hrs',
                style: const TextStyle(color: Paleta.apagado, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: cardDeco(radius: 20),
                child: Column(
                  children: [
                    _fila('Cancha', r.canchaNombre),
                    _fila('Fecha', Fechas.dmy(r.fecha)),
                    _fila('Horario', '${r.hora} – ${horaFin(r.hora)} hrs'),
                    _fila('Código', r.codigo, mono: true),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, color: Paleta.borde),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(color: Paleta.apagado, fontSize: 13),
                        ),
                        Text(
                          dinero(r.total),
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
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Paleta.primario,
                    foregroundColor: Paleta.enPrimario,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text(
                    'Volver al calendario',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}