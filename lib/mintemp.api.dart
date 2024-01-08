class Mintemp {
  final String minTemp;

  Mintemp({
    required this.minTemp,
  });

  factory Mintemp.fromJson(Map<String, dynamic> json) {
    return Mintemp(
      minTemp: json['temp'],
    );
  }
}
