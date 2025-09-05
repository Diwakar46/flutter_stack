import 'package:flutter/material.dart';
import 'code_themes.dart';

class SyntaxHighlighter {
  static TextSpan highlight(String code, String language, bool isDark) {
    final theme = VSCodeThemes.getTheme(isDark);
    final baseStyle = theme['root'] ?? TextStyle(
      color: VSCodeThemes.getTextColor(isDark),
      fontFamily: 'Consolas, Monaco, monospace',
      fontSize: 14,
    );

    switch (language.toLowerCase()) {
      case 'dart':
        return _highlightDart(code, theme, baseStyle);
      case 'javascript':
      case 'js':
        return _highlightJavaScript(code, theme, baseStyle);
      case 'json':
        return _highlightJson(code, theme, baseStyle);
      case 'html':
        return _highlightHtml(code, theme, baseStyle);
      case 'css':
        return _highlightCss(code, theme, baseStyle);
      default:
        return TextSpan(text: code, style: baseStyle);
    }
  }

  static TextSpan _highlightDart(String code, Map<String, TextStyle> theme, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final lines = code.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      spans.addAll(_parseDartLine(line, theme, baseStyle));
      if (i < lines.length - 1) {
        spans.add(TextSpan(text: '\n', style: baseStyle));
      }
    }
    
    return TextSpan(children: spans);
  }

  static List<TextSpan> _parseDartLine(String line, Map<String, TextStyle> theme, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    
    // Handle empty lines
    if (line.trim().isEmpty) {
      spans.add(TextSpan(text: line, style: baseStyle));
      return spans;
    }
    
    final RegExp patterns = RegExp(
      r'(?:'
      r'//.*?$|'                                    // Single line comments
      r'/\*.*?\*/|'                                 // Multi-line comments
      r'"(?:[^"\\]|\\.)*"|'                        // Double quoted strings
      r"'(?:[^'\\]|\\.)*'|"                        // Single quoted strings
      r'r"[^"]*"|'                                 // Raw strings
      r"r'[^']*'|"                                 // Raw strings
      r'\b(?:abstract|as|assert|async|await|break|case|catch|class|const|continue|default|deferred|do|dynamic|else|enum|export|extends|external|factory|false|final|finally|for|function|get|if|implements|import|in|interface|is|library|mixin|new|null|operator|part|rethrow|return|set|static|super|switch|sync|this|throw|true|try|typedef|var|void|while|with|yield)\b|' // Dart keywords
      r'\b(?:int|double|String|bool|List|Map|Set|Object|Future|Stream|Iterable|Widget|StatelessWidget|StatefulWidget|BuildContext|MaterialApp|Scaffold)\b|' // Built-in types
      r'\b\d+\.?\d*[eE]?[+-]?\d*\b|'             // Numbers (including scientific notation)
      r'@[a-zA-Z_]\w*|'                          // Annotations
      r'[a-zA-Z_]\w*\s*(?=\()|'                   // Function calls
      r'\$\{[^}]*\}|'                            // String interpolation
      r'\$[a-zA-Z_]\w*|'                         // Simple string interpolation
      r'[a-zA-Z_]\w*'                             // Identifiers
      r')',
      multiLine: true,
    );

    int lastEnd = 0;
    for (final match in patterns.allMatches(line)) {
      // Add text before match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: line.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      final matchText = match.group(0)!;
      TextStyle style = baseStyle;

      if (matchText.startsWith('//') || matchText.startsWith('/*')) {
        // Comments
        style = theme['comment'] ?? baseStyle;
      } else if (matchText.startsWith('"') || matchText.startsWith("'") || matchText.startsWith('r"') || matchText.startsWith("r'")) {
        // Strings (including raw strings)
        style = theme['string'] ?? baseStyle;
      } else if (matchText.startsWith('@')) {
        // Annotations
        style = theme['meta'] ?? baseStyle;
      } else if (matchText.startsWith('\$')) {
        // String interpolation
        style = theme['template-variable'] ?? baseStyle;
      } else if (RegExp(r'\b(?:abstract|as|assert|async|await|break|case|catch|class|const|continue|default|deferred|do|dynamic|else|enum|export|extends|external|factory|false|final|finally|for|function|get|if|implements|import|in|interface|is|library|mixin|new|null|operator|part|rethrow|return|set|static|super|switch|sync|this|throw|true|try|typedef|var|void|while|with|yield)\b').hasMatch(matchText)) {
        // Keywords
        style = theme['keyword'] ?? baseStyle;
      } else if (RegExp(r'\b(?:int|double|String|bool|List|Map|Set|Object|Future|Stream|Iterable|Widget|StatelessWidget|StatefulWidget|BuildContext|MaterialApp|Scaffold)\b').hasMatch(matchText)) {
        // Built-in types
        style = theme['built_in'] ?? baseStyle;
      } else if (RegExp(r'\b\d+\.?\d*[eE]?[+-]?\d*\b').hasMatch(matchText)) {
        // Numbers
        style = theme['number'] ?? baseStyle;
      } else if (RegExp(r'[a-zA-Z_]\w*\s*(?=\()').hasMatch(matchText)) {
        // Functions
        style = theme['function'] ?? baseStyle;
      } else {
        // Variables/Identifiers
        style = theme['variable'] ?? baseStyle;
      }

      spans.add(TextSpan(text: matchText, style: style));
      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < line.length) {
      spans.add(TextSpan(
        text: line.substring(lastEnd),
        style: baseStyle,
      ));
    }

    return spans;
  }

  static TextSpan _highlightJavaScript(String code, Map<String, TextStyle> theme, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final lines = code.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      spans.addAll(_parseJavaScriptLine(line, theme, baseStyle));
      if (i < lines.length - 1) {
        spans.add(TextSpan(text: '\n', style: baseStyle));
      }
    }
    
    return TextSpan(children: spans);
  }

  static List<TextSpan> _parseJavaScriptLine(String line, Map<String, TextStyle> theme, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final RegExp patterns = RegExp(
      r'(?:'
      r'//.*?$|'                                    // Single line comments
      r'/\*.*?\*/|'                                 // Multi-line comments
      r'"(?:[^"\\]|\\.)*"|'                        // Double quoted strings
      r"'(?:[^'\\]|\\.)*'|"                        // Single quoted strings
      r'`(?:[^`\\]|\\.)*`|'                        // Template literals
      r'\b(?:abstract|arguments|await|boolean|break|byte|case|catch|char|class|const|continue|debugger|default|delete|do|double|else|enum|eval|export|extends|false|final|finally|float|for|function|goto|if|implements|import|in|instanceof|int|interface|let|long|native|new|null|package|private|protected|public|return|short|static|super|switch|synchronized|this|throw|throws|transient|true|try|typeof|var|void|volatile|while|with|yield)\b|' // JS keywords
      r'\b\d+\.?\d*\b|'                           // Numbers
      r'[a-zA-Z_$]\w*\s*(?=\()|'                  // Function calls
      r'[a-zA-Z_$]\w*'                            // Identifiers
      r')',
      multiLine: true,
    );

    int lastEnd = 0;
    for (final match in patterns.allMatches(line)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: line.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      final matchText = match.group(0)!;
      TextStyle style = baseStyle;

      if (matchText.startsWith('//') || matchText.startsWith('/*')) {
        style = theme['comment'] ?? baseStyle;
      } else if (matchText.startsWith('"') || matchText.startsWith("'") || matchText.startsWith('`')) {
        style = theme['string'] ?? baseStyle;
      } else if (RegExp(r'\b(?:abstract|arguments|await|boolean|break|byte|case|catch|char|class|const|continue|debugger|default|delete|do|double|else|enum|eval|export|extends|false|final|finally|float|for|function|goto|if|implements|import|in|instanceof|int|interface|let|long|native|new|null|package|private|protected|public|return|short|static|super|switch|synchronized|this|throw|throws|transient|true|try|typeof|var|void|volatile|while|with|yield)\b').hasMatch(matchText)) {
        style = theme['keyword'] ?? baseStyle;
      } else if (RegExp(r'\b\d+\.?\d*\b').hasMatch(matchText)) {
        style = theme['number'] ?? baseStyle;
      } else if (RegExp(r'[a-zA-Z_$]\w*\s*(?=\()').hasMatch(matchText)) {
        style = theme['function'] ?? baseStyle;
      }

      spans.add(TextSpan(text: matchText, style: style));
      lastEnd = match.end;
    }

    if (lastEnd < line.length) {
      spans.add(TextSpan(
        text: line.substring(lastEnd),
        style: baseStyle,
      ));
    }

    return spans;
  }

  static TextSpan _highlightJson(String code, Map<String, TextStyle> theme, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final RegExp patterns = RegExp(
      r'(?:'
      r'"[^"]*"(?=\s*:)|'                         // Keys
      r'"[^"]*"(?!\s*:)|'                         // String values
      r'\b(?:true|false|null)\b|'                 // Boolean/null values
      r'\b\d+\.?\d*\b|'                           // Numbers
      r'[{}[\],:"]'                               // Punctuation
      r')',
      multiLine: true,
    );

    int lastEnd = 0;
    for (final match in patterns.allMatches(code)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: code.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      final matchText = match.group(0)!;
      TextStyle style = baseStyle;

      if (matchText.startsWith('"') && RegExp(r'"[^"]*"(?=\s*:)').hasMatch(matchText)) {
        style = theme['property'] ?? baseStyle; // JSON keys
      } else if (matchText.startsWith('"')) {
        style = theme['string'] ?? baseStyle;   // JSON string values
      } else if (RegExp(r'\b(?:true|false|null)\b').hasMatch(matchText)) {
        style = theme['literal'] ?? baseStyle;  // Boolean/null
      } else if (RegExp(r'\b\d+\.?\d*\b').hasMatch(matchText)) {
        style = theme['number'] ?? baseStyle;   // Numbers
      }

      spans.add(TextSpan(text: matchText, style: style));
      lastEnd = match.end;
    }

    if (lastEnd < code.length) {
      spans.add(TextSpan(
        text: code.substring(lastEnd),
        style: baseStyle,
      ));
    }

    return TextSpan(children: spans);
  }

  static TextSpan _highlightHtml(String code, Map<String, TextStyle> theme, TextStyle baseStyle) {
    // Simple HTML highlighting - can be expanded
    return TextSpan(
      text: code,
      style: baseStyle,
    );
  }

  static TextSpan _highlightCss(String code, Map<String, TextStyle> theme, TextStyle baseStyle) {
    // Simple CSS highlighting - can be expanded
    return TextSpan(
      text: code,
      style: baseStyle,
    );
  }

  static String getLanguageFromFilename(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'dart': return 'dart';
      case 'js': return 'javascript';
      case 'ts': return 'typescript';
      case 'jsx': return 'javascript';
      case 'tsx': return 'typescript';
      case 'html': return 'html';
      case 'css': return 'css';
      case 'scss': return 'scss';
      case 'json': return 'json';
      case 'md': return 'markdown';
      case 'py': return 'python';
      case 'java': return 'java';
      case 'kt': return 'kotlin';
      case 'swift': return 'swift';
      case 'go': return 'go';
      case 'rs': return 'rust';
      case 'cpp': return 'cpp';
      case 'c': return 'c';
      case 'cs': return 'csharp';
      case 'php': return 'php';
      case 'rb': return 'ruby';
      case 'sh': return 'bash';
      case 'yml': 
      case 'yaml': return 'yaml';
      case 'xml': return 'xml';
      case 'sql': return 'sql';
      default: return 'plaintext';
    }
  }
}