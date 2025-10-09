import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
    
    final url = 'https://player.vimeo.com/video/${widget.videoId}?autoplay=${widget.autoPlay ? 1 : 0}&title=0&byline=0&portrait=0';
    
    _controller = WebViewController()
      ..setBackgroundColor(const Color(0x00000000))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: WebViewWidget(controller: _controller),
    );
  }
}
