import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/iframe_registry.dart'
    if (dart.library.io) '../utils/iframe_registry_stub.dart';

class VimeoPlayerWidget extends StatefulWidget {
  final String videoId;
  final bool autoPlay;
  final bool loop;

  const VimeoPlayerWidget({
    Key? key,
    required this.videoId,
    this.autoPlay = true,
    this.loop = false,
  }) : super(key: key);

  @override
  State<VimeoPlayerWidget> createState() => _VimeoPlayerWidgetState();
}

class _VimeoPlayerWidgetState extends State<VimeoPlayerWidget> {
  late final WebViewController _controller;
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
              if (mounted) {
                setState(() => _isLoading = false);
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      final viewType = registerVimeoIframe(
        widget.videoId,
        autoPlay: widget.autoPlay,
        loop: widget.loop,
      );
      return HtmlElementView(viewType: viewType);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: WebViewWidget(controller: _controller),
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}
