import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_flutter/logic/cubits/inspection_cubit.dart';
import 'package:test_flutter/logic/cubits/sync_cubit.dart';
import 'package:test_flutter/presentation/widgets/app_snackbar.dart';
import 'package:test_flutter/presentation/widgets/connection_status_indicator.dart';
import 'package:test_flutter/presentation/widgets/inspection_card.dart';
import 'package:test_flutter/presentation/pages/create_inspection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<InspectionCubit>().loadInspections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inspecciones de Campo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: const [
          ConnectionStatusIndicator(),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SyncCubit, SyncState>(
            listener: (context, state) {
              if (state is Syncing) {
                AppSnackBar.showLoading(context, 'Sincronizando ${state.pendingCount} registro(s)...');
              } else if (state is SyncSuccess) {
                AppSnackBar.showSuccess(context, state.message);
              } else if (state is SyncFailed) {
                AppSnackBar.showError(context, state.error);
              }
            },
          ),
        ],
        child: BlocBuilder<InspectionCubit, InspectionState>(
          builder: (context, state) {
            if (state is InspectionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is InspectionError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<InspectionCubit>().loadInspections(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is InspectionLoaded) {
              final list = state.inspections;

              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 84, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay inspecciones',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Presiona el botón "+" para registrar una nueva inspección de campo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<InspectionCubit>().loadInspections();
                  await context.read<SyncCubit>().syncPendingQueue();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return InspectionCard(item: item);
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateInspectionPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Inspección'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
