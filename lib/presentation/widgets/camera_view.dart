import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _isInitializing = true;
  bool _isTakingPicture = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No se encontraron cámaras en el dispositivo.';
          _isInitializing = false;
        });
        return;
      }

      // Usamos la cámara trasera por defecto
      final backCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium, // Calidad media para no generar archivos masivos
        enableAudio: false, // Desactivamos el micrófono para no pedir permisos de audio innecesarios
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al inicializar la cámara: $e';
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // Si el estado de la app cambia, pausamos o re-inicializamos el controlador para liberar recursos
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  /// Comprime y redimensiona la imagen usando APIs de dibujo nativas de Flutter.
  /// Reduce el ancho a un máximo de 1080px (manteniendo el aspecto) y guarda como PNG.
  Future<String> _compressAndResizePhoto(String originalPath) async {
    final file = File(originalPath);
    final bytes = await file.readAsBytes();

    // Decodificar la imagen a un codec gráfico nativo de Flutter
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 1080, // Ancho máximo
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image resizedImage = frameInfo.image;

    // Convertir de nuevo a bytes
    final byteData = await resizedImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return originalPath;

    final uint8List = byteData.buffer.asUint8List();

    // Guardar en directorio temporal
    final tempDir = await getTemporaryDirectory();
    final newPath = '${tempDir.path}/comp_${DateTime.now().millisecondsSinceEpoch}.png';
    final compressedFile = File(newPath);
    await compressedFile.writeAsBytes(uint8List);

    // Intentamos eliminar la imagen original para evitar basura en el storage
    try {
      await file.delete();
    } catch (_) {}

    return newPath;
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isTakingPicture) {
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      final XFile rawPhoto = await _controller!.takePicture();
      
      // Aplicamos compresión asíncrona antes de retornar
      final String compressedPath = await _compressAndResizePhoto(rawPhoto.path);

      if (mounted) {
        Navigator.pop(context, compressedPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al tomar foto: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Cabecera superior
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cámara de Inspección',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Área de previsualización
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[900],
                  child: _buildCameraPreview(size),
                ),
              ),
            ),

            // Controles inferiores
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isInitializing && _errorMessage == null)
                    GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        height: 84,
                        width: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Center(
                          child: _isTakingPicture
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Container(
                                  height: 68,
                                  width: 68,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(Size size) {
    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.deepPurpleAccent),
            SizedBox(height: 16),
            Text('Inicializando cámara real...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _errorMessage = null;
                  });
                  _initializeCamera();
                },
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: Text('Cámara no disponible', style: TextStyle(color: Colors.white70)),
      );
    }

    // Centramos y recortamos el preview para llenar el contenedor
    final cameraValue = _controller!.value;
    final scale = size.aspectRatio * cameraValue.aspectRatio;

    return ClipRect(
      child: Transform.scale(
        scale: scale < 1.0 ? 1.0 / scale : scale,
        child: Center(
          child: CameraPreview(_controller!),
        ),
      ),
    );
  }
}
