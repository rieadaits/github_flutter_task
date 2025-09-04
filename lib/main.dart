import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/theme/theme_bloc.dart';
import 'features/github_repos/presentation/pages/home_page.dart';
import 'features/github_repos/presentation/bloc/github_repos_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ThemeBloc()..add(ThemeInitialized()),
        ),
        BlocProvider(
          create: (_) => di.sl<GithubReposBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'GitHub Repository Explorer',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState is ThemeLoaded
                ? (themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light)
                : ThemeMode.light,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}