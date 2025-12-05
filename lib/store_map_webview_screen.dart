import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StoreMapWebViewScreen extends StatefulWidget {
  const StoreMapWebViewScreen({super.key});

  @override
  State<StoreMapWebViewScreen> createState() => _StoreMapWebViewScreenState();
}

// 근처 찾기 화면 안에 넣어서 쓰는, 박스 형태의 지도 WebView
class InlineStoreMapWebView extends StatefulWidget {
  const InlineStoreMapWebView({super.key});

  @override
  State<InlineStoreMapWebView> createState() => _InlineStoreMapWebViewState();
}

class _InlineStoreMapWebViewState extends State<InlineStoreMapWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // 에뮬레이터 도메인 주소 그대로 사용
    const baseUrl = 'http://10.0.2.2:5001/';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (_) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
              _errorMessage =
              '에러: ${error.errorCode} / ${error.description}';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(baseUrl));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          // 실제 지도/매장 HTML
          WebViewWidget(controller: _controller),

          // 로딩 인디케이터
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // 에러 메시지
          if (_errorMessage != null)
            Container(
              color: Colors.white.withOpacity(0.9),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),

          // 전체 화면 지도 열기 버튼 (오른쪽 아래 사각형 버튼)
          Positioned(
            bottom: 8,
            right: 8,
            child: Material(
              color: Colors.white,
              elevation: 2,
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StoreMapWebViewScreen(),
                    ),
                  );
                },
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.fullscreen,
                    size: 20,
                    color: Color(0xFF2C5CD4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreMapWebViewScreenState extends State<StoreMapWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    const baseUrl = 'http://10.0.2.2:5001/';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (_) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            // 에러 발생 시 스피너 멈추고 에러 메시지 표시
            setState(() {
              _isLoading = false;
              _errorMessage =
              '에러: ${error.errorCode} / ${error.description}';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(baseUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주변 매장 지도')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          if (_errorMessage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
