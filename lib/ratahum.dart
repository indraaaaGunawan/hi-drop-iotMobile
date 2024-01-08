class Ratahum {
  final String rataHum;

  Ratahum({
    required this.rataHum,
  });

  factory Ratahum.fromJson(Map<String, dynamic> json) {
    return Ratahum(
      rataHum: json['hum'],
    );
  }
}
