import 'dart:io';
import 'package:flutter/material.dart';

class PhotoPlaceholder extends StatelessWidget {
  final String? photoPath;
  final VoidCallback onTap;

  const PhotoPlaceholder({
    super.key,
    required this.photoPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (photoPath != null) {
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
                File(photoPath!),
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
                    onPressed: onTap,
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
      onTap: onTap,
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
