import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../core/theme/theme_bloc.dart';
import '../bloc/github_repos_bloc.dart';
import '../bloc/github_repos_event.dart';
import '../bloc/github_repos_state.dart';
import '../widgets/repository_list_item.dart';
import '../widgets/shimmer_loading_widget.dart';
import 'repository_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadRepositories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadRepositories() {
    context.read<GithubReposBloc>().add(const FetchGithubRepos());
  }

  void _onSearchChanged(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      // Clear search and load default Flutter repositories
      context.read<GithubReposBloc>().add(const ClearSearch());
    } else {
      // Search for the specified query
      context.read<GithubReposBloc>().add(SearchRepositories(trimmedQuery));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<GithubReposBloc>().add(const ClearSearch());
  }

  void _loadMoreRepositories() {
    if (!_isLoadingMore) {
      _isLoadingMore = true;
      // Check the actual search field text, not just the state
      if (_searchController.text.trim().isNotEmpty) {
        context.read<GithubReposBloc>().add(const LoadMoreSearchResults());
      } else {
        context.read<GithubReposBloc>().add(const LoadMoreGithubRepos());
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreRepositories();
    }
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repositories'),
        centerTitle: false,
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              final isDarkMode = state is ThemeLoaded ? state.isDarkMode : false;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Dark mode',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        context.read<ThemeBloc>().add(ThemeChanged(value));
                      },
                      activeTrackColor: Colors.green,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search tags ie: flutter/swiftui etc.',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
            ),
          ),
          // Content
          Expanded(
            child: BlocConsumer<GithubReposBloc, GithubReposState>(
              listener: (context, state) {
                if (state is GithubReposLoaded) {
                  _isLoadingMore = state.isLoadingMore;
                } else if (state is GithubReposError) {
                  _showErrorToast(state.message);
                } else if (state is GithubReposOffline) {
                  // Don't show toast for offline state as it has its own UI
                  _isLoadingMore = false;
                }
              },
              builder: (context, state) {
                if (state is GithubReposLoading) {
                  return const RepositoryListShimmer();
                } else if (state is GithubReposLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      if (_searchController.text.trim().isNotEmpty) {
                        context.read<GithubReposBloc>().add(
                          SearchRepositories(_searchController.text.trim()),
                        );
                      } else {
                        context.read<GithubReposBloc>().add(const ClearSearch());
                      }
                    },
                    child: state.repositories.isEmpty
                        ? _buildEmptyState(state.isSearching)
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.repositories.length + 1,
                            itemBuilder: (context, index) {
                              if (index == state.repositories.length) {
                                return _buildLoadingFooter(state);
                              }

                              final repository = state.repositories[index];
                              return RepositoryListItem(
                                repository: repository,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    _createSlideRoute(
                                      RepositoryDetailsPage(repository: repository),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  );
                } else if (state is GithubReposOffline) {
                  return _buildOfflineState(state.message);
                } else if (state is GithubReposError) {
                  return _buildErrorState(state.message);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.inbox_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'No repositories found' : 'No repositories available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching 
                  ? 'Try searching with different keywords'
                  : 'Pull to refresh or try again later',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingFooter(GithubReposLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: state.isLoadingMore
            ? const CircularProgressIndicator()
            : state.hasReachedMax
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No more repositories',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildOfflineState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'No Internet Connection',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your internet connection',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                // Show loading toast
                Fluttertoast.showToast(
                  msg: 'Checking connection...',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                );
                
                // Add a small delay to show the toast
                await Future.delayed(const Duration(milliseconds: 500));
                
                // Retry the API call
                _loadRepositories();
                
                // Listen to the result and show appropriate toast if still no internet
                if (mounted) {
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      final currentState = context.read<GithubReposBloc>().state;
                      if (currentState is GithubReposOffline) {
                        Fluttertoast.showToast(
                          msg: 'Still no internet connection. Please check your network.',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                      }
                    }
                  });
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRepositories,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Route _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}