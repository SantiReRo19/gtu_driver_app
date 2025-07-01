import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class Websocketservice {
  StompClient? _client;
  final String driverId;
  String? sessionId;
  final String wsUrl;
  final Function(Map<String, dynamic>) onLocationReceived;
  final VoidCallback? onConnect;

  Websocketservice({
    required this.driverId,
    required this.wsUrl,
    required this.onLocationReceived,
    this.onConnect,
  });

  void connect() {
    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (frame) {
          if (kDebugMode) print('WebSocket conectado');
          if (onConnect != null) onConnect!();
        },
        onWebSocketError: (dynamic error) {
          if (kDebugMode) {
            print('WebSocket error: $error');
          }
        },
        onStompError: (StompFrame frame) {
          if (kDebugMode) {
            print('STOMP error: ${frame.body}');
          }
        },
        onDisconnect: (StompFrame frame) {
          if (kDebugMode) {
            print('Disconnected from WebSocket');
          }
        },
      ),
    );
    _client?.activate();
  }

  void sendLocation(double latitude, double longitude) {
    try {
      if (_client != null && _client!.isActive && sessionId != null) {
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
    } catch (e, st) {
      if (kDebugMode) print('Error en sendLocation: $e\n$st');
    }
  }

  void disconnect() {
    _client?.deactivate();
  }

   get client => _client;
}
