import 'package:flutter/material.dart';
import 'package:gallitest/app/root_app.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RootApp();
  }
}
