abstract class ConnectivityServicePort {
  /// Stream que emite `true` cuando se detecta conexión activa a internet y `false` en caso offline.
  Stream<bool> get onConnectivityChanged;

  /// Retorna un booleano asíncrono indicando si hay conexión a internet activa en el instante.
  Future<bool> get isConnected;
}
