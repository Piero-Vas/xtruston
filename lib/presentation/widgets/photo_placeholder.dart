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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        elevation: 0,
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    label: const Text(
                      'Cambiar Evidencia',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
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
          color: const Color(0xFFF8FAFC), // Slate-50
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5, style: BorderStyle.solid), // Slate-300
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2F6), // Indigo-50 / Slate-100
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 32,
                color: Color(0xFF4F46E5), // Indigo-600
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Tomar Foto en Vivo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A), // Slate-900
                fontSize: 15,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'La imagen se comprimirá automáticamente',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B), // Slate-500
              ),
            ),
          ],
        ),
      ),
    );
  }
}
