// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InspectionModel _$InspectionModelFromJson(Map<String, dynamic> json) =>
    _InspectionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      photoPath: json['photoPath'] as String,
      observation: json['observation'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$InspectionModelToJson(_InspectionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'photoPath': instance.photoPath,
      'observation': instance.observation,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
    };
