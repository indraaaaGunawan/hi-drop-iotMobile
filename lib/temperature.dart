import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:hi_drop/ratatemp.api.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:hi_drop/ratatemp.api.dart';
import 'package:hi_drop/makstemp.api.dart';
import 'package:hi_drop/mintemp.api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TemperaturePage extends StatefulWidget {
  const TemperaturePage({Key? key}) : super(key: key);

  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage>
    with SingleTickerProviderStateMixin {
  late MqttServerClient client;
  String temperature = 'N/A';
  late Ticker _ticker;
  late Future<List<Ratatemp>> _future;

  @override
  void initState() {
    super.initState();
    connectMQTT();
    _refresh();
    _ticker = createTicker(_tick);
    _ticker.start();
  }

  void _refresh() {
    _future = suhurataaaa.getPosts();
  }

  Duration _prev = Duration.zero;

  void _tick(Duration elapsed) {
    // check every 1 second
    if ((elapsed - _prev) >= Duration(seconds: 5)) {
      setState(() {
        // update the UI
        _refresh();
      });
      _prev = elapsed;
    }
  }

  void connectMQTT() async {
    client = MqttServerClient.withPort(
        'broker.hivemq.com', 'hidroponik monitoring', 1883);

    client.onDisconnected = onDisconnected;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(
            'hidroponik monitoring') // Ganti dengan identifier klien yang unik
        .keepAliveFor(60) // Tingkatkan jika diperlukan
        .startClean() // Hapus sesi sebelumnya
        .withWillTopic('willtopic') // Topik pesan akan
        .withWillMessage('Will message') // Pesan akan
        .authenticateAs('username',
            'password'); // Ganti dengan informasi otentikasi jika diperlukan;

    client.connectionMessage = connMess;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      print('Client connected');
      subscribeToTopic('kel4iot/suhu'); // Ganti dengan topik yang sesuai
    } else {
      print(
          'Client connection failed - disconnecting, state is ${client.connectionStatus?.state}');
      client.disconnect();
    }
  }

  void subscribeToTopic(String topic) {
    if (client != null &&
        client.connectionStatus?.state == MqttConnectionState.connected) {
      client.subscribe(topic, MqttQos.atMostOnce);
      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        if (c.isNotEmpty) {
          final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
          final String pt =
              MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          print('GOT A MESSAGE $pt');
          processMessage(pt);
        }
      });
      print('Subscribed to topic: $topic');
    } else {
      print('Client not connected');
    }
  }

  void processMessage(String message) {
    print('Menerima pesan MQTT: $message');

    this.temperature = message;

    setState(() {});
  }

  void onConnected() {
    print('Connected');
  }

  void onDisconnected() {
    print('Disconnected');
  }

  void onSubscribeFail(String topic) {
    print('Failed to subscribe to $topic');
  }

  final Suhurataaa suhurataaaa = Suhurataaa();
  final tempMin tempminn = tempMin();
  final tempMax tempmaks = tempMax();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 10, 143, 196),
      appBar: AppBar(
        title: Text(
          "Temperature",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Arial',
            fontSize: 25,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: RotatedBox(
              quarterTurns:
                  1, // Sesuaikan kebutuhan dengan perputaran yang diinginkan
              child: Icon(
                Icons.bar_chart_rounded,
                color: Colors.indigo,
                size: 28,
              ),
            ),
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 10, 143, 196),
        elevation: 0.0,
        toolbarHeight: 70,
      ),
      body: Container(
        child: ListView(
          children: [
            CircularPercentIndicator(
              radius: 100,
              lineWidth: 14,
              percent: 0.29,
              progressColor: Colors.indigo,
              center: const Text(
                '29\u00B0',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'TODAY',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 25),
              child: Column(
                children: [
                  Row(
                    children: [
                      Card(
                        elevation: 30,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: SizedBox(
                            height: 150,
                            width: 150,
                            child: ListView(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 15, left: 15),
                                  child: Text(
                                    "Rata-Rata",
                                    style: TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text(
                                    "Minggu ini",
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                FutureBuilder<List<Ratatemp>>(
                                  future: _future,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      // Access the data from the list of ratatemp objects
                                      List<Ratatemp> ratatempList =
                                          snapshot.data!;
                                      // Now you can use ratatempList to access its properties
                                      if (ratatempList.isNotEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30, left: 25),
                                          child: Text(
                                            '${ratatempList[0].rataTemp}%',
                                            style: TextStyle(
                                                fontSize: 30,
                                                color: Color.fromARGB(
                                                    255, 228, 158, 8)),
                                          ),
                                        );
                                      } else {
                                        return Text('No data available');
                                      }
                                    } else {
                                      // Return a default or fallback widget here
                                      return Text('No data available');
                                    }
                                  },
                                ),
                              ],
                            )),
                      ),
                      Padding(padding: EdgeInsets.only(left: 35)),
                      Card(
                        elevation: 30,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: SizedBox(
                          height: 150,
                          width: 150,
                          child: ListView(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, left: 15),
                                child: Text(
                                  "Temp",
                                  style: TextStyle(fontSize: 25),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  "Hari ini",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 30, left: 25),
                                child: Text(
                                  '$temperature %',
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.green[500]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(left: 30)),
                  Row(
                    children: [
                      Card(
                        elevation: 30,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: SizedBox(
                            height: 150,
                            width: 150,
                            child: ListView(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 15, left: 15),
                                  child: Text(
                                    "Max",
                                    style: TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text(
                                    "Bulan ini",
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                FutureBuilder<List<Makstemp>>(
                                  future: tempmaks.getPosts(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      // Access the data from the list of Suhumaks objects
                                      List<Makstemp> makstempksList =
                                          snapshot.data!;
                                      // Now you can use makstempksList to access its properties
                                      if (makstempksList.isNotEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30, left: 25),
                                          child: Text(
                                            '${makstempksList[0].maksTemp}°',
                                            style: TextStyle(
                                                fontSize: 30,
                                                color: Color.fromARGB(
                                                    255, 219, 9, 9)),
                                          ),
                                        );
                                      } else {
                                        return Text('No data available');
                                      }
                                    } else {
                                      // Return a default or fallback widget here
                                      return Text('No data available');
                                    }
                                  },
                                ),
                              ],
                            )),
                      ),
                      Padding(padding: EdgeInsets.only(left: 35)),
                      Card(
                        elevation: 30,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: SizedBox(
                            height: 150,
                            width: 150,
                            child: ListView(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 15, left: 15),
                                  child: Text(
                                    "Min",
                                    style: TextStyle(fontSize: 25),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text(
                                    "Bulan ini",
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                FutureBuilder<List<Mintemp>>(
                                  future: tempminn.getPosts(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      // Access the data from the list of Suhumaks objects
                                      List<Mintemp> mintempList =
                                          snapshot.data!;
                                      // Now you can use mintempList to access its properties
                                      if (mintempList.isNotEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30, left: 25),
                                          child: Text(
                                            '${mintempList[0].minTemp}°',
                                            style: TextStyle(
                                                fontSize: 30,
                                                color: Color.fromARGB(
                                                    255, 8, 12, 216)),
                                          ),
                                        );
                                      } else {
                                        return Text('No data available');
                                      }
                                    } else {
                                      // Return a default or fallback widget here
                                      return Text('No data available');
                                    }
                                  },
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    client.disconnect();
    _ticker.dispose();
    super.dispose();
  }
}

Widget buildDataWidget(context, snapshot) => Padding(
      padding: const EdgeInsets.only(top: 15, left: 55),
      child: Text(
        'Temperature: ${snapshot.data!.maksTemp.toStringAsFixed(2)}°',
        style: TextStyle(fontSize: 50, color: Colors.purple[400]),
      ),
    );

class Suhurataaa {
  static const String apiUrl =
      'https://kel4iot.000webhostapp.com/averageTemp.php';

  Future<List<Ratatemp>> getPosts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Ratatemp.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}

class tempMin {
  static const String apiUrl = 'https://kel4iot.000webhostapp.com/minTemp.php';

  Future<List<Mintemp>> getPosts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Mintemp.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}

class tempMax {
  static const String apiUrl = 'https://kel4iot.000webhostapp.com/maksTemp.php';

  Future<List<Makstemp>> getPosts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Makstemp.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
