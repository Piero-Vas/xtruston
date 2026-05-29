import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_flutter/logic/cubits/inspection_cubit.dart';
import 'package:test_flutter/logic/cubits/sync_cubit.dart';
import 'package:test_flutter/presentation/widgets/app_snackbar.dart';
import 'package:test_flutter/presentation/widgets/sync_status_badge.dart';
import 'package:test_flutter/presentation/widgets/sync_warning_card.dart';

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

    AppSnackBar.showSuccess(context, 'Observación guardada. Subiendo actualización...');
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
        if (!_isEditing &&
            _observationController.text != inspection.observation &&
            _originalObservation != inspection.observation) {
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
                    SyncStatusBadge(status: inspection.status, isLarge: true),
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
                SyncWarningCard(inspection: inspection),

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
                      inspection.observation.isEmpty ? 'Sin observaciones registradas.' : inspection.observation,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
