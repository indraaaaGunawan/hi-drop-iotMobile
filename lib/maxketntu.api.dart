class Maksketntu {
  final String maksKetNtu;

  Maksketntu({
    required this.maksKetNtu,
  });

  factory Maksketntu.fromJson(Map<String, dynamic> json) {
    return Maksketntu(
      maksKetNtu: json['ket_ntu'],
    );
  }
}
