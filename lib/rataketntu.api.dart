class Rataketntu {
  final String rataKetNtu;

  Rataketntu({
    required this.rataKetNtu,
  });

  factory Rataketntu.fromJson(Map<String, dynamic> json) {
    return Rataketntu(
      rataKetNtu: json['AVG(ntu)'],
    );
  }
}
