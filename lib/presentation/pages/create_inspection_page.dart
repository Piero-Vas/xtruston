import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/inspection_model.dart';
import '../../logic/cubits/inspection_cubit.dart';
import '../../logic/cubits/sync_cubit.dart';
import '../widgets/camera_view.dart';

class CreateInspectionPage extends StatefulWidget {
  const CreateInspectionPage({super.key});

  @override
  State<CreateInspectionPage> createState() => _CreateInspectionPageState();
}

class _CreateInspectionPageState extends State<CreateInspectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _observationController = TextEditingController();

  final List<String> _categories = ['Seguridad', 'Mantenimiento', 'Limpieza'];
  String? _selectedCategory;
  String? _photoPath;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    final String? path = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const CameraView()),
    );

    if (path != null) {
      setState(() {
        _photoPath = path;
      });
    }
  }

  void _saveInspection() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_photoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Es obligatorio tomar una foto para registrar la inspección.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newInspection = InspectionModel(
      id: _uuid.v4(),
      name: _nameController.text.trim(),
      category: _selectedCategory!,
      photoPath: _photoPath!,
      observation: _observationController.text.trim(),
      status: 'pending', // Siempre inicia como pendiente de sincronización
      createdAt: DateTime.now(),
    );

    // Guardar en base de datos local y refrescar lista
    context.read<InspectionCubit>().addInspection(newInspection);
    
    // Disparar sincronización asíncrona de inmediato (se ejecutará si hay conexión)
    context.read<SyncCubit>().syncPendingQueue();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Inspección', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Entrada: Nombre del Lugar
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Lugar *',
                  hintText: 'Ej. Planta 1, Almacén A, etc.',
                  prefixIcon: const Icon(Icons.place_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el nombre del lugar.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Dropdown: Categoría
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Categoría *',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona una categoría.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Captura de Foto (Cámara Real)
              const Text(
                'Evidencia Fotográfica *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildPhotoPlaceholder(),
              const SizedBox(height: 24),

              // Entrada: Observaciones (Multilínea)
              TextFormField(
                controller: _observationController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Observación (Opcional)',
                  hintText: 'Describe cualquier hallazgo relevante...',
                  prefixIcon: const Icon(Icons.comment_outlined),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),

              // Botón de Guardar
              ElevatedButton.icon(
                onPressed: _saveInspection,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Registrar Inspección', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    if (_photoPath != null) {
      return Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.file(
                File(_photoPath!),
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.black.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _capturePhoto,
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    label: const Text(
                      'Cambiar Foto',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _capturePhoto,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text(
              'Tomar Foto en Vivo',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 4),
            Text(
              '(Cámara nativa integrada)',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
