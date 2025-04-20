import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FavoriteSong {
  final int id;
  final String title;
  final String artist;

  FavoriteSong({required this.id, required this.title, required this.artist});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
    };
  }

  factory FavoriteSong.fromMap(Map<String, dynamic> map) {
    return FavoriteSong(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
    );
  }
}

class DatabaseHelper {
  static final _databaseName = "favorites.db";
  static final _databaseVersion = 1;

  static final table = 'songs';

  static final columnId = '_id';
  static final columnTitle = 'title';
  static final columnArtist = 'artist';

  Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
       CREATE TABLE $table (
         $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
         $columnTitle TEXT NOT NULL,
         $columnArtist TEXT NOT NULL
       )
     ''');
  }

  // Insert a new song into the database
  Future<int> insert(FavoriteSong song) async {
    Database? db = await database;
    return await db!.insert(table, song.toMap());
  }

  // Query all songs from the database
  Future<List<FavoriteSong>> queryAllSongs() async {
    Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(table);

    return List.generate(maps.length, (i) {
      return FavoriteSong(
        id: maps[i][columnId],
        title: maps[i][columnTitle],
        artist: maps[i][columnArtist],
      );
    });
  }

  // Delete a song from the database
  Future<void> delete(int id) async {
    Database? db = await database;
    await db!.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}