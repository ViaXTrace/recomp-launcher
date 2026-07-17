class Game {
  final String id;
  final String title;
  final String filePath;
  final int fileSizeBytes;
  final String? coverImagePath;
  final String? description;
  final int? releaseYear;
  final String? genre;
  final String? publisher;
  final String? rating;
  final bool isFavorite;
  final DateTime addedAt;
  final DateTime? lastPlayedAt;
  final int playCount;

  const Game({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileSizeBytes,
    this.coverImagePath,
    this.description,
    this.releaseYear,
    this.genre,
    this.publisher,
    this.rating,
    this.isFavorite = false,
    required this.addedAt,
    this.lastPlayedAt,
    this.playCount = 0,
  });

  String get fileExtension => filePath.split('.').last.toUpperCase();

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else if (fileSizeBytes < 1024 * 1024 * 1024) {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  Game copyWith({
    String? id,
    String? title,
    String? filePath,
    int? fileSizeBytes,
    String? coverImagePath,
    String? description,
    int? releaseYear,
    String? genre,
    String? publisher,
    String? rating,
    bool? isFavorite,
    DateTime? addedAt,
    DateTime? lastPlayedAt,
    int? playCount,
  }) {
    return Game(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      description: description ?? this.description,
      releaseYear: releaseYear ?? this.releaseYear,
      genre: genre ?? this.genre,
      publisher: publisher ?? this.publisher,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      addedAt: addedAt ?? this.addedAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      playCount: playCount ?? this.playCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'fileSizeBytes': fileSizeBytes,
      'coverImagePath': coverImagePath,
      'description': description,
      'releaseYear': releaseYear,
      'genre': genre,
      'publisher': publisher,
      'rating': rating,
      'isFavorite': isFavorite ? 1 : 0,
      'addedAt': addedAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
      'playCount': playCount,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] as String,
      title: map['title'] as String,
      filePath: map['filePath'] as String,
      fileSizeBytes: map['fileSizeBytes'] as int? ?? 0,
      coverImagePath: map['coverImagePath'] as String?,
      description: map['description'] as String?,
      releaseYear: map['releaseYear'] as int?,
      genre: map['genre'] as String?,
      publisher: map['publisher'] as String?,
      rating: map['rating'] as String?,
      isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
      addedAt: DateTime.parse(map['addedAt'] as String),
      lastPlayedAt: map['lastPlayedAt'] != null
          ? DateTime.parse(map['lastPlayedAt'] as String)
          : null,
      playCount: map['playCount'] as int? ?? 0,
    );
  }
}
