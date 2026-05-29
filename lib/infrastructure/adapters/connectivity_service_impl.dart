import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:test_flutter/domain/ports/connectivity_service_port.dart';

class ConnectivityServiceImpl implements ConnectivityServicePort {
  final Connectivity _connectivity;

  ConnectivityServiceImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((result) {
      return _hasConnection(result);
    });
  }

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  /// Helper dinámico para soportar tanto List  (v5+) como ConnectivityResult (v4)
  bool _hasConnection(dynamic result) {
    if (result is List) {
      if (result.isEmpty) return false;
      return result.any((r) => r != ConnectivityResult.none);
    }
    return result != ConnectivityResult.none;
  }
}
