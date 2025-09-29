import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/iframe_registry.dart'
    if (dart.library.io) '../utils/iframe_registry_stub.dart';

class VimeoPlayerWidget extends StatefulWidget {
  final String videoId;
  final bool autoPlay;

  const VimeoPlayerWidget({
    super.key,
    required this.videoId,
    this.autoPlay = true,
  });

  @override
  State<VimeoPlayerWidget> createState() => _VimeoPlayerWidgetState();
}

class _VimeoPlayerWidgetState extends State<VimeoPlayerWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      final url =
          'https://player.vimeo.com/video/${widget.videoId}?autoplay=${widget.autoPlay ? 1 : 0}&title=0&byline=0&portrait=0';

      _controller = WebViewController()
        ..setBackgroundColor(const Color(0x00000000)) // 👈 Fondo transparente
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      registerVimeoIframe(videoId: widget.videoId, autoPlay: widget.autoPlay);
      return HtmlElementView(viewType: 'vimeo-iframe-${widget.videoId}');
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: WebViewWidget(controller: _controller),
      );
    }
  }
}
