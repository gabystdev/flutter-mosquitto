import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String broker = 'test.mosquitto.org';
  final int port = 1883;
  final String clientId = 'flutter_client';

  late MqttServerClient client;
  String status = 'Desconectado';

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    client = MqttServerClient(broker, clientId);
    client.port = port;
    client.logging(on: true);
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      setState(() => status = 'Error al conectar: $e');
      client.disconnect();
    }
  }

  void _onConnected() {
    setState(() => status = 'Conectado a $broker');
  }

  void _onDisconnected() {
    setState(() => status = 'Desconectado');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('MQTT Flutter')),
        body: Center(child: Text(status)),
      ),
    );
  }
}
