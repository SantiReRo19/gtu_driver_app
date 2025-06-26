import 'dart:convert';
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
      _client!.send(
        destination: '/app/tracking/driver/$driverId/send',
        headers: {'token': sessionId!},
        body: jsonEncode({
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        }),
      );
    }
  }

  void disconnect() {
    _client?.deactivate();
  }
}
