import 'dart:convert';

class Barbell {
  // final int id;
  final String name, width;
  final double weight;

  Barbell({
    // required this.id,
    required this.name,
    required this.width,
    required this.weight,
  });

  factory Barbell.fromJson(Map<String, dynamic> jsonData) {
    return Barbell(
      // id: jsonData['id'],
      name: jsonData['name'],
      width: jsonData['width'],
      weight: jsonData['weight'],
    );
  }

  static Map<String, dynamic> toMap(Barbell barbell) => {
        // 'id': barbell.id,
        'name': barbell.name,
        'width': barbell.width,
        'weight': barbell.weight,
      };

  static String encode(List<Barbell> musics) => json.encode(
        musics
            .map<Map<String, dynamic>>((music) => Barbell.toMap(music))
            .toList(),
      );

  static List<Barbell> decode(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<Barbell>((item) => Barbell.fromJson(item))
          .toList();
}
