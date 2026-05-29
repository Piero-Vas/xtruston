import 'package:hive/hive.dart';
import 'package:test_flutter/domain/models/inspection_model.dart';
import 'package:test_flutter/domain/ports/inspection_repository_port.dart';

class HiveInspectionRepository implements InspectionRepositoryPort {
  static const String _boxName = 'inspections_box';
  final Box _box;

  HiveInspectionRepository(this._box);

  /// Abre la caja de Hive y retorna una instancia del adaptador.
  static Future<HiveInspectionRepository> init() async {
    final box = await Hive.openBox(_boxName);
    return HiveInspectionRepository(box);
  }

  @override
  List<InspectionModel> getAllInspections() {
    return _box.values.map((item) {
      final map = Map<dynamic, dynamic>.from(item as Map);
      return InspectionModel.fromMap(map);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> saveInspection(InspectionModel inspection) async {
    await _box.put(inspection.id, inspection.toMap());
  }

  @override
  Future<InspectionModel?> getInspection(String id) async {
    final data = _box.get(id);
    if (data == null) return null;
    final map = Map<dynamic, dynamic>.from(data as Map);
    return InspectionModel.fromMap(map);
  }

  @override
  Future<void> deleteInspection(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
  }
}
