class Rataketntu {
  final double rataKetNtu;

  Rataketntu({
    required this.rataKetNtu,
  });

  factory Rataketntu.fromJson(Map<String, dynamic> json) {
    // Cek jika nilai 'avg_ntu' ada dan bukan null
    if (json.containsKey('avg_ntu') && json['avg_ntu'] != null) {
      // Konversi nilai 'avg_ntu' ke tipe double
      // Jika gagal, kembalikan nilai default 0.0 atau atur nilai lain sesuai kebutuhan
      double parsedValue = 0.0; // Nilai default jika konversi gagal
      try {
        parsedValue = double.parse(json['avg_ntu'].toString());
      } catch (e) {
        // Tangani kesalahan konversi jika terjadi
        print('Error parsing value: $e');
        // Atau lakukan sesuatu yang sesuai dengan kasus Anda
      }

      return Rataketntu(rataKetNtu: parsedValue);
    } else {
      // Jika nilai tidak ada atau null, kembalikan nilai default atau atur nilai lain
      return Rataketntu(
          rataKetNtu: 0.0); // Nilai default jika 'avg_ntu' tidak ada
      // Atau lakukan sesuatu yang sesuai dengan kasus Anda
    }
  }
}
