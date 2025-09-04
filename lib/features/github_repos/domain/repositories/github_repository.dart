import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/repository.dart';

abstract class GithubRepository {
  Future<Either<Failure, List<Repository>>> getRepositories({int page = 1});
  Future<Either<Failure, List<Repository>>> searchRepositories({
    required String query,
    int page = 1,
  });
} 