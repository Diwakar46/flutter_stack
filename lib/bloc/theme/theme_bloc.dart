import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState.light) {
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeEvent>(_onSetTheme);
  }

  void _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) {
    if (state.isDark) {
      emit(ThemeState.light);
    } else {
      emit(ThemeState.dark);
    }
  }

  void _onSetTheme(SetThemeEvent event, Emitter<ThemeState> emit) {
    if (event.isDark) {
      emit(ThemeState.dark);
    } else {
      emit(ThemeState.light);
    }
  }
}