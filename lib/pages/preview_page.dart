// lib/pages/preview_page.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stack/bloc/load_code/bloc/load_code_bloc.dart';
import 'package:flutter_stack/bloc/theme/theme_bloc.dart';
import 'package:flutter_stack/bloc/theme/theme_event.dart';
import 'package:flutter_stack/bloc/theme/theme_state.dart';
import 'package:flutter_stack/utils/code_themes.dart';
// Conditional imports for web-specific functionality
import 'package:flutter_stack/utils/web_utils_stub.dart'
    if (dart.library.html) 'package:flutter_stack/utils/web_utils_web.dart';

class PreviewPage extends StatefulWidget {
  const PreviewPage({super.key});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  
  String _currentContent = '';
  String _currentFilename = '';
  bool _showDartPad = false;
  bool _isFlutterCode = false;
  bool _isDartPadReady = false;
  double _splitRatio = 0.4; // 60% for code, 40% for DartPad
  final String _dartPadViewId = 'dartpad-iframe';
  final TextEditingController _urlController = TextEditingController();
  bool _showUrlField = false;
  @override
  void initState() {
    super.initState();
    
    if (kIsWeb) {
      _initializeDartPadForWeb();
      _checkForUrlParameter();
    }
  }

  void _initializeDartPadForWeb() {
    if (!kIsWeb) return;
    
    // Register the iframe view factory for web
    platformViewRegistry.registerViewFactory(
      _dartPadViewId,
      (int viewId) {
        final iframe = IFrameElement()
          ..src = 'https://dartpad.dev/embed-flutter.html'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        
        // Listen for iframe load
        iframe.onLoad.listen((_) {
          if (mounted) {
            setState(() {
              _isDartPadReady = true;
            });
          }
        });
        
        return iframe;
      },
    );
  }

  String _decodeBase64Content(String? content) {
    if (content == null || content.isEmpty) return '';
    try {
      final cleanContent = content.replaceAll(RegExp(r'\s'), '');
      final decodedBytes = base64.decode(cleanContent);
      return utf8.decode(decodedBytes);
    } catch (e) {
      return 'Error decoding content: $e';
    }
  }

  bool _isFlutterDartCode(String content, String filename) {
    final extension = filename.split('.').last.toLowerCase();
    if (extension != 'dart') return false;
    
    // Check for common Flutter imports and patterns
    return content.contains('package:flutter/') ||
           content.contains('StatelessWidget') ||
           content.contains('StatefulWidget') ||
           content.contains('Widget build(') ||
           content.contains('runApp(') ||
           content.contains('MaterialApp') ||
           content.contains('Scaffold');
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }



  String _prepareCodeForDartPad(String code) {
    // Remove any existing import statements that might conflict
    String cleaned = code;
    
    // Ensure the code has a main function and runApp
    if (!cleaned.contains('void main()') && !cleaned.contains('main()')) {
      if (cleaned.contains('runApp(')) {
        // If runApp exists but no main, wrap it
        cleaned = '''
void main() {
$cleaned
}''';
      } else if (cleaned.contains('class ') && (cleaned.contains('extends StatelessWidget') || cleaned.contains('extends StatefulWidget'))) {
        // If it's a widget class, create a simple main
        String className = _extractClassName(cleaned);
        cleaned = '''
$cleaned

void main() {
  runApp(MaterialApp(home: $className()));
}''';
      }
    }
    
    // Add necessary imports if missing
    if (!cleaned.contains('import \'package:flutter/material.dart\'')) {
      cleaned = '''import 'package:flutter/material.dart';

$cleaned''';
    }
    
    return cleaned;
  }

  String _extractClassName(String code) {
    final classMatch = RegExp(r'class\s+(\w+)\s+extends\s+StatelessWidget').firstMatch(code);
    if (classMatch != null) {
      return classMatch.group(1)!;
    }
    final statefulMatch = RegExp(r'class\s+(\w+)\s+extends\s+StatefulWidget').firstMatch(code);
    if (statefulMatch != null) {
      return statefulMatch.group(1)!;
    }
    return 'MyApp';
  }

