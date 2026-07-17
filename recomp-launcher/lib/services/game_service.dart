import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/game.dart';

class GameService {
  GameService._();
  static final GameService instance = GameService._();

  Database? _db;

  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'recomp.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE games (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            filePath TEXT NOT NULL,
            fileSizeBytes INTEGER NOT NULL DEFAULT 0,
            coverImagePath TEXT,
            description TEXT,
            releaseYear INTEGER,
            genre TEXT,
            publisher TEXT,
            rating TEXT,
            isFavorite INTEGER NOT NULL DEFAULT 0,
            addedAt TEXT NOT NULL,
            lastPlayedAt TEXT,
            playCount INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<List<Game>> getAllGames() async {
    final maps = await _db!.query('games', orderBy: 'addedAt DESC');
    return maps.map(Game.fromMap).toList();
  }

  Future<List<Game>> getRecentlyPlayed({int limit = 5}) async {
    final maps = await _db!.query(
      'games',
      where: 'lastPlayedAt IS NOT NULL',
      orderBy: 'lastPlayedAt DESC',
      limit: limit,
    );
    return maps.map(Game.fromMap).toList();
  }

  Future<List<Game>> getFavorites() async {
    final maps = await _db!.query(
      'games',
      where: 'isFavorite = 1',
      orderBy: 'title ASC',
    );
    return maps.map(Game.fromMap).toList();
  }

  Future<List<Game>> searchGames(String query) async {
    final maps = await _db!.query(
      'games',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'title ASC',
    );
    return maps.map(Game.fromMap).toList();
  }

  Future<void> addGame(Game game) async {
    await _db!.insert(
      'games',
      game.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateGame(Game game) async {
    await _db!.update(
      'games',
      game.toMap(),
      where: 'id = ?',
      whereArgs: [game.id],
    );
  }

  Future<void> deleteGame(String id) async {
    await _db!.delete('games', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await _db!.update(
      'games',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> recordPlay(String id) async {
    await _db!.rawUpdate(
      'UPDATE games SET lastPlayedAt = ?, playCount = playCount + 1 WHERE id = ?',
      [DateTime.now().toIso8601String(), id],
    );
  }

  Future<void> updateCover(String id, String? coverPath) async {
    await _db!.update(
      'games',
      {'coverImagePath': coverPath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getGameCount() async {
    final result =
        await _db!.rawQuery('SELECT COUNT(*) as count FROM games');
    return result.first['count'] as int;
  }
}
