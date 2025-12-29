import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class GoogleDrivePlayer extends StatefulWidget {
  final String fileId;
  final String title;

  const GoogleDrivePlayer({
    super.key,
    required this.fileId,
    this.title = 'Video Player',
  });

  @override
  State<GoogleDrivePlayer> createState() => _GoogleDrivePlayerState();
}

class _GoogleDrivePlayerState extends State<GoogleDrivePlayer> {
  late InAppWebViewController webViewController;
  double progress = 0;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    // Google Drive embed URL format
    final embedUrl = 'https://drive.google.com/file/d/${widget.fileId}/preview';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(embedUrl)),
            initialSettings: InAppWebViewSettings(
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              useHybridComposition: true,
              javaScriptEnabled: true,
              domStorageEnabled: true,
              databaseEnabled: true,
              supportZoom: false,
              builtInZoomControls: false,
              displayZoomControls: false,
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true;
              });
            },
            onLoadStop: (controller, url) {
              setState(() {
                isLoading = false;
              });
            },
            onProgressChanged: (controller, newProgress) {
              setState(() {
                progress = newProgress / 100;
              });
            },
            onConsoleMessage: (controller, consoleMessage) {
              print('Console: ${consoleMessage.message}');
            },
          ),
          if (isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading video... ${(progress * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
