// Stub implementation for non-web platforms

class IFrameElement {
  String src = '';
  CSSStyleDeclaration get style => CSSStyleDeclaration();
  Stream<Event> get onLoad => Stream<Event>.empty();
  WindowBase? get contentWindow => null;
}

class CSSStyleDeclaration {
  String border = '';
  String width = '';
  String height = '';
}

class Event {}

class WindowBase {
  void postMessage(dynamic message, String targetOrigin) {}
}

class PlatformViewRegistry {
  void registerViewFactory(String viewId, dynamic Function(int) factory) {}
}

class Document {
  Element? querySelector(String selector) => null;
}

final platformViewRegistry = PlatformViewRegistry();
final document = Document();

class Element {}