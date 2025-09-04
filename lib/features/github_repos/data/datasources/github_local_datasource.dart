import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../../core/error/exceptions.dart';
import '../models/repository_model.dart';

abstract class GithubLocalDataSource {
  Future<List<RepositoryModel>> getLastRepositories();
  Future<void> cacheRepositories(List<RepositoryModel> repositories);
}

class GithubLocalDataSourceImpl implements GithubLocalDataSource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'github_repos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE repositories(
            id INTEGER PRIMARY KEY,
            name TEXT,
            full_name TEXT,
            description TEXT,
            owner_avatar_url TEXT,
            owner_name TEXT,
            stargazers_count INTEGER,
            forks_count INTEGER,
            watchers_count INTEGER,
            updated_at TEXT,
            html_url TEXT
          )
        ''');
      },
    );
  }

  @override
  Future<List<RepositoryModel>> getLastRepositories() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('repositories');
      
      return List.generate(maps.length, (i) {
        return RepositoryModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw CacheException('Failed to get cached repositories');
    }
  }

  @override
  Future<void> cacheRepositories(List<RepositoryModel> repositories) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await txn.delete('repositories');
        for (var repository in repositories) {
          await txn.insert(
            'repositories',
            repository.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (e) {
      throw CacheException('Failed to cache repositories');
    }
  }
} 