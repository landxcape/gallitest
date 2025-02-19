import 'package:flutter/material.dart';
import 'package:gallitest/presentation/pages/widgets/map_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(),
    );
  }
}
