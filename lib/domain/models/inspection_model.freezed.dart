// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InspectionModel {

 String get id; String get name; String get category; String get photoPath; String get observation; String get status; DateTime get createdAt;
/// Create a copy of InspectionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionModelCopyWith<InspectionModel> get copyWith => _$InspectionModelCopyWithImpl<InspectionModel>(this as InspectionModel, _$identity);

  /// Serializes this InspectionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.observation, observation) || other.observation == observation)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,photoPath,observation,status,createdAt);

@override
String toString() {
  return 'InspectionModel(id: $id, name: $name, category: $category, photoPath: $photoPath, observation: $observation, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $InspectionModelCopyWith<$Res>  {
  factory $InspectionModelCopyWith(InspectionModel value, $Res Function(InspectionModel) _then) = _$InspectionModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String category, String photoPath, String observation, String status, DateTime createdAt
});




}
/// @nodoc
class _$InspectionModelCopyWithImpl<$Res>
    implements $InspectionModelCopyWith<$Res> {
  _$InspectionModelCopyWithImpl(this._self, this._then);

  final InspectionModel _self;
  final $Res Function(InspectionModel) _then;

/// Create a copy of InspectionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? category = null,Object? photoPath = null,Object? observation = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,photoPath: null == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String,observation: null == observation ? _self.observation : observation // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InspectionModel].
extension InspectionModelPatterns on InspectionModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectionModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectionModel value)  $default,){
final _that = this;
switch (_that) {
case _InspectionModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectionModel value)?  $default,){
final _that = this;
switch (_that) {
case _InspectionModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String category,  String photoPath,  String observation,  String status,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectionModel() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.photoPath,_that.observation,_that.status,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String category,  String photoPath,  String observation,  String status,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _InspectionModel():
return $default(_that.id,_that.name,_that.category,_that.photoPath,_that.observation,_that.status,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String category,  String photoPath,  String observation,  String status,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InspectionModel() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.photoPath,_that.observation,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InspectionModel extends InspectionModel {
  const _InspectionModel({required this.id, required this.name, required this.category, required this.photoPath, required this.observation, required this.status, required this.createdAt}): super._();
  factory _InspectionModel.fromJson(Map<String, dynamic> json) => _$InspectionModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String category;
@override final  String photoPath;
@override final  String observation;
@override final  String status;
@override final  DateTime createdAt;

/// Create a copy of InspectionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionModelCopyWith<_InspectionModel> get copyWith => __$InspectionModelCopyWithImpl<_InspectionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.observation, observation) || other.observation == observation)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,photoPath,observation,status,createdAt);

@override
String toString() {
  return 'InspectionModel(id: $id, name: $name, category: $category, photoPath: $photoPath, observation: $observation, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InspectionModelCopyWith<$Res> implements $InspectionModelCopyWith<$Res> {
  factory _$InspectionModelCopyWith(_InspectionModel value, $Res Function(_InspectionModel) _then) = __$InspectionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String category, String photoPath, String observation, String status, DateTime createdAt
});




}
/// @nodoc
class __$InspectionModelCopyWithImpl<$Res>
    implements _$InspectionModelCopyWith<$Res> {
  __$InspectionModelCopyWithImpl(this._self, this._then);

  final _InspectionModel _self;
  final $Res Function(_InspectionModel) _then;

/// Create a copy of InspectionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? category = null,Object? photoPath = null,Object? observation = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_InspectionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,photoPath: null == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String,observation: null == observation ? _self.observation : observation // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
