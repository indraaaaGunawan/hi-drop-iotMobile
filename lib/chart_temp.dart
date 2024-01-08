import 'package:collection/collection.dart';

class SuhuChart {
  final double x;
  final double y;
  SuhuChart({required this.x, required this.y});
}

List<SuhuChart> get suhuChart {
  // final List<double> data = [30, 36, 27, 20, 37, 28, 30, 29];
  final List<double> data = [40, 45, 37, 30, 43, 38, 40, 39];

  // Menggabungkan data waktu dan suhu menjadi objek SuhuChart
  return data
      .mapIndexed(
          (index, element) => SuhuChart(x: index.toDouble(), y: element))
      .toList();
}
