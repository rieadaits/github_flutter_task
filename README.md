# GitHub Repository Explorer - Flutter App

A comprehensive Flutter application that allows users to explore GitHub repositories with advanced features including search, dark mode, pagination, and smooth animations. Built using Clean Architecture principles and BLoC state management.

## Features ✨

### Architecture
- **Clean Architecture** with proper separation of concerns
- **Repository Pattern** for data access abstraction
- **BLoC Pattern** for state management
- **Dependency Injection** using GetIt

### Home Screen
- **Skeleton Loading** with shimmer effects while loading repositories
- **Search Functionality** with debounced input to search repositories by tags (e.g., flutter, swiftui)
- **Infinite Pagination** for seamless browsing
- **Pull-to-Refresh** support

### Detail Screen
- **Complete Repository Information** including full repository name, description, star and fork count
- **Owner Avatar** and profile information
- **GitHub URL** that opens in external browser
- **Responsive Design** for different screen sizes

### Search
- **Debounced Search Input** to minimize API calls (500ms delay)
- **Search Pagination** with load more functionality
- **Search State Management** with proper loading and error states

### Dark Mode
- **System Theme Support** with manual toggle
- **Persistent Theme Selection** using SharedPreferences
- **Consistent Design** across light and dark themes

### Error Handling
- **Toast Notifications** for error feedback
- **Retry Logic** for failed network requests
- **Graceful Fallbacks** for offline scenarios
- **User-Friendly Error Messages**

### Navigation
- **Custom Slide Animations** for page transitions
- **Smooth Navigation** between screens

## Setup Instructions 🚀

### Prerequisites
- Flutter SDK
- Dart SDK
- Android Studio / VS Code with Flutter plugins
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd gihub_repo_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For development
   flutter run
   
   # For specific platform
   flutter run -d android
   flutter run -d ios
   ```

4. **Build for production**
   ```bash
   # Android APK
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   ```

## Architecture Overview 🏗️

### Project Structure
```
lib/
├── core/
│   ├── di/                    # Dependency Injection
│   ├── error/                 # Error handling
│   ├── network/               # Network utilities
│   └── theme/                 # Theme management
└── features/
    └── github_repos/
        ├── data/
        │   ├── datasources/   # Remote & Local data sources
        │   ├── models/        # Data models
        │   └── repositories/  # Repository implementations
        ├── domain/
        │   ├── entities/      # Business entities
        │   └── repositories/  # Repository interfaces
        └── presentation/
            ├── bloc/          # BLoC state management
            ├── pages/         # UI screens
            └── widgets/       # Reusable widgets
```

### Clean Architecture Layers

#### 1. **Domain Layer** (Business Logic)
- **Entities**: Core business models (`Repository`)
- **Repository Interfaces**: Abstract contracts for data access
- **No Dependencies**: Pure Dart with no external dependencies

#### 2. **Data Layer** (Data Sources)
- **Repository Implementations**: Concrete implementations of domain interfaces
- **Data Sources**: Remote (GitHub API) and Local (SQLite) data sources
- **Models**: Data transfer objects that extend domain entities
- **Network Management**: Internet connectivity checking

#### 3. **Presentation Layer** (UI)
- **BLoC**: State management with events and states
- **Pages**: Screen implementations
- **Widgets**: Reusable UI components

### Key Design Patterns

#### Repository Pattern
- Abstracts data access logic
- Provides single source of truth
- Enables easy testing and mocking
- Handles online/offline scenarios

#### BLoC Pattern
- Unidirectional data flow
- Separation of business logic from UI
- Reactive programming with streams
- Testable and maintainable

#### Dependency Injection
- Loose coupling between components
- Easy testing with mock implementations
- Service locator pattern using GetIt

## Dependencies 📦

### Core Dependencies
```yaml
flutter_bloc: ^9.1.1          # State management
get_it: ^8.2.0               # Dependency injection
http: ^1.5.0                 # HTTP client
dartz: ^0.10.1               # Functional programming
equatable: ^2.0.7            # Value equality
```

### UI & UX Dependencies
```yaml
shimmer: ^3.0.0              # Skeleton loading animations
cached_network_image: ^3.4.1 # Image caching and loading
url_launcher: ^6.3.1         # External URL launching
fluttertoast: ^8.2.8         # Toast notifications
```

### Data & Storage
```yaml
sqflite: ^2.4.2              # Local database
shared_preferences: ^2.3.2    # Key-value storage
internet_connection_checker: ^3.0.1 # Network connectivity
```

### Utility Dependencies
```yaml
path: ^1.9.1                 # Path utilities
intl: ^0.20.2                # Internationalization
rxdart: ^0.28.0              # Reactive extensions
```

## API Integration 🌐

### GitHub REST API v3
- **Base URL**: `https://api.github.com`
- **Search Endpoint**: `/search/repositories`
- **Default Query**: Flutter repositories sorted by stars
- **Rate Limiting**: 60 requests per hour for unauthenticated requests

### Sample API Request
```
GET /search/repositories?q=flutter&sort=stars&order=desc&page=1&per_page=20
```

## State Management 🧠

### BLoC Events
- `FetchGithubRepos`: Load initial repositories
- `LoadMoreGithubRepos`: Pagination for more repositories
- `SearchRepositories`: Search with debouncing
- `LoadMoreSearchResults`: Pagination for search results
- `ClearSearch`: Reset to default repository list

### BLoC States
- `GithubReposInitial`: Initial state
- `GithubReposLoading`: Loading state
- `GithubReposLoaded`: Success state with data
- `GithubReposError`: Error state with message

## Testing Strategy 🧪

### Unit Tests
- Domain entities and use cases
- Repository implementations
- BLoC logic and state transitions

### Widget Tests
- Individual widget behavior
- UI interactions and animations
- State changes and rebuilds

### Integration Tests
- End-to-end user flows
- API integration
- Database operations

## Performance Optimizations ⚡

### Network
- **Request Debouncing**: 500ms delay for search inputs
- **Pagination**: 20 items per page to reduce memory usage
- **Caching**: Local SQLite database for offline support

### UI
- **Shimmer Loading**: Skeleton screens for better perceived performance
- **Image Caching**: Cached network images with placeholder
- **Lazy Loading**: ListView.builder for efficient memory usage

### State Management
- **Stream Debouncing**: RxDart for search input debouncing
- **State Persistence**: SharedPreferences for theme selection

### Limitations
2. **Search Scope**: Limited to repository name and description
3. **Offline Functionality**: Limited to previously cached data
4. **Image Loading**: Dependent on network for repository owner avatars

### Technical Improvements
- **Advanced Search Filters**: Language, date range, repository size
- **Favorites System**: Local bookmarking of repositories
- **Share Functionality**: Share repository links

### UI/UX Enhancements
- **Repository Details**: Contributors, issues, pull requests
- **Code Preview**: Basic file browser for repositories
- **Trending Repositories**: Daily/weekly trending lists
- **User Profiles**: Complete GitHub user information

## Contributing 🤝

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support 📧

For support and questions, please contact:
- **Email**: support@example.com
- **Issues**: [GitHub Issues](https://github.com/username/repo/issues)

---

**Built with ❤️ using Flutter and Clean Architecture**