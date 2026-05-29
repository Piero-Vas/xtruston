import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'domain/ports/api_service_port.dart';
import 'domain/ports/connectivity_service_port.dart';
import 'domain/ports/inspection_repository_port.dart';
import 'infrastructure/adapters/connectivity_service_impl.dart';
import 'infrastructure/adapters/hive_inspection_repository.dart';
import 'infrastructure/adapters/http_api_service.dart';
import 'logic/cubits/inspection_cubit.dart';
import 'logic/cubits/sync_cubit.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive para Flutter
  await Hive.initFlutter();

  // Inicializar el adaptador de repositorio abriendo la caja local
  final HiveInspectionRepository inspectionRepository = await HiveInspectionRepository.init();

  // Crear instancias de los adaptadores concretos
  final ApiServicePort apiService = HttpApiService();
  final ConnectivityServicePort connectivityService = ConnectivityServiceImpl();

  runApp(
    MyApp(
      inspectionRepository: inspectionRepository,
      apiService: apiService,
      connectivityService: connectivityService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final InspectionRepositoryPort inspectionRepository;
  final ApiServicePort apiService;
  final ConnectivityServicePort connectivityService;

  const MyApp({
    super.key,
    required this.inspectionRepository,
    required this.apiService,
    required this.connectivityService,
  });

  @override
  Widget build(BuildContext context) {
    // Inyectamos las dependencias globales en el árbol de widgets
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: inspectionRepository),
        RepositoryProvider.value(value: apiService),
        RepositoryProvider.value(value: connectivityService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<InspectionCubit>(
            create: (context) => InspectionCubit(inspectionRepository),
          ),
          BlocProvider<SyncCubit>(
            create: (context) => SyncCubit(
              inspectionRepository,
              apiService,
              connectivityService,
              context.read<InspectionCubit>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Inspecciones Offline-First',
          debugShowCheckedModeBanner: false,
          
          // --- SISTEMA DE DISEÑO PREMIUM (Material 3) ---
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6750A4), // Púrpura elegante como semilla
              primary: const Color(0xFF6750A4),
              onPrimary: Colors.white,
              secondary: const Color(0xFF625B71),
              surface: const Color(0xFFFEF7FF), // 'surface' reemplaza a 'background' en Flutter 3.18+
              error: const Color(0xFFB3261E),
            ),
            
            // Tipografía moderna y limpia
            fontFamily: 'Roboto',
            
            // Estilo global de la AppBar
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFFEF7FF),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              iconTheme: IconThemeData(color: Color(0xFF1D1B20)),
            ),
            
            cardTheme: const CardThemeData(
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
              elevation: 2,
            ),
            
            // Estilo global para los campos de texto
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF7F2FA),
              labelStyle: const TextStyle(color: Color(0xFF49454F)),
              floatingLabelStyle: const TextStyle(color: Color(0xFF6750A4), fontWeight: FontWeight.bold),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF79747E)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF79747E)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6750A4), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFB3261E)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFB3261E), width: 2),
              ),
            ),
            
            // Estilo de botones elevados
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          
          // Pantalla Principal
          home: const HomePage(),
        ),
      ),
    );
  }
}
