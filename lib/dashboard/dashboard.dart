import 'dart:async'; // Para usar StreamController
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:myapp/dashboard/widgets/sensor_chart.dart';

const topicPrefix = 'Flutter_Malaga';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  MqttServerClient? client;

  // StreamControllers para cada tipo de dato
  final StreamController<List<FlSpot>> temperatureStreamController =
      StreamController<List<FlSpot>>.broadcast();
  final StreamController<List<FlSpot>> humidityStreamController =
      StreamController<List<FlSpot>>.broadcast();
  final StreamController<List<FlSpot>> pressureStreamController =
      StreamController<List<FlSpot>>.broadcast();

  List<FlSpot> temperatureData = [];
  List<FlSpot> humidityData = [];
  List<FlSpot> pressureData = [];

  @override
  void initState() {
    super.initState();
    _connectToMqtt();
  }

  Future<void> _connectToMqtt() async {
    client = MqttServerClient('test.mosquitto.org', '');
    client?.logging(on: true);
    client?.onConnected = _onConnected;
    client?.onDisconnected = _onDisconnected;
    client?.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client?.connectionMessage = connMessage;

    try {
      await client?.connect();
    } catch (e) {
      print('Exception: $e');
      client?.disconnect();
    }
  }

  void _onConnected() {
    print('Connected');
    client?.subscribe('$topicPrefix/temperature', MqttQos.atLeastOnce);
    client?.subscribe('$topicPrefix/humidity', MqttQos.atLeastOnce);
    client?.subscribe('$topicPrefix/pressure', MqttQos.atLeastOnce);

    client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );
      final topic = c[0].topic;

      setState(() {
        final data = FlSpot(
          DateTime.now().millisecondsSinceEpoch.toDouble(),
          double.parse(pt),
        );
        if (topic == '$topicPrefix/temperature') {
          temperatureData.add(data);
          temperatureStreamController.sink.add(
            temperatureData,
          ); // Emitir los datos actualizados
        } else if (topic == '$topicPrefix/humidity') {
          humidityData.add(data);
          humidityStreamController.sink.add(
            humidityData,
          ); // Emitir los datos actualizados
        } else if (topic == '$topicPrefix/pressure') {
          pressureData.add(data);
          pressureStreamController.sink.add(
            pressureData,
          ); // Emitir los datos actualizados
        }
      });
    });
  }

  void _onDisconnected() {
    print('Disconnected');
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('IoT Dashboard')),
      body: Column(
        children: [
          Expanded(
            child: SensorChart.barChart(
              dataStream: temperatureStreamController.stream, // Usar el Stream
              title: 'Temperature',
              yAxisTitle: '°C',
              lineColor: Colors.red,
            ),
          ),
          Expanded(
            child: SensorChart.lineChart(
              dataStream: humidityStreamController.stream, // Usar el Stream
              title: 'Humidity',
              yAxisTitle: '%',
              lineColor: Colors.blue,
            ),
          ),
          Expanded(
            child: SensorChart.lineChart(
              dataStream: pressureStreamController.stream, // Usar el Stream
              title: 'Pressure',
              yAxisTitle: 'hPa',
              lineColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Asegurarse de cerrar los StreamControllers al salir del widget
    temperatureStreamController.close();
    humidityStreamController.close();
    pressureStreamController.close();
    super.dispose();
  }
}
