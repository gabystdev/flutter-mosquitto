import 'dart:async';
import 'dart:math';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() async {
  final client = MqttServerClient('test.mosquitto.org', '');
  client.logging(on: true);

  final connMessage = MqttConnectMessage()
      .withClientIdentifier('dart_simulator')
      .startClean()
      .withWillQos(MqttQos.atLeastOnce);
  client.connectionMessage = connMessage;

  try {
    await client.connect();
  } catch (e) {
    print('Exception: $e');
    client.disconnect();
  }

  if (client.connectionStatus?.state == MqttConnectionState.connected) {
    print('Connected');
    const topicPrefix = 'Flutter_Malaga';
    [
      SensorSimulator(
        topic: '$topicPrefix/temperature',
        client: client,
        randomRange: (20, 15),
      ),
      SensorSimulator(
        topic: '$topicPrefix/humidity',
        client: client,
        randomRange: (30, 80),
      ),
      SensorSimulator(
        topic: '$topicPrefix/pressure',
        client: client,
        randomRange: (950, 100),
      ),
    ].forEach((simulator) => simulator.start());
  } else {
    print('Connection failed');
    client.disconnect();
  }
}

class SensorSimulator {
  SensorSimulator({
    required this.topic,
    required this.client,
    required this.randomRange,
  });

  final String topic;
  final MqttServerClient client;
  final (int, int) randomRange;

  void start() {
    final rand = Random();
    Timer.periodic(Duration(seconds: rand.nextInt(3) + rand.nextInt(6)), (
      timer,
    ) {
      final payloadBuilder = MqttClientPayloadBuilder();
      final value = randomRange.$1 + rand.nextInt(randomRange.$2);
      if (payloadBuilder case MqttClientPayloadBuilder(:final payload?)) {
        payloadBuilder.addString('$value');
        client.publishMessage(topic, MqttQos.atLeastOnce, payload);
      }
    });
  }
}