  Widget _buildCodeViewer() {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        return Container(
          decoration: BoxDecoration(
            color: VSCodeThemes.getBackgroundColor(isDark),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xff3c3c3c) : Colors.grey[300]!,
            ),
          ),
      child: Column(
        children: [
          // Header with file info and controls
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xff2d2d30) : const Color(0xfff3f3f3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xff3c3c3c) : Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getFileIcon(_currentFilename.split('.').last), 
                  size: 18,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentFilename,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Text(
                  '${_currentContent.split('\n').length} lines',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[600], 
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    Icons.copy_all, 
                    size: 18,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  onPressed: () => _copyToClipboard(_currentContent),
                  tooltip: 'Copy all code',
                ),
              ],
            ),
          ),
          // Selectable code content
          Expanded(
            child: Container(
              width: double.infinity,
              color: VSCodeThemes.getBackgroundColor(isDark),
              child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                child: SelectableText(
                       _currentContent,
                  style: TextStyle(
                    fontFamily: 'Consolas, Monaco, monospace',
                    fontSize: 14,
                    color: VSCodeThemes.getTextColor(isDark),
                  ),
                ),
              ),
            ),
            ),
          ),
        ],
      ),
        );
      },
    );
  }


  Widget _buildDartPadViewer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // DartPad header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.code, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'DartPad - Flutter',
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
                ),
                const Spacer(),
                if (!_isDartPadReady)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                if (_isDartPadReady)
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
              ],
            ),
          ),
          // DartPad iframe
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: kIsWeb 
                ? HtmlElementView(viewType: _dartPadViewId)
                : Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.web_asset_off, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'DartPad is only available on web platform',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitPanelDragger() {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final screenWidth = MediaQuery.of(context).size.width;
            final delta = details.delta.dx / screenWidth;
            _splitRatio = (_splitRatio + delta).clamp(0.2, 0.8);
          });
        },
        child: SizedBox(
          width: 8,
          child: Center(
            child: Container(
              width: 2,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentViewer() {
    if (_currentContent.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Enter a GitHub API URL and fetch a file to preview its content here.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // Code section (left side)
        SizedBox(
          width: MediaQuery.of(context).size.width * _splitRatio,
          child: Card(
            margin: const EdgeInsets.all(8),
            elevation: 2,
            child: _buildCodeViewer(),
          ),
        ),
        // Draggable divider
        if (_showDartPad) _buildSplitPanelDragger(),
        // DartPad section (right side)
        if (_showDartPad)
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(8),
              elevation: 2,
              child: _buildDartPadViewer(),
            ),
          ),
      ],
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'dart': return Icons.code;
      case 'js': return Icons.javascript;
      case 'html': return Icons.web;
      case 'css': return Icons.style;
      case 'json': return Icons.data_object;
      case 'md': return Icons.article;
      default: return Icons.insert_drive_file;
    }
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red[50],
          border: Border.all(color: Colors.red[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> _parseGitHubUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw Exception('Invalid URL format');
    }

    // Handle GitHub API URLs
    if (uri.host.contains('api.github.com')) {
      final pathSegments = uri.pathSegments;
      if (pathSegments.length < 5 || 
          pathSegments[0] != 'repos' || 
          pathSegments[2] != 'contents') {
        throw Exception('API URL must be in format: https://api.github.com/repos/owner/repo/contents/path');
      }

      return {
        'owner': pathSegments[1],
        'repo': pathSegments[2],
        'path': pathSegments.skip(4).join('/'),
      };
    }
    
    // Handle regular GitHub URLs
    if (uri.host.contains('github.com')) {
      final pathSegments = uri.pathSegments;
      if (pathSegments.length < 4 || pathSegments[2] != 'blob') {
        throw Exception('GitHub URL must be in format: https://github.com/owner/repo/blob/branch/path');
      }

      return {
        'owner': pathSegments[0],
        'repo': pathSegments[1],
        'path': pathSegments.skip(4).join('/'),
      };
    }

    throw Exception('URL must be a GitHub or GitHub API URL');
  }

  void _checkForUrlParameter() {
    if (!kIsWeb) return;
    
    // Get current URL
    final currentUrl = Uri.base.toString();
    
    // Extract GitHub URL from path (after domain)
    String? githubUrl = _extractGitHubUrlFromPath(currentUrl);
    
    if (githubUrl != null && githubUrl.isNotEmpty) {
      // Set the URL in the controller
      _urlController.text = githubUrl;
      // Auto-fetch the file
      _fetchFileFromUrl();
    }
  }

  String? _extractGitHubUrlFromPath(String fullUrl) {
    try {
      final uri = Uri.parse(fullUrl);
      final path = uri.path;
      
      // Check if path contains github.com
      if (path.contains('github.com')) {
        // Find the start of the GitHub URL
        final githubIndex = path.indexOf('https://github.com');
        if (githubIndex != -1) {
          // Extract everything from 'https://github.com' onwards
          final githubUrl = path.substring(githubIndex);
          return Uri.decodeFull(githubUrl);
        }
        
        // Also handle case where protocol is missing
        final githubIndexNoProtocol = path.indexOf('github.com');
        if (githubIndexNoProtocol != -1) {
          final githubUrl = 'https://${path.substring(githubIndexNoProtocol)}';
          return Uri.decodeFull(githubUrl);
        }
      }
      
      // Also check query parameters
      final githubParam = uri.queryParameters['github'] ?? uri.queryParameters['url'];
      if (githubParam != null && githubParam.contains('github.com')) {
        return Uri.decodeFull(githubParam);
      }
      
    } catch (e) {
      debugPrint('Error parsing URL: $e');
    }
    
    return null;
  }

  void _toggleUrlField() {
    setState(() {
      _showUrlField = !_showUrlField;
    });
  }

  void _fetchFileFromUrl() {
    final url = _urlController.text.trim();
    
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a GitHub URL')),
      );
      return;
    }

    try {
      final parsed = _parseGitHubUrl(url);
      context.read<GitHubBloc>().add(
        FetchFileContents(
          owner: parsed['owner']!,
          repo: parsed['repo']!,
          path: parsed['path']!,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error parsing URL: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
        children: [   
          Image.asset('assets/flutter_stack_logo.png',  height: 32,),
        ],
      ),
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return IconButton(
                icon: Icon(themeState.isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => context.read<ThemeBloc>().add(ToggleThemeEvent()),
                tooltip: themeState.isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              );
            },
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _showUrlField ? 300 : 0,
            child: _showUrlField
                ? Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        hintText: 'GitHub URL...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            _fetchFileFromUrl();
                            _toggleUrlField();
                          },
                        ),
                      ),
                      onSubmitted: (_) {
                        _fetchFileFromUrl();
                        _toggleUrlField();
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _toggleUrlField,
            tooltip: 'GitHub URL',
          ),
          if (_currentContent.isNotEmpty && _isFlutterCode)
            IconButton(
              icon: Icon(_showDartPad ? Icons.code : Icons.play_circle_outline),
              onPressed: () => setState(() => _showDartPad = !_showDartPad),
              tooltip: _showDartPad ? 'Hide DartPad' : 'Show DartPad',
            ),
          if (_currentContent.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy_all),
              onPressed: () => _copyToClipboard(_currentContent),
              tooltip: 'Copy entire file',
            ),
        ],
      ),
      body: Column(
        children: [
          // Platform info banner
          if (!kIsWeb)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.orange[100],
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange[800]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'DartPad integration is only available when running on web platform. Run with "flutter run -d chrome" to use DartPad.',
                      style: TextStyle(color: Colors.orange[800], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          // Content section
          Expanded(
            child: BlocListener<GitHubBloc, GitHubState>(
              listener: (context, state) {
                if (state is GitHubFileLoaded) {
                  final content = _decodeBase64Content(state.file.content);
                  final filename = state.file.name ?? 'unknown';
                  
                  setState(() {
                    _currentContent = content;
                    _currentFilename = filename;
                    _isFlutterCode = _isFlutterDartCode(content, filename);
                    _showDartPad = _isFlutterCode && kIsWeb; // Auto-show DartPad for Flutter code on web
                  });
                } else if (state is GitHubError) {
                  setState(() {
                    _currentContent = '';
                    _currentFilename = '';
                    _isFlutterCode = false;
                    _showDartPad = false;
                  });
                }
              },
              child: BlocBuilder<GitHubBloc, GitHubState>(
                builder: (context, state) {
                  if (state is GitHubLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Fetching file from GitHub...'),
                        ],
                      ),
                    );
                  } else if (state is GitHubError) {
                    return _buildErrorView(state.message);
                  }
                  
                  return _buildContentViewer();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}