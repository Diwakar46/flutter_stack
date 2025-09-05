// lib/repositories/api_github_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_stack/model/apiGitHubResponseModel.dart';

class ApiGitHubRepository {
  final Dio _dio;
  static const String _baseUrl = 'https://api.github.com';

  ApiGitHubRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<ApiGitHubResponse> getFileContents({
    required String owner,
    required String repo,
    required String path,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/repos/$owner/$repo/contents/$path',
        options: Options(
          headers: {
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'Flutter-App',
          },
        ),
      );

      if (response.statusCode == 200) {
        return ApiGitHubResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch file contents: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('File not found: $path');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access forbidden. Check if repository is public or provide authentication.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<ApiGitHubResponse>> getDirectoryContents({
    required String owner,
    required String repo,
    required String path,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/repos/$owner/$repo/contents/$path',
        options: Options(
          headers: {
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'Flutter-App',
          },
        ),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((item) => ApiGitHubResponse.fromJson(item))
              .toList();
        } else {
          // Single file
          return [ApiGitHubResponse.fromJson(response.data)];
        }
      } else {
        throw Exception('Failed to fetch directory contents: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Directory not found: $path');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access forbidden. Check if repository is public or provide authentication.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}