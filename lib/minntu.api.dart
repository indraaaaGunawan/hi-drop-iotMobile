class Minntu {
  final String minNtu;

  Minntu({
    required this.minNtu,
  });

  factory Minntu.fromJson(Map<String, dynamic> json) {
    return Minntu(
      minNtu: json['ntu'],
    );
  }
}
