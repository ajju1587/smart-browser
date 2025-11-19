import 'package:flutter/material.dart';
import 'features/browser/presentation/in_app_browser.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter AI Browser',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Scaffold(
        body: SafeArea(child: InAppBrowser(initialUrl: 'https://example.com')),
      ),
    );
  }
}
