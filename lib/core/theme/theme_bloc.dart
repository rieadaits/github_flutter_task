import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ThemeChanged extends ThemeEvent {
  final bool isDarkMode;

  const ThemeChanged(this.isDarkMode);

  @override
  List<Object> get props => [isDarkMode];
}

class ThemeInitialized extends ThemeEvent {}

// States
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final bool isDarkMode;

  const ThemeLoaded(this.isDarkMode);

  @override
  List<Object> get props => [isDarkMode];
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'is_dark_mode';

  ThemeBloc() : super(ThemeInitial()) {
    on<ThemeInitialized>(_onThemeInitialized);
    on<ThemeChanged>(_onThemeChanged);
  }

  Future<void> _onThemeInitialized(
    ThemeInitialized event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_themeKey) ?? false;
    emit(ThemeLoaded(isDarkMode));
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, event.isDarkMode);
    emit(ThemeLoaded(event.isDarkMode));
  }
}
