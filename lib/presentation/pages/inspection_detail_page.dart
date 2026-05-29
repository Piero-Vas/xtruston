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

    AppSnackBar.showSuccess(context, 'Observación guardada. Sincronizando...');
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
          backgroundColor: const Color(0xFFF8FAFC), // Slate-50 fondo global
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8FAFC),
            title: const Text('Detalle', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen grande animada con Hero
                Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                  elevation: 0,
                  child: AspectRatio(
                    aspectRatio: 16 / 11,
                    child: Hero(
                      tag: 'photo_${inspection.id}',
                      child: Image.file(
                        File(inspection.photoPath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.broken_image_outlined, color: Color(0xFF94A3B8), size: 48),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Nombre del Lugar y Categoría con distribución moderna
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
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9), // Slate-100
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                            ),
                            child: Text(
                              inspection.category,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF475569), // Slate-600
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
                const SizedBox(height: 12),

                // Fecha de creación
                Text(
                  'Registrado el ${_formatDate(inspection.createdAt)}',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 28),

                // Alerta de estado offline-sync
                SyncWarningCard(inspection: inspection),

                const SizedBox(height: 8),

                // Sección: Observación
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Observaciones de Campo',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (!_isEditing)
                      IconButton.filledTonal(
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFEEF2F6),
                          foregroundColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
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
                            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: _saveObservationChanges,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: const Color(0xFF4F46E5),
                            ),
                            child: const Text('Guardar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                if (!_isEditing)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    ),
                    child: Text(
                      inspection.observation.isEmpty ? 'Sin observaciones detalladas.' : inspection.observation,
                      style: TextStyle(
                        fontSize: 15,
                        color: inspection.observation.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                        fontStyle: inspection.observation.isEmpty ? FontStyle.italic : FontStyle.normal,
                        height: 1.4,
                      ),
                    ),
                  )
                else
                  TextField(
                    controller: _observationController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Describe cualquier hallazgo o detalle...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      filled: true,
                      fillColor: Colors.white,
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
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year a las $hour:$minute';
  }
}
