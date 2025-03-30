import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final WebViewController controller;
  bool isLoading = true;
  bool showSplash = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Enable JavaScript
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => isLoading = true);
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
              Future.delayed(Duration(milliseconds: 500), () {
                setState(() => showSplash = false);
              });
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://hu-stu-lectures.vercel.app'));

    // Keep splash screen visible until WebView is fully loaded
    Future.delayed(Duration(seconds: 3), () {
      if (isLoading) return;
      setState(() => showSplash = false);
    });
  }

  // Handle back button navigation
  Future<bool> _onWillPop() async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return false; // Stay in app
    }
    return true; // Exit app
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide debug banner
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      home: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('HU LECTURES'),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () => controller.reload(),
              ),
            ],
          ),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          WebViewWidget(controller: controller),
                          if (isLoading) Center(child: CircularProgressIndicator()),
                        ],
                      ),
                    ),
                    Container(
                      height: 34, // For bottom notch
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              if (showSplash) SplashScreen(),
            ],
          ),
        ),
      ),
    );
  }
}

// Splash screen with fade-out effect
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _opacity = Tween<double>(begin: 1, end: 0).animate(_controller);

    Future.delayed(Duration(seconds: 3), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/1.png', width: 150),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
