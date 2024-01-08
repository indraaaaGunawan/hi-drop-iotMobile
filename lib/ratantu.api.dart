class Ratantu {
  final String rataNtu;

  Ratantu({
    required this.rataNtu,
  });

  factory Ratantu.fromJson(Map<String, dynamic> json) {
    return Ratantu(
      rataNtu: json['ntu'],
    );
  }
}
