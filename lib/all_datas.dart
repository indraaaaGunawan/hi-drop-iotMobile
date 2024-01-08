class AllData {
  final double temp;
  final double hum;
  final double ntu;
  final double ket_ntu;
  final double ts;

  AllData(
      {required this.temp,
      required this.hum,
      required this.ntu,
      required this.ts,
      required this.ket_ntu});

  factory AllData.fromJson(Map<String, dynamic> json) {
    return AllData(
      temp: double.parse(json['tempC'].toString()),
      hum: double.parse(json['hum'].toString()),
      ntu: double.parse(json['ntu'].toString()),
      ket_ntu: double.parse(json['ket_ntu'].toString()),
      ts: double.parse(json['ts'].toString()),
    );
  }
}
