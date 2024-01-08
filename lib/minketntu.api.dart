class Minketntu {
  final String minKetNtu;

  Minketntu({
    required this.minKetNtu,
  });

  factory Minketntu.fromJson(Map<String, dynamic> json) {
    return Minketntu(
      minKetNtu: json['ket_ntu'],
    );
  }
}
