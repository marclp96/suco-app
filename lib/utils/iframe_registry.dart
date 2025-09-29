import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;

/// Registra un iframe dinámico de Vimeo para Flutter Web
void registerVimeoIframe({required String videoId, bool autoPlay = true}) {
  final viewType = 'vimeo-iframe-$videoId';

  ui.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) => web.HTMLIFrameElement()
      ..src =
          'https://player.vimeo.com/video/$videoId?autoplay=${autoPlay ? 1 : 0}&title=0&byline=0&portrait=0'
      ..style.border = '0'
      ..style.margin = '0'
      ..style.padding = '0'
      ..style.background = 'transparent'
      ..style.width = '100%'
      ..style.height = '100%',
  );
}
