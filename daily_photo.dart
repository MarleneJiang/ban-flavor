class DailyPhoto {
  final String id;
  final DateTime date;
  final String filePath;
  final String thumbnailPath;

  DailyPhoto({
    required this.id,
    required this.date,
    required this.filePath,
    required this.thumbnailPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'filePath': filePath,
      'thumbnailPath': thumbnailPath,
    };
  }

  factory DailyPhoto.fromJson(Map<String, dynamic> json) {
    return DailyPhoto(
      id: json['id'],
      date: DateTime.parse(json['date']),
      filePath: json['filePath'],
      thumbnailPath: json['thumbnailPath'],
    );
  }

  @override
  String toString() {
    return 'DailyPhoto{id: $id, date: $date, filePath: $filePath}';
  }
}
