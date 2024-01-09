import 'dart:convert';

class Barbell {
  final String name, width;
  final double weight;

  Barbell({
    required this.name,
    required this.width,
    required this.weight,
  });

  factory Barbell.fromJson(Map<String, dynamic> jsonData) {
    return Barbell(
      name: jsonData['name'],
      width: jsonData['width'],
      weight: jsonData['weight'],
    );
  }

  static Map<String, dynamic> toMap(Barbell barbell) => {
        'name': barbell.name,
        'width': barbell.width,
        'weight': barbell.weight,
      };

  static String encode(List<Barbell> barbells) => json.encode(
    barbells
            .map<Map<String, dynamic>>((barbell) => Barbell.toMap(barbell))
            .toList(),
      );

  static List<Barbell> decode(String barbells) =>
      (json.decode(barbells) as List<dynamic>)
          .map<Barbell>((item) => Barbell.fromJson(item))
          .toList();
}
