// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;

/// Registra un iframe limpio de Vimeo para Flutter Web y devuelve el viewType
String registerVimeoIframe(
  String videoId, {
  bool autoPlay = true,
  bool loop = false,
}) {
  final viewType = 'vimeo-iframe-$videoId';

  // Si ya estaba registrado, no lo volvemos a registrar (evita error en hot reload)
  try {
    ui.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final iframe = web.HTMLIFrameElement()
          ..src =
              'https://player.vimeo.com/video/$videoId?autoplay=${autoPlay ? 1 : 0}&loop=${loop ? 1 : 0}&title=0&byline=0&portrait=0&transparent=0'
          ..style.border = 'none'
          ..style.margin = '0'
          ..style.padding = '0'
          ..style.backgroundColor = 'transparent'
          ..style.width = '100%'
          ..style.height = '100%'
          ..setAttribute('allow', 'autoplay; fullscreen; picture-in-picture')
          ..setAttribute('allowfullscreen', 'true')
          ..setAttribute('loading', 'lazy');
        return iframe;
      },
    );
  } catch (_) {
    // Silenciar si ya está registrado
  }

  return viewType;
}
