import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_flutter/logic/cubits/create_inspection_form_cubit.dart';
import 'package:test_flutter/logic/cubits/inspection_cubit.dart';
import 'package:test_flutter/logic/cubits/sync_cubit.dart';
import 'package:test_flutter/presentation/widgets/app_snackbar.dart';
import 'package:test_flutter/presentation/widgets/camera_view.dart';
import 'package:test_flutter/presentation/widgets/photo_placeholder.dart';

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

  void _saveInspection(BuildContext context) {
    // Validar visualmente campos locales del formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Despachar la lógica al Cubit del Formulario
    context.read<CreateInspectionFormCubit>().submit(
          name: _nameController.text,
          category: _selectedCategory,
          photoPath: _photoPath,
          observation: _observationController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateInspectionFormCubit(
        inspectionCubit: context.read<InspectionCubit>(),
        syncCubit: context.read<SyncCubit>(),
      ),
      child: BlocConsumer<CreateInspectionFormCubit, CreateInspectionFormState>(
        listener: (context, state) {
          if (state is CreateInspectionFormSuccess) {
            Navigator.pop(context);
          } else if (state is CreateInspectionFormError) {
            AppSnackBar.showError(context, state.error);
          }
        },
        builder: (context, state) {
          final isSubmitting = state is CreateInspectionFormSubmitting;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Nueva Inspección', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            body: isSubmitting
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Guardando inspección...', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : SingleChildScrollView(
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
                          PhotoPlaceholder(
                            photoPath: _photoPath,
                            onTap: _capturePhoto,
                          ),
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
                            onPressed: () => _saveInspection(context),
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
        },
      ),
    );
  }
}
