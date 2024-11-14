import 'package:flutter/material.dart';

import 'config/routes.dart';
import 'service/pedometer_service.dart';
import 'ui/main_page.dart';

void main() {
  PedometerService.instance.init();
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        Routes.main: (_) => const MainPage(),
      },
      initialRoute: Routes.main,
    );
  }
}
