import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_flutter/domain/models/inspection_model.dart';
import 'package:test_flutter/logic/cubits/sync_cubit.dart';

class SyncWarningCard extends StatelessWidget {
  final InspectionModel inspection;

  const SyncWarningCard({super.key, required this.inspection});

  @override
  Widget build(BuildContext context) {
    if (inspection.status == 'synced') return const SizedBox.shrink();

    final isConflict = inspection.status == 'conflict';
    final color = isConflict ? Colors.red : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(isConflict ? Icons.error : Icons.cloud_off, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConflict ? 'Error de Conflicto en Servidor' : 'Pendiente de Sincronización',
                      style: TextStyle(fontWeight: FontWeight.bold, color: color[800] ?? color, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isConflict
                          ? 'El backend rechazó este registro (Simulación de conflicto 409). Edita el registro o intenta re-sincronizar de forma manual.'
                          : 'Este registro se guardó localmente porque no había conexión. Se sincronizará automáticamente cuando vuelvas a tener red.',
                      style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Botón de Forzar sincronización manual
          BlocBuilder<SyncCubit, SyncState>(
            builder: (context, syncState) {
              final isSyncingSingle = syncState is Syncing && syncState.pendingCount == 1;

              return ElevatedButton.icon(
                onPressed: isSyncingSingle
                    ? null
                    : () => context.read<SyncCubit>().syncSingle(inspection.id),
                icon: isSyncingSingle
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
                      )
                    : const Icon(Icons.sync_rounded),
                label: Text(
                  isSyncingSingle ? 'Sincronizando...' : 'Sincronizar ahora',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
