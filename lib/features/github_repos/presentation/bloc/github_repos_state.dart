import 'package:equatable/equatable.dart';
import '../../domain/entities/repository.dart';

abstract class GithubReposState extends Equatable {
  const GithubReposState();

  @override
  List<Object?> get props => [];
}

class GithubReposInitial extends GithubReposState {}

class GithubReposLoading extends GithubReposState {}

class GithubReposLoaded extends GithubReposState {
  final List<Repository> repositories;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final bool isSearching;
  final String searchQuery;

  const GithubReposLoaded({
    required this.repositories,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.isSearching = false,
    this.searchQuery = '',
  });

  GithubReposLoaded copyWith({
    List<Repository>? repositories,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? isSearching,
    String? searchQuery,
  }) {
    return GithubReposLoaded(
      repositories: repositories ?? this.repositories,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [repositories, hasReachedMax, isLoadingMore, isSearching, searchQuery];
}

class GithubReposError extends GithubReposState {
  final String message;

  const GithubReposError(this.message);

  @override
  List<Object?> get props => [message];
}

class GithubReposOffline extends GithubReposState {
  final String message;

  const GithubReposOffline(this.message);

  @override
  List<Object?> get props => [message];
} 