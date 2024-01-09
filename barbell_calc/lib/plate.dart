import 'dart:convert';

class Plate {
  final String width;
  final double weight;

  Plate({
    required this.width,
    required this.weight,
  });

  factory Plate.fromJson(Map<String, dynamic> jsonData) {
    return Plate(
      width: jsonData['width'],
      weight: jsonData['weight'],
    );
  }

  static Map<String, dynamic> toMap(Plate plate) => {
        'width': plate.width,
        'weight': plate.weight,
      };

  static String encode(List<Plate> plates) => json.encode(
    plates
            .map<Map<String, dynamic>>((plate) => Plate.toMap(plate))
            .toList(),
      );

  static List<Plate> decode(String plates) =>
      (json.decode(plates) as List<dynamic>)
          .map<Plate>((item) => Plate.fromJson(item))
          .toList();
}
