// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;

/// Registra un iframe limpio de Vimeo para Flutter Web y devuelve el viewType
String registerVimeoIframe(
  String videoId, {
  bool autoPlay = false, // 👈 por defecto apagado
  bool loop = false,
}) {
  final viewType = 'vimeo-iframe-$videoId';

  // Evita registrar duplicados (por hot reload)
  try {
    ui.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final iframe = web.HTMLIFrameElement()
          ..src =
              'https://player.vimeo.com/video/$videoId?autoplay=0&loop=${loop ? 1 : 0}&title=0&byline=0&portrait=0&transparent=0' // 👈 autoplay forzado en 0
          ..style.border = 'none'
          ..style.margin = '0'
          ..style.padding = '0'
          ..style.backgroundColor = 'transparent'
          ..style.width = '100%'
          ..style.height = '100%'
          ..setAttribute('allow', 'fullscreen; picture-in-picture') // 👈 sin autoplay
          ..setAttribute('allowfullscreen', 'true')
          ..setAttribute('loading', 'lazy')
          ..id = viewType;
        return iframe;
      },
    );
  } catch (_) {
    // Ignorar si ya está registrado
  }

  return viewType;
}
