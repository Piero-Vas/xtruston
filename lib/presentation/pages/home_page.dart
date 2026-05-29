import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:test_flutter/logic/cubits/inspection_cubit.dart';
import 'package:test_flutter/logic/cubits/sync_cubit.dart';
import 'package:test_flutter/domain/models/inspection_model.dart';
import 'package:test_flutter/presentation/widgets/app_snackbar.dart';
import 'package:test_flutter/presentation/widgets/connection_status_indicator.dart';
import 'package:test_flutter/presentation/widgets/inspection_card.dart';
import 'package:test_flutter/presentation/widgets/slide_fade_transition.dart';
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
      backgroundColor: const Color(0xFFF8FAFC), // Slate-50 fondo global
      appBar: AppBar(
        title: const Text(
          'Inspecciones de Campo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF0F172A),
          ),
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
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
                      const SizedBox(height: 12),
                      Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B))),
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
                        Lottie.network(
                          'https://assets10.lottiefiles.com/packages/lf20_yzn8y7az.json',
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEEF2F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.assignment_outlined, size: 64, color: Color(0xFF94A3B8)),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No hay inspecciones',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Presiona el botón inferior para registrar una nueva inspección de campo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600], height: 1.4),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Panel de Estadísticas (Dashboard Minimalista)
                    _buildDashboard(list),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Registros Recientes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          return SlideFadeTransition(
                            index: index,
                            child: InspectionCard(item: item),
                          );
                        },
                      ),
                    ),
                  ],
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
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva Inspección'),
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildDashboard(List<InspectionModel> list) {
    final total = list.length;
    final synced = list.where((i) => i.status == 'synced').length;
    final pending = list.where((i) => i.status == 'pending').length;
    final conflict = list.where((i) => i.status == 'conflict').length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Panel de Estado',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatCard('Total', total.toString(), const Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              _buildStatCard('Sincronizados', synced.toString(), const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _buildStatCard('Pendientes', (pending + conflict).toString(), const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
