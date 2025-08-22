import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/decode_controller.dart';

class DecodePage extends ConsumerWidget {
  const DecodePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(decodeControllerProvider);

    final bg = const Color(0xff2f9fe8);
    final fg = Colors.purple;
    final accent = Colors.lightBlue;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Audio Decoder'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ref.read(decodeControllerProvider.notifier).decode(),
        child: const Icon(Icons.play_arrow_rounded),
      ),
      body: Center(
        child: state.when(
          data: (msg) {
            if (msg == null) {
              return _hint(accent, fg);
            }
            return _resultCard(msg.text, msg.peaks, accent, fg);
          },
          error: (e, _) => Text(
            'Error: $e',
            style: const TextStyle(color: Colors.redAccent),
          ),
          loading: () => const CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _hint(Color accent, Color fg) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Tap ▶ to decode the hidden message from the WAV asset.',
        style: TextStyle(color: fg),
      ),
    );
  }

  Widget _resultCard(String text, List<double> freqs, Color accent, Color fg) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: fg, fontSize: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Hidden message decoded!',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(text),
            const SizedBox(height: 12),
            Text('Detected tones (Hz): ${freqs.map((f) => f.toStringAsFixed(0)).join(', ')}'),
          ],
        ),
      ),
    );
  }
}
