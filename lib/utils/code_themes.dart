import 'package:flutter/material.dart';

class VSCodeThemes {
  // VS Code Light Theme (Default Light+)
  static Map<String, TextStyle> get lightTheme => {
    'root': const TextStyle(
      backgroundColor: Color(0xffffffff),
      color: Color(0xff000000),
      fontFamily: 'Consolas, Monaco, monospace',
      fontSize: 14,
    ),
    'comment': const TextStyle(
      color: Color(0xff008000),
      fontStyle: FontStyle.italic,
    ),
    'quote': const TextStyle(
      color: Color(0xff008000),
      fontStyle: FontStyle.italic,
    ),
    'keyword': const TextStyle(
      color: Color(0xff0000ff),
      fontWeight: FontWeight.bold,
    ),
    'selector-tag': const TextStyle(
      color: Color(0xff800000),
    ),
    'built_in': const TextStyle(
      color: Color(0xff267f99),
    ),
    'name': const TextStyle(
      color: Color(0xff267f99),
    ),
    'tag': const TextStyle(
      color: Color(0xff800000),
    ),
    'string': const TextStyle(
      color: Color(0xffa31515),
    ),
    'title': const TextStyle(
      color: Color(0xff795e26),
    ),
    'section': const TextStyle(
      color: Color(0xff795e26),
      fontWeight: FontWeight.bold,
    ),
    'attribute': const TextStyle(
      color: Color(0xff0451a5),
    ),
    'literal': const TextStyle(
      color: Color(0xff0000ff),
    ),
    'template-tag': const TextStyle(
      color: Color(0xffa31515),
    ),
    'template-variable': const TextStyle(
      color: Color(0xffa31515),
    ),
    'type': const TextStyle(
      color: Color(0xff267f99),
    ),
    'addition': const TextStyle(
      color: Color(0xff008000),
    ),
    'deletion': const TextStyle(
      color: Color(0xffa31515),
    ),
    'selector-attr': const TextStyle(
      color: Color(0xff800000),
    ),
    'selector-pseudo': const TextStyle(
      color: Color(0xff800000),
    ),
    'meta': const TextStyle(
      color: Color(0xff795e26),
    ),
    'doctag': const TextStyle(
      color: Color(0xff008000),
      fontWeight: FontWeight.bold,
    ),
    'attr': const TextStyle(
      color: Color(0xff0451a5),
    ),
    'symbol': const TextStyle(
      color: Color(0xff0451a5),
    ),
    'bullet': const TextStyle(
      color: Color(0xff0451a5),
    ),
    'link': const TextStyle(
      color: Color(0xff0451a5),
      decoration: TextDecoration.underline,
    ),
    'emphasis': const TextStyle(
      fontStyle: FontStyle.italic,
    ),
    'strong': const TextStyle(
      fontWeight: FontWeight.bold,
    ),
    'formula': const TextStyle(
      color: Color(0xff795e26),
    ),
    'params': const TextStyle(
      color: Color(0xff001080),
    ),
    'class': const TextStyle(
      color: Color(0xff267f99),
    ),
    'function': const TextStyle(
      color: Color(0xff795e26),
    ),
    'number': const TextStyle(
      color: Color(0xff09885a),
    ),
    'variable': const TextStyle(
      color: Color(0xff001080),
    ),
    'property': const TextStyle(
      color: Color(0xff001080),
    ),
  };

  // VS Code Dark Theme (Dark+)
  static Map<String, TextStyle> get darkTheme => {
    'root': const TextStyle(
      backgroundColor: Color(0xff1e1e1e),
      color: Color(0xffd4d4d4),
      fontFamily: 'Consolas, Monaco, monospace',
      fontSize: 14,
    ),
    'comment': const TextStyle(
      color: Color(0xff6a9955),
      fontStyle: FontStyle.italic,
    ),
    'quote': const TextStyle(
      color: Color(0xff6a9955),
      fontStyle: FontStyle.italic,
    ),
    'keyword': const TextStyle(
      color: Color(0xff569cd6),
      fontWeight: FontWeight.bold,
    ),
    'selector-tag': const TextStyle(
      color: Color(0xff569cd6),
    ),
    'built_in': const TextStyle(
      color: Color(0xff4ec9b0),
    ),
    'name': const TextStyle(
      color: Color(0xff4ec9b0),
    ),
    'tag': const TextStyle(
      color: Color(0xff569cd6),
    ),
    'string': const TextStyle(
      color: Color(0xffce9178),
    ),
    'title': const TextStyle(
      color: Color(0xffdcdcaa),
    ),
    'section': const TextStyle(
      color: Color(0xffdcdcaa),
      fontWeight: FontWeight.bold,
    ),
    'attribute': const TextStyle(
      color: Color(0xff9cdcfe),
    ),
    'literal': const TextStyle(
      color: Color(0xff569cd6),
    ),
    'template-tag': const TextStyle(
      color: Color(0xffce9178),
    ),
    'template-variable': const TextStyle(
      color: Color(0xffce9178),
    ),
    'type': const TextStyle(
      color: Color(0xff4ec9b0),
    ),
    'addition': const TextStyle(
      color: Color(0xff6a9955),
    ),
    'deletion': const TextStyle(
      color: Color(0xffce9178),
    ),
    'selector-attr': const TextStyle(
      color: Color(0xff569cd6),
    ),
    'selector-pseudo': const TextStyle(
      color: Color(0xff569cd6),
    ),
    'meta': const TextStyle(
      color: Color(0xffdcdcaa),
    ),
    'doctag': const TextStyle(
      color: Color(0xff6a9955),
      fontWeight: FontWeight.bold,
    ),
    'attr': const TextStyle(
      color: Color(0xff9cdcfe),
    ),
    'symbol': const TextStyle(
      color: Color(0xff9cdcfe),
    ),
    'bullet': const TextStyle(
      color: Color(0xff9cdcfe),
    ),
    'link': const TextStyle(
      color: Color(0xff9cdcfe),
      decoration: TextDecoration.underline,
    ),
    'emphasis': const TextStyle(
      fontStyle: FontStyle.italic,
    ),
    'strong': const TextStyle(
      fontWeight: FontWeight.bold,
    ),
    'formula': const TextStyle(
      color: Color(0xffdcdcaa),
    ),
    'params': const TextStyle(
      color: Color(0xff9cdcfe),
    ),
    'class': const TextStyle(
      color: Color(0xff4ec9b0),
    ),
    'function': const TextStyle(
      color: Color(0xffdcdcaa),
    ),
    'number': const TextStyle(
      color: Color(0xffb5cea8),
    ),
    'variable': const TextStyle(
      color: Color(0xff9cdcfe),
    ),
    'property': const TextStyle(
      color: Color(0xff9cdcfe),
    ),
  };

  // Get theme based on isDark flag
  static Map<String, TextStyle> getTheme(bool isDark) {
    return isDark ? darkTheme : lightTheme;
  }

  // Get background color for the theme
  static Color getBackgroundColor(bool isDark) {
    return isDark ? const Color(0xff1e1e1e) : const Color(0xffffffff);
  }

  // Get text color for the theme
  static Color getTextColor(bool isDark) {
    return isDark ? const Color(0xffd4d4d4) : const Color(0xff000000);
  }
}