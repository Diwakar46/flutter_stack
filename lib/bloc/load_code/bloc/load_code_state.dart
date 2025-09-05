part of 'load_code_bloc.dart';

@immutable
abstract class GitHubState {}


class GitHubInitial extends GitHubState {}

class GitHubLoading extends GitHubState {}

class GitHubFileLoaded extends GitHubState {
  final ApiGitHubResponse file;

  GitHubFileLoaded(this.file);
}

class GitHubDirectoryLoaded extends GitHubState {
  final List<ApiGitHubResponse> contents;

  GitHubDirectoryLoaded(this.contents);
}

class GitHubError extends GitHubState {
  final String message;

  GitHubError(this.message);
}