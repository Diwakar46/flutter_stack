// lib/pages/preview_page.dart
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stack/bloc/load_code/bloc/load_code_bloc.dart';

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
  double _splitRatio = 0.6; // 60% for code, 40% for DartPad
  final String _dartPadViewId = 'dartpad-iframe';
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _repoController = TextEditingController();
  final TextEditingController _pathController = TextEditingController();
  @override
  void initState() {
    super.initState();
    
    // Set default URL for testing
    
    if (kIsWeb) {
      _initializeDartPadForWeb();
    }
  }

  void _initializeDartPadForWeb() {
    // Register the iframe view factory for web
    ui_web.platformViewRegistry.registerViewFactory(
      _dartPadViewId,
      (int viewId) {
        final iframe = html.IFrameElement()
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

  void _copyToDartPad() async {
    if (!_isFlutterCode || !_isDartPadReady || !kIsWeb) return;
    
    try {
      // Clean the code for DartPad
      String cleanedCode = _prepareCodeForDartPad(_currentContent);
      
      // Find the iframe and inject code
      final iframe = html.document.querySelector('iframe[src*="dartpad.dev"]') as html.IFrameElement?;
      if (iframe != null) {
        // Use postMessage to communicate with DartPad
        final message = {
          'type': 'sourceCode',
          'sourceCode': {
            'main.dart': cleanedCode,
          }
        };
        
        iframe.contentWindow?.postMessage(message, 'https://dartpad.dev');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code sent to DartPad! Click Run to execute.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception('DartPad iframe not found');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending code to DartPad: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Header with file info and controls
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(_getFileIcon(_currentFilename.split('.').last), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentFilename,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  '${_currentContent.split('\n').length} lines',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                // if (_isFlutterCode) ...[
                //   ElevatedButton.icon(
                //     onPressed: _isDartPadReady ? _copyToDartPad : null,
                //     icon: const Icon(Icons.play_arrow, size: 16),
                //     label: const Text('Run in DartPad'),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.blue,
                //       foregroundColor: Colors.white,
                //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                //     ),
                //   ),
                //   const SizedBox(width: 8),
                // ],
                IconButton(
                  icon: const Icon(Icons.copy_all, size: 18),
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
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _currentContent,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.left,
                showCursor: true,
                cursorColor: Colors.blue,
                selectionControls: MaterialTextSelectionControls(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDartPadViewer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // DartPad header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
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
        child: Container(
          width: 8,
          color: Colors.grey[300],
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
    // Parse GitHub API URL to extract owner, repo, and path
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.host.contains('api.github.com')) {
      throw Exception('Invalid GitHub API URL');
    }

    final pathSegments = uri.pathSegments;
    if (pathSegments.length < 5 || 
        pathSegments[0] != 'repos' || 
        pathSegments[2] != 'contents') {
      throw Exception('URL must be in format: https://api.github.com/repos/owner/repo/contents/path');
    }

    return {
      'owner': pathSegments[1],
      'repo': pathSegments[2],
      'path': pathSegments.skip(4).join('/'),
    };
  }

  void _fetchFile() {
    final owner = _ownerController.text.trim();
    final repo = _repoController.text.trim();
    final path = _pathController.text.trim();

    if (owner.isEmpty || repo.isEmpty || path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    context.read<GitHubBloc>().add(
      FetchFileContents(owner: owner, repo: repo, path: path),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Code Runner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
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
          // URL input section
 Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ownerController,
                        decoration: const InputDecoration(
                          labelText: 'Owner',
                          hintText: 'e.g., flutter',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _repoController,
                        decoration: const InputDecoration(
                          labelText: 'Repository',
                          hintText: 'e.g., flutter',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pathController,
                        decoration: const InputDecoration(
                          labelText: 'File Path',
                          hintText: 'e.g., README.md or lib/main.dart',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _fetchFile,
                      child: const Text('Fetch File'),
                    ),
                  ],
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
      _ownerController.dispose();
    _repoController.dispose();
    _pathController.dispose();
    super.dispose();
  }
}