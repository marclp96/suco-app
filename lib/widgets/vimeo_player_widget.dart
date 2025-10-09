// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui; // 👈 ESTE IMPORT ES CLAVE
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VimeoPlayerWidget extends StatefulWidget {
  final String videoId;
  final bool autoPlay;
  final bool loop;

  const VimeoPlayerWidget({
    Key? key,
    required this.videoId,
    this.autoPlay = false, // 👈 autoplay desactivado
    this.loop = false,
  }) : super(key: key);

  @override
  VimeoPlayerWidgetState createState() => VimeoPlayerWidgetState();
}

class VimeoPlayerWidgetState extends State<VimeoPlayerWidget> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      final url =
          'https://player.vimeo.com/video/${widget.videoId}?autoplay=${widget.autoPlay ? 1 : 0}&loop=${widget.loop ? 1 : 0}&title=0&byline=0&portrait=0&transparent=0';

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => _isLoading = false);
            },
          ),
        )
        ..loadRequest(Uri.parse(url));
    }
  }

  /// 👇 Pausa el video (para evitar solapamiento)
  void pauseVideo() {
    try {
      if (kIsWeb) {
        final iframe = html.document.getElementById('vimeo-iframe-${widget.videoId}')
            as html.IFrameElement?;
        if (iframe != null) {
          iframe.contentWindow?.postMessage({'method': 'pause'}, '*');
          debugPrint('⏸️ Vimeo iframe paused via postMessage');
        }
      } else {
        _controller?.runJavaScript('player && player.pause && player.pause();');
      }
    } catch (e) {
      debugPrint("❌ Error pausing Vimeo video: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      final viewType = 'vimeo-iframe-${widget.videoId}';

      // 👇 Registro del iframe para Web
      ui.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src =
                'https://player.vimeo.com/video/${widget.videoId}?autoplay=0&loop=${widget.loop ? 1 : 0}&title=0&byline=0&portrait=0&transparent=0'
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..id = viewType;
          return iframe;
        },
      );

      return HtmlElementView(viewType: viewType);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: WebViewWidget(controller: _controller!),
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}
