import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stack/bloc/load_code/bloc/load_code_bloc.dart';
import 'package:flutter_stack/bloc/theme/theme_bloc.dart';
import 'package:flutter_stack/bloc/theme/theme_state.dart';
import 'package:flutter_stack/repository/apiGitHubRepository.dart';

import 'pages/preview_page.dart';

void main() {
  // Register WebView implementation for web builds

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider(
          create: (context) => GitHubBloc(
            repository: ApiGitHubRepository(),
          ),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'GitHub File Preview',
            theme: themeState.themeData,
            home: const PreviewPage(),
          );
        },
      ),
    );
  }
}
