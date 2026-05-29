import 'dart:io';
import 'package:flutter/material.dart';
import 'package:test_flutter/domain/models/inspection_model.dart';
import 'package:test_flutter/presentation/pages/inspection_detail_page.dart';
import 'package:test_flutter/presentation/widgets/sync_status_badge.dart';

class InspectionCard extends StatelessWidget {
  final InspectionModel item;

  const InspectionCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 0, // Plano
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InspectionDetailPage(inspectionId: item.id),
            ),
          );
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Miniatura de la foto con padding interno y bordes redondeados (estética de marco fotográfico)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Hero(
                  tag: 'photo_${item.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.file(
                        File(item.photoPath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.broken_image_outlined, color: Color(0xFF94A3B8)),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Datos del registro
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              color: Color(0xFF0F172A), // Slate-900
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.category,
                            style: const TextStyle(
                              color: Color(0xFF64748B), // Slate-500
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Fecha formateada sutilmente
                      Text(
                        _formatDate(item.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8), // Slate-400
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Indicador de estado de sincronización a la derecha
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: SyncStatusBadge(status: item.status),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
