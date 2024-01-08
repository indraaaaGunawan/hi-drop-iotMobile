class Makstemp {
  final String maksTemp;

  Makstemp({
    required this.maksTemp,
  });

  factory Makstemp.fromJson(Map<String, dynamic> json) {
    return Makstemp(
      maksTemp: json['temp'],
    );
  }
}
