import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/repositories/github_repository.dart';
import 'github_repos_event.dart';
import 'github_repos_state.dart';

class GithubReposBloc extends Bloc<GithubReposEvent, GithubReposState> {
  final GithubRepository repository;
  int _currentPage = 1;
  String _currentSearchQuery = '';
  static const int _itemsPerPage = 15;

  GithubReposBloc({required this.repository}) : super(GithubReposInitial()) {
    on<FetchGithubRepos>(_onFetchGithubRepos);
    on<LoadMoreGithubRepos>(_onLoadMoreGithubRepos);
    on<SearchRepositories>(
      _onSearchRepositories,
      transformer: (events, mapper) {
        return events
            .debounceTime(const Duration(milliseconds: 500))
            .switchMap(mapper);
      },
    );
    on<LoadMoreSearchResults>(_onLoadMoreSearchResults);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onFetchGithubRepos(
    FetchGithubRepos event,
    Emitter<GithubReposState> emit,
  ) async {
    emit(GithubReposLoading());
    _currentPage = 1;
    final result = await repository.getRepositories(page: _currentPage);
    result.fold(
      (failure) {
        // Check if it's an offline scenario (CacheFailure with specific message)
        if (failure.message.contains('No internet connection')) {
          emit(GithubReposOffline(failure.message));
        } else {
          emit(GithubReposError(failure.message));
        }
      },
      (repositories) => emit(
        GithubReposLoaded(
          repositories: repositories,
          hasReachedMax: repositories.length < _itemsPerPage,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreGithubRepos(
    LoadMoreGithubRepos event,
    Emitter<GithubReposState> emit,
  ) async {
    if (state is GithubReposLoaded) {
      final currentState = state as GithubReposLoaded;
      if (!currentState.hasReachedMax) {
        emit(currentState.copyWith(isLoadingMore: true));
        _currentPage++;
        
        final result = currentState.isSearching
            ? await repository.searchRepositories(
                query: _currentSearchQuery,
                page: _currentPage,
              )
            : await repository.getRepositories(page: _currentPage);
            
        result.fold(
          (failure) => emit(GithubReposError(failure.message)),
          (newRepositories) {
            if (newRepositories.isEmpty) {
              emit(currentState.copyWith(
                hasReachedMax: true,
                isLoadingMore: false,
              ));
            } else {
              emit(currentState.copyWith(
                repositories: [...currentState.repositories, ...newRepositories],
                hasReachedMax: newRepositories.length < _itemsPerPage,
                isLoadingMore: false,
              ));
            }
          },
        );
      }
    }
  }

  Future<void> _onSearchRepositories(
    SearchRepositories event,
    Emitter<GithubReposState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      add(const ClearSearch());
      return;
    }

    _currentSearchQuery = event.query.trim();
    _currentPage = 1;
    emit(GithubReposLoading());

    final result = await repository.searchRepositories(
      query: _currentSearchQuery,
      page: _currentPage,
    );
    result.fold(
      (failure) => emit(GithubReposError(failure.message)),
      (repositories) => emit(
        GithubReposLoaded(
          repositories: repositories,
          hasReachedMax: repositories.length < _itemsPerPage,
          isSearching: true,
          searchQuery: _currentSearchQuery,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreSearchResults(
    LoadMoreSearchResults event,
    Emitter<GithubReposState> emit,
  ) async {
    if (state is GithubReposLoaded) {
      final currentState = state as GithubReposLoaded;
      if (!currentState.hasReachedMax && currentState.isSearching) {
        emit(currentState.copyWith(isLoadingMore: true));
        _currentPage++;
        
        final result = await repository.searchRepositories(
          query: _currentSearchQuery,
          page: _currentPage,
        );
        result.fold(
          (failure) => emit(GithubReposError(failure.message)),
          (newRepositories) {
            if (newRepositories.isEmpty) {
              emit(currentState.copyWith(
                hasReachedMax: true,
                isLoadingMore: false,
              ));
            } else {
              emit(currentState.copyWith(
                repositories: [...currentState.repositories, ...newRepositories],
                hasReachedMax: newRepositories.length < _itemsPerPage,
                isLoadingMore: false,
              ));
            }
          },
        );
      }
    }
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<GithubReposState> emit,
  ) async {
    _currentSearchQuery = '';
    _currentPage = 1;
    emit(GithubReposLoading());
    
    final result = await repository.getRepositories(page: _currentPage);
    result.fold(
      (failure) {
        // Check if it's an offline scenario (CacheFailure with specific message)
        if (failure.message.contains('No internet connection')) {
          emit(GithubReposOffline(failure.message));
        } else {
          emit(GithubReposError(failure.message));
        }
      },
      (repositories) => emit(
        GithubReposLoaded(
          repositories: repositories,
          hasReachedMax: repositories.length < _itemsPerPage,
          isSearching: false,
          searchQuery: '',
        ),
      ),
    );
  }
} 