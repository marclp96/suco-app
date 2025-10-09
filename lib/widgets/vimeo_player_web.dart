import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'package:flutter/material.dart';

class VimeoPlayerWidget extends StatelessWidget {
  final String videoId;
  final bool autoPlay;

  const VimeoPlayerWidget({
    super.key,
    required this.videoId,
    this.autoPlay = true,
  });

  @override
  Widget build(BuildContext context) {
    final viewType = 'vimeo-iframe-$videoId';
    
    ui.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = 'https://player.vimeo.com/video/$videoId?autoplay=${autoPlay ? 1 : 0}'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      },
    );
    
    return HtmlElementView(viewType: viewType);
  }
}
