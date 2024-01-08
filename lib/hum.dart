import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:hi_drop/ratatemp.api.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:http/http.dart' as http;
import 'package:hi_drop/makshum.dart';
import 'package:hi_drop/minhum.dart';
import 'package:hi_drop/ratahum.dart';
import 'package:hi_drop/lineCharttemp.dart';
import 'package:hi_drop/chart_temp.dart';
import 'dart:convert';

class Charttemp extends StatefulWidget {
  const Charttemp({super.key});

  @override
  State<Charttemp> createState() => _CharttempState();
}

class _CharttempState extends State<Charttemp>
    with SingleTickerProviderStateMixin {
  late MqttServerClient client;
  String humidity = 'N/A';
  late Ticker _ticker;
  late Future<List<Ratahum>> _future;

  @override
  void initState() {
    super.initState();
    connectMQTT();
    _refresh();
    _ticker = createTicker(_tick);
    _ticker.start();
  }

  void _refresh() {
    _future = humrataaa.getPosts();
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
      subscribeToTopic('kel4iot/humi'); // Ganti dengan topik yang sesuai
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

    this.humidity = message;

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

  final Hummakssss hummakss = Hummakssss();
  final Humminnn humminn = Humminnn();
  final Humrataaa humrataaa = Humrataaa();

  @override
  Widget build(BuildContext context) {
    // client.subscribe('hidroponik monitoring', MqttQos.atLeastOnce); // Subscribe to the weather updates topic
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 10, 143, 196),
      appBar: AppBar(
        title: Text(
          "Humidity",
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
        padding: EdgeInsets.only(left: 20, right: 20),
        child: ListView(
          children: [
            // Card(
            //   elevation: 30,
            //   shadowColor: Color.fromARGB(255, 192, 9, 9),
            //   shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(25.0)),
            //   child: Column(
            //     children: [
            //       SizedBox(
            //         height: 200,
            //         child: Row(
            //           children: [
            //             Container(
            //                 // color: Colors.black,
            //                 margin: EdgeInsets.only(left: 5),
            //                 child: RotatedBox(
            //                     quarterTurns:
            //                         -1, // Mengatur jumlah putaran (90 derajat)
            //                     child: Text(
            //                       '% Kelembapan',
            //                       style: TextStyle(fontSize: 15),
            //                     ))),
            //             Container(
            //               // color: Colors.black,
            //               child: SizedBox(
            //                 height: 200,
            //                 width: 318,
            //                 child: LineChartWidget(suhuChart),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //       Container(
            //           // color: Colors.black,
            //           margin: EdgeInsets.only(bottom: 5),
            //           child: Text(
            //             'Waktu',
            //             style: TextStyle(fontSize: 15),
            //           )),
            //     ],
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
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
                                    "Humidity",
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
                                    '$humidity %',
                                    style: TextStyle(
                                        fontSize: 30, color: Colors.green[500]),
                                  ),
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
                                FutureBuilder<List<Ratahum>>(
                                  future: _future,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      // Access the data from the list of Ratamaks objects
                                      List<Ratahum> ratamaksList =
                                          snapshot.data!;
                                      // Now you can use ratamaksList to access its properties
                                      if (ratamaksList.isNotEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30, left: 25),
                                          child: Text(
                                            '${ratamaksList[0].rataHum}%',
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
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(top: 30)),
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
                                FutureBuilder<List<Minhum>>(
                                  future: humminn.getPosts(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      // Access the data from the list of Suhumaks objects
                                      List<Minhum> minhumList = snapshot.data!;
                                      // Now you can use minhumList to access its properties
                                      if (minhumList.isNotEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30, left: 25),
                                          child: Text(
                                            '${minhumList[0].minHum}°',
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
                                FutureBuilder<List<Makshum>>(
                                  future: hummakss.getPosts(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      // Access the data from the list of Suhumaks objects
                                      List<Makshum> suhumaksList =
                                          snapshot.data!;
                                      // Now you can use suhumaksList to access its properties
                                      if (suhumaksList.isNotEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30, left: 25),
                                          child: Text(
                                            '${suhumaksList[0].maksHum}°',
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
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
    _ticker.dispose();
    super.dispose();
  }
}

Widget buildDataWidget(context, snapshot) => Padding(
      padding: const EdgeInsets.only(top: 15, left: 55),
      child: Text(
        'Humidity: ${snapshot.data!.maksHum.toStringAsFixed(2)}°',
        style: TextStyle(fontSize: 50, color: Colors.purple[400]),
      ),
    );

class Hummakssss {
  static const String apiUrl = 'https://kel4iot.000webhostapp.com/maksHum.php';

  Future<List<Makshum>> getPosts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Makshum.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}

class Humminnn {
  static const String apiUrl = 'https://kel4iot.000webhostapp.com/minHum.php';

  Future<List<Minhum>> getPosts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Minhum.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}

class Humrataaa {
  static const String apiUrl =
      'https://kel4iot.000webhostapp.com/averageHum.php';

  Future<List<Ratahum>> getPosts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Ratahum.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
