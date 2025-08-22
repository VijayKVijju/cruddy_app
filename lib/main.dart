import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/pages/decode_page.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hidden Audio Decoder',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF978F8F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF288EE1),
          secondary: Color(0xFF7B4DFF),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const DecodePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
