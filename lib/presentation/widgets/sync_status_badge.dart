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
    Color baseColor;
    String label;
    IconData icon;

    switch (status) {
      case 'synced':
        baseColor = const Color(0xFF10B981); // Emerald-500 (Verde premium)
        label = 'Sincronizado';
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'conflict':
        baseColor = const Color(0xFFEF4444); // Red-500 (Rojo premium)
        label = 'Conflicto';
        icon = Icons.error_outline_rounded;
        break;
      case 'pending':
      default:
        baseColor = const Color(0xFFF59E0B); // Amber-500 (Naranja premium)
        label = 'Pendiente';
        icon = Icons.history_rounded;
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      child: isLarge
          ? _buildLargeBadge(baseColor, label)
          : _buildCompactBadge(baseColor, label, icon),
    );
  }

  Widget _buildLargeBadge(Color baseColor, String label) {
    return Container(
      key: ValueKey('large_$status'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: baseColor.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: baseColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: baseColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBadge(Color baseColor, String label, IconData icon) {
    return Container(
      key: ValueKey('compact_$status'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: baseColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: baseColor, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: baseColor,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
