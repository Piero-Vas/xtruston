import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/inspection_model.dart';
import '../../logic/cubits/inspection_cubit.dart';
import '../../logic/cubits/sync_cubit.dart';

class InspectionDetailPage extends StatefulWidget {
  final String inspectionId;

  const InspectionDetailPage({super.key, required this.inspectionId});

  @override
  State<InspectionDetailPage> createState() => _InspectionDetailPageState();
}

class _InspectionDetailPageState extends State<InspectionDetailPage> {
  final _observationController = TextEditingController();
  bool _isEditing = false;
  String _originalObservation = '';

  @override
  void dispose() {
    _observationController.dispose();
    super.dispose();
  }

  void _saveObservationChanges() {
    final newObservation = _observationController.text.trim();
    context.read<InspectionCubit>().updateObservation(widget.inspectionId, newObservation);
    
    // Al guardar los cambios, el estado local vuelve a 'pending'.
    // Disparamos la sincronización asíncrona de inmediato
    context.read<SyncCubit>().syncPendingQueue();

    setState(() {
      _isEditing = false;
      _originalObservation = newObservation;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Observación guardada. Subiendo actualización...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InspectionCubit, InspectionState>(
      builder: (context, state) {
        if (state is! InspectionLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Buscar el elemento en la lista actual
        final inspectionList = state.inspections;
        final inspectionIndex = inspectionList.indexWhere((i) => i.id == widget.inspectionId);

        if (inspectionIndex == -1) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Registro no encontrado.')),
          );
        }

        final inspection = inspectionList[inspectionIndex];

        // Inicializamos los valores del controlador la primera vez que se carga
        if (!_isEditing && _observationController.text != inspection.observation && _originalObservation != inspection.observation) {
          _observationController.text = inspection.observation;
          _originalObservation = inspection.observation;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalle de Inspección', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen grande con bordes redondeados
                Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  child: AspectRatio(
                    aspectRatio: 16 / 11,
                    child: Image.file(
                      File(inspection.photoPath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, color: Colors.grey, size: 64),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Nombre del Lugar y Categoría
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inspection.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              inspection.category,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSyncStatusBadge(inspection.status),
                  ],
                ),
                const SizedBox(height: 8),

                // Fecha
                Text(
                  'Creado el: ${_formatDate(inspection.createdAt)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Alerta de estado offline-sync
                if (inspection.status != 'synced') _buildSyncWarning(context, inspection),

                const SizedBox(height: 16),

                // Observación editable
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Observación',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    if (!_isEditing)
                      TextButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Editar'),
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                      )
                    else
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _observationController.text = _originalObservation;
                              });
                            },
                            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _saveObservationChanges,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Guardar'),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                if (!_isEditing)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      inspection.observation.isEmpty
                          ? 'Sin observaciones registradas.'
                          : inspection.observation,
                      style: TextStyle(
                        fontSize: 15,
                        color: inspection.observation.isEmpty ? Colors.grey[500] : Colors.black87,
                        fontStyle: inspection.observation.isEmpty ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  )
                else
                  TextField(
                    controller: _observationController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Ingresa observaciones sobre el lugar...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    autofocus: true,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSyncStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'synced':
        color = Colors.green;
        label = 'Sincronizado';
        break;
      case 'conflict':
        color = Colors.red;
        label = 'Conflicto';
        break;
      case 'pending':
      default:
        color = Colors.orange;
        label = 'Pendiente';
        break;
    }

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

  Widget _buildSyncWarning(BuildContext context, InspectionModel inspection) {
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
