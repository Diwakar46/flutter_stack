import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_stack/model/apiGitHubResponseModel.dart';
import 'package:flutter_stack/repository/apiGitHubRepository.dart';
import 'package:meta/meta.dart';

part 'load_code_event.dart';
part 'load_code_state.dart';



class GitHubBloc extends Bloc<GitHubEvent, GitHubState> {
  final ApiGitHubRepository _repository;

  GitHubBloc({required ApiGitHubRepository repository})
      : _repository = repository,
        super(GitHubInitial()) {
    on<FetchFileContents>(_onFetchFileContents);
    on<FetchDirectoryContents>(_onFetchDirectoryContents);
    on<ClearContents>(_onClearContents);
  }

  Future<void> _onFetchFileContents(
    FetchFileContents event,
    Emitter<GitHubState> emit,
  ) async {
    emit(GitHubLoading());
    try {
      final file = await _repository.getFileContents(
        owner: event.owner,
        repo: event.repo,
        path: event.path,
      );
      emit(GitHubFileLoaded(file));
    } catch (e) {
      emit(GitHubError(e.toString()));
    }
  }

  Future<void> _onFetchDirectoryContents(
    FetchDirectoryContents event,
    Emitter<GitHubState> emit,
  ) async {
    emit(GitHubLoading());
    try {
      final contents = await _repository.getDirectoryContents(
        owner: event.owner,
        repo: event.repo,
        path: event.path,
      );
      emit(GitHubDirectoryLoaded(contents));
    } catch (e) {
      emit(GitHubError(e.toString()));
    }
  }

  void _onClearContents(
    ClearContents event,
    Emitter<GitHubState> emit,
  ) {
    emit(GitHubInitial());
  }
}