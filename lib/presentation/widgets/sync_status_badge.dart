import 'package:flutter/material.dart';

class SyncStatusBadge extends StatelessWidget {
  final String status;
  final bool isLarge;

  const SyncStatusBadge({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String label;

    switch (status) {
      case 'synced':
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        label = 'Sincronizado';
        break;
      case 'conflict':
        icon = Icons.error_rounded;
        color = Colors.red;
        label = 'Conflicto';
        break;
      case 'pending':
      default:
        icon = Icons.watch_later_rounded;
        color = Colors.orange;
        label = 'Pendiente';
        break;
    }

    // Diseño detallado y alargado para la pantalla de detalle
    if (isLarge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      );
    }

    // Diseño compacto para las tarjetas de la lista principal
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
