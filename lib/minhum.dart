class Minhum {
  final String minHum;

  Minhum({
    required this.minHum,
  });

  factory Minhum.fromJson(Map<String, dynamic> json) {
    return Minhum(
      minHum: json['hum'],
    );
  }
}
