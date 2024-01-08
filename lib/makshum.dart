class Makshum {
  final String maksHum;

  Makshum({
    required this.maksHum,
  });

  factory Makshum.fromJson(Map<String, dynamic> json) {
    return Makshum(
      maksHum: json['hum'],
    );
  }
}
