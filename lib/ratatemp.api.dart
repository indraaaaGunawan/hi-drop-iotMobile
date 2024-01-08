class Ratatemp {
  final String rataTemp;

  Ratatemp({
    required this.rataTemp,
  });

  factory Ratatemp.fromJson(Map<String, dynamic> json) {
    return Ratatemp(
      rataTemp: json['temp'],
    );
  }
}
