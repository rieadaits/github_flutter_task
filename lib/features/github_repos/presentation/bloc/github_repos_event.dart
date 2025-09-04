import 'package:equatable/equatable.dart';

abstract class GithubReposEvent extends Equatable {
  const GithubReposEvent();

  @override
  List<Object?> get props => [];
}

class FetchGithubRepos extends GithubReposEvent {
  const FetchGithubRepos();
}

class LoadMoreGithubRepos extends GithubReposEvent {
  const LoadMoreGithubRepos();
}

class SearchRepositories extends GithubReposEvent {
  final String query;

  const SearchRepositories(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadMoreSearchResults extends GithubReposEvent {
  const LoadMoreSearchResults();
}

class ClearSearch extends GithubReposEvent {
  const ClearSearch();
} 