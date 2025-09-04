import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/github_repository.dart';
import '../datasources/github_local_datasource.dart';
import '../datasources/github_remote_datasource.dart';
import '../../domain/entities/repository.dart';

class GithubRepositoryImpl implements GithubRepository {
  final GithubRemoteDataSource remoteDataSource;
  final GithubLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  GithubRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Repository>>> getRepositories({int page = 1}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRepos = await remoteDataSource.getRepositories(page: page);
        if (page == 1) {
          await localDataSource.cacheRepositories(remoteRepos);
        }
        return Right(remoteRepos);
      } on ServerException catch (e) {
        // If there's a server error, try to fallback to cached data
        try {
          final localRepos = await localDataSource.getLastRepositories();
          if (localRepos.isNotEmpty) {
            return Right(localRepos);
          }
        } on CacheException {
          return Left(CacheFailure('No internet connection. Please check your connection and try again.'));
        }
        return Left(ServerFailure(e.message));
      }
    } else {
      // No internet connection
      try {
        final localRepos = await localDataSource.getLastRepositories();
        if (localRepos.isNotEmpty) {
          return Right(localRepos);
        } else {
          return Left(CacheFailure('No internet connection. Please check your connection and try again.'));
        }
      } on CacheException {
        return Left(CacheFailure('No internet connection. Please check your connection and try again.'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Repository>>> searchRepositories({
    required String query,
    int page = 1,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRepos = await remoteDataSource.searchRepositories(
          query: query,
          page: page,
        );
        return Right(remoteRepos);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection available for search'));
    }
  }
} 