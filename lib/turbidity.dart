import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hi_drop/minntu.api.dart';
import 'package:hi_drop/maxntu.api.dart';
import 'package:hi_drop/ratantu.api.dart';
import 'package:hi_drop/rataketntu.api.dart';
import 'package:hi_drop/minketntu.api.dart';
import 'package:hi_drop/maxketntu.api.dart';

class TurbidityPage extends StatefulWidget {
  const TurbidityPage({Key? key}) : super(key: key);

  @override
  _TurbidityPageState createState() => _TurbidityPageState();
}

class _TurbidityPageState extends State<TurbidityPage> {
  // Future<Suhumaks?>? Suhumakss;
  late MqttServerClient client;
  String turbidity = 'N/A';
  String ket_turbidity = 'N/A';

  @override
  void initState() {
    super.initState();
    connectMQTT();
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
      subscribeToTopic(
          'kel4iot/ntu', 'kel4iot/kntu'); // Ganti dengan topik yang sesuai
    } else {
      print(
          'Client connection failed - disconnecting, state is ${client.connectionStatus?.state}');
      client.disconnect();
    }
  }

  void subscribeToTopic(String topic, String topic2) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      client.subscribe(topic, MqttQos.atMostOnce);
      client.subscribe(topic2, MqttQos.atMostOnce);
      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        if (c.isNotEmpty) {
          final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
          // get the topic
          final String topic = c[0].topic;
          print("topic $topic");
          final String pt =
              MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          print('GOT A MESSAGE $pt');
          if (topic == 'kel4iot/ntu') {
            setState(() {
              this.turbidity = pt;
            });
          } else {
            setState(() {
              this.ket_turbidity = pt;
            });
          }
        }
      });
      print('Subscribed to topic: $topic');
    } else {
      print('Client not connected');
    }
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

  final Nturataaa nturataaaa = Nturataaa();
  final Ntumin ntumiiin = Ntumin();
  final Ntumax ntumaaax = Ntumax();

  //keterangan nilai turbidity
  final Ketnturataaa ketnturataa = Ketnturataaa();
  final Ketntumin ketntumiiin = Ketntumin();
  final Ketntumax ketntumaaax = Ketntumax();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 10, 143, 196),
      appBar: AppBar(
        title: Text(
          "Turbudity",
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
              percent: 0.35,
              progressColor: const Color.fromARGB(255, 18, 43, 185),
              center: const Text(
                '2.35\Ntu',
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
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(234, 0, 0, 0)),
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
                                  "NTU",
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
                                  '$turbidity',
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.green[500]),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                  "Ket NTU",
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
                                  '$ket_turbidity',
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
                  Padding(padding: EdgeInsets.only(top: 35)),
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
                                    "AVG-NTU",
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
                                FutureBuilder<List<Ratantu>>(
                                  future: nturataaaa.getPosts(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      // Access the data from the list of ratantu objects
                                      List<Ratantu> ratantuList =
                                          snapshot.data!;
                                      // Now you can use ratantuList to access its properties
                                      if (ratantuList.isNotEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30, left: 25),
                                          child: Text(
                                            '${ratantuList[0].rataNtu}',
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
                                    "AVG-Ket-NTU",
                                    style: TextStyle(
                                      fontSize: 20,
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
                                FutureBuilder<List<Rataketntu>>(
                                  future: ketnturataa.getPosts(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      // Access the data from the list of ratantu objects
                                      List<Rataketntu> ratantuList =
                                          snapshot.data!;
                                      // Now you can use ratantuList to access its properties
                                      if (ratantuList.isNotEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30, left: 25),
                                          child: Text(
                                            '${ratantuList[0].rataKetNtu}',
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
                  Padding(padding: EdgeInsets.only(left: 35)),
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
                                    "Max NTU",
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
                                FutureBuilder<List<Maksntu>>(
                                  future: ntumaaax.getPosts(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      // Access the data from the list of Suhumaks objects
                                      List<Maksntu> maxketntusList =
                                          snapshot.data!;
                                      // Now you can use maxketntusList to access its properties
                                      if (maxketntusList.isNotEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30, left: 25),
                                          child: Text(
                                            '${maxketntusList[0].maksNtu}',
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
                                    "Min NTU",
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
                                FutureBuilder<List<Minntu>>(
                                  future: ntumiiin.getPosts(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      // Access the data from the list of Suhumaks objects
                                      List<Minntu> minketntuList =
                                          snapshot.data!;
                                      // Now you can use minketntuList to access its properties
                                      if (minketntuList.isNotEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30, left: 25),
                                          child: Text(
                                            '${minketntuList[0].minNtu}',
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
                  Padding(padding: EdgeInsets.only(left: 35)),
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
                                    "Max K- NTU",
                                    style: TextStyle(
                                      fontSize: 20,
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
                                FutureBuilder<List<Maksketntu>>(
                                  future: ketntumaaax.getPosts(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      // Access the data from the list of Suhumaks objects
                                      List<Maksketntu> maxketntusList =
                                          snapshot.data!;
                                      // Now you can use maxketntusList to access its properties
                                      if (maxketntusList.isNotEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30, left: 25),
                                          child: Text(
                                            '${maxketntusList[0].maksKetNtu}',
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
                                    "Min K-NTU",
                                    style: TextStyle(fontSize: 20),
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
                                FutureBuilder<List<Minketntu>>(
                                  future: ketntumiiin.getPosts(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      // Access the data from the list of Suhumaks objects
                                      List<Minketntu> minketntuList =
                                          snapshot.data!;
                                      // Now you can use minketntuList to access its properties
                                      if (minketntuList.isNotEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30, left: 25),
                                          child: Text(
                                            '${minketntuList[0].minKetNtu}',
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
    super.dispose();
  }
}

Widget buildDataWidget(context, snapshot) => Padding(
      padding: const EdgeInsets.only(top: 15, left: 55),
      child: Text(
        'Temperature: ${snapshot.data!.maksNtu.toStringAsFixed(2)}°',
        style: TextStyle(fontSize: 50, color: Colors.purple[400]),
      ),
    );

class Nturataaa {
  static const String apiUrl =
      'https://kel4iot.000webhostapp.com/averageNtu.php';

  Future<List<Ratantu>> getPosts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Ratantu.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}

class Ntumin {
  static const String apiUrl = 'https://kel4iot.000webhostapp.com/minNtu.php';

  Future<List<Minntu>> getPosts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Minntu.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}

class Ntumax {
  static const String apiUrl = 'https://kel4iot.000webhostapp.com/maksNtu.php';

  Future<List<Maksntu>> getPosts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Maksntu.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}

class Ketnturataaa {
  static const String apiUrl =
      'https://kel4iot.000webhostapp.com/averageKetNtu.php';

  Future<List<Rataketntu>> getPosts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Rataketntu.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}

class Ketntumin {
  static const String apiUrl =
      'https://kel4iot.000webhostapp.com/minKetNtu.php';

  Future<List<Minketntu>> getPosts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Minketntu.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}

class Ketntumax {
  static const String apiUrl =
      'https://kel4iot.000webhostapp.com/maksKetNtu.php';

  Future<List<Maksketntu>> getPosts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Maksketntu.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
