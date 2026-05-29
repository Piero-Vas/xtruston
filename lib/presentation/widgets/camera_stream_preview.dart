import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/presentation/widgets/camera_error_view.dart';

class CameraStreamPreview extends StatelessWidget {
  final bool isInitializing;
  final String? errorMessage;
  final CameraController? controller;
  final VoidCallback onRetry;

  const CameraStreamPreview({
    super.key,
    required this.isInitializing,
    required this.errorMessage,
    required this.controller,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isInitializing) {
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

    if (errorMessage != null) {
      return CameraErrorView(
        errorMessage: errorMessage!,
        onRetry: onRetry,
      );
    }

    if (controller == null || !controller!.value.isInitialized) {
      return const Center(
        child: Text('Cámara no disponible', style: TextStyle(color: Colors.white70)),
      );
    }

    final size = MediaQuery.of(context).size;
    final cameraValue = controller!.value;
    final scale = size.aspectRatio * cameraValue.aspectRatio;

    return ClipRect(
      child: Transform.scale(
        scale: scale < 1.0 ? 1.0 / scale : scale,
        child: Center(
          child: CameraPreview(controller!),
        ),
      ),
    );
  }
}
