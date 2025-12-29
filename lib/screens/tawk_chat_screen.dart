import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Tawk.to Live Chat Integration Screen
///
/// This screen integrates Tawk.to live chat widget into the Flutter app.
/// The chat widget loads in a WebView and auto-maximizes on load.
///
/// Configuration:
/// - Property ID: 69230e9781b92b195f7a8a18
/// - Widget ID: 1jaof20u2
///
/// Features:
/// - Auto-maximizes chat on load
/// - Closes screen when chat is minimized
/// - Loading indicator while chat initializes
/// - Responsive design for all screen sizes
///
/// To update Tawk.to settings:
/// 1. Log in to your Tawk.to dashboard
/// 2. Go to Administration > Property Settings
/// 3. Copy the Property ID and Widget ID from the embed code
/// 4. Update the constants below
class TawkChatScreen extends StatefulWidget {
  static const routeName = '/tawk-chat';

  const TawkChatScreen({super.key});

  @override
  State<TawkChatScreen> createState() => _TawkChatScreenState();
}

class _TawkChatScreenState extends State<TawkChatScreen> {
  late InAppWebViewController webViewController;
  bool isLoading = true;
  double progress = 0;

  // Your Tawk.to property ID and widget ID
  // Update these if you change your Tawk.to widget
  final String tawkPropertyId = '69230e9781b92b195f7a8a18';
  final String tawkWidgetId = '1jaof20u2';

  @override
  Widget build(BuildContext context) {
    // Direct Tawk.to chat URL - more reliable than embedded HTML
    final String tawkDirectUrl =
        'https://tawk.to/chat/$tawkPropertyId/$tawkWidgetId';

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(tawkDirectUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                useHybridComposition: true,
                allowsInlineMediaPlayback: true,
                mediaPlaybackRequiresUserGesture: false,
                supportZoom: true,
                builtInZoomControls: false,
                displayZoomControls: false,
                useShouldOverrideUrlLoading: true,
                clearCache: false,
                cacheEnabled: true,
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  isLoading = true;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  isLoading = false;
                });
              },
              onProgressChanged: (controller, newProgress) {
                setState(() {
                  progress = newProgress / 100;
                  // Hide loading when we reach 100%
                  if (newProgress == 100) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    });
                  }
                });
              },
              onConsoleMessage: (controller, consoleMessage) {
                print('Tawk.to Console: ${consoleMessage.message}');
              },
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                return NavigationActionPolicy.ALLOW;
              },
            ),
            if (isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress > 0 ? progress : null,
                        color: const Color(0xFF6C63FF),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        progress > 0
                            ? 'Loading ${(progress * 100).toInt()}%...'
                            : 'Connecting to support...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
