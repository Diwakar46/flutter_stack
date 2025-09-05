part of 'load_code_bloc.dart';

abstract class GitHubEvent {}

class FetchFileContents extends GitHubEvent {
  final String owner;
  final String repo;
  final String path;

  FetchFileContents({
    required this.owner,
    required this.repo,
    required this.path,
  });
}

class FetchDirectoryContents extends GitHubEvent {
  final String owner;
  final String repo;
  final String path;

  FetchDirectoryContents({
    required this.owner,
    required this.repo,
    required this.path,
  });
}

class ClearContents extends GitHubEvent {}