import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../features/github_repos/data/datasources/github_local_datasource.dart';
import '../../features/github_repos/data/datasources/github_remote_datasource.dart';
import '../../features/github_repos/data/repositories/github_repository_impl.dart';
import '../../features/github_repos/domain/repositories/github_repository.dart';
import '../../features/github_repos/presentation/bloc/github_repos_bloc.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoC
  sl.registerFactory(
    () => GithubReposBloc(repository: sl()),
  );

  // Repository
  sl.registerLazySingleton<GithubRepository>(
    () => GithubRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<GithubRemoteDataSource>(
    () => GithubRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<GithubLocalDataSource>(
    () => GithubLocalDataSourceImpl(),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  // External
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker.instance);
}
