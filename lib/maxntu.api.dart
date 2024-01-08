class Maksntu {
  final String maksNtu;

  Maksntu({
    required this.maksNtu,
  });

  factory Maksntu.fromJson(Map<String, dynamic> json) {
    return Maksntu(
      maksNtu: json['ntu'],
    );
  }
}
