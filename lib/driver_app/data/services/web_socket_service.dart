import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class Websocketservice {
  StompClient? _client;
  final String driverId;
  String? sessionId;
  final String wsUrl;
  final Function(Map<String, dynamic>) onLocationReceived;

  Websocketservice({
    required this.driverId,
    required this.wsUrl,
    required this.onLocationReceived,
  });

  void connect() {
    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        onWebSocketError: (dynamic error) {},
        onStompError: (StompFrame frame) {},
        onDisconnect: (StompFrame frame) {},
      ),
    );
    _client?.activate();
  }

  void sendLocation(double latitude, double longitude) {
    if (_client != null && _client!.isActive && sessionId != null) {
      //if (_client != null && _client!.isActive) {
      _client!.send(
        destination: '/app/tracking/driver/$driverId/send',
        headers: {'token': sessionId!},
        body: jsonEncode({
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        }),
      );
      if (kDebugMode) {
        print('Enviando ubicación al back: $latitude, $longitude');
      }
    }
    if (kDebugMode) {
      print('No se esta Enviando ubicación al back: $latitude, $longitude');
    }
  }

  void disconnect() {
    _client?.deactivate();
  }
}
