import 'dart:math' as math;

class AudioDecoder {
  AudioDecoder();

  static const Map<String, double> _charToFreq = {
    "A": 440,
    "B": 350,
    "C": 260,
    "D": 474,
    "E": 492,
    "F": 401,
    "G": 584,
    "H": 553,
    "I": 582,
    "J": 525,
    "K": 501,
    "L": 532,
    "M": 594,
    "N": 599,
    "O": 528,
    "P": 539,
    "Q": 675,
    "R": 683,
    "S": 698,
    "T": 631,
    "U": 628,
    "V": 611,
    "W": 622,
    "X": 677,
    "Y": 688,
    "Z": 693,
    " ": 418,
  };

  static final List<double> _targetFreqs = _charToFreq.values.toList();
  static final Map<double, String> _freqToChar =
  {for (final e in _charToFreq.entries) e.value: e.key};

  ({String text, List<double> detectedFreqs}) decode(
      List<double> samples, int sampleRate) {
    final env = _shortTimeEnergy(samples, (0.02 * sampleRate).round());
    final thr = env.reduce(math.max) * 0.25;

    final voicedRanges = _rangesAboveThreshold(
      env,
      thr,
      hop: (0.02 * sampleRate).round(),
      minLenSamples: (0.18 * sampleRate).round(),
    );

    final letterLen = (0.30 * sampleRate).round();
    final detected = <double>[];
    final decoded = StringBuffer();

    for (final r in voicedRanges) {
      final center = ((r.$1 + r.$2) ~/ 2).clamp(0, samples.length - 1);
      final start =
      (center - letterLen ~/ 2).clamp(0, samples.length - letterLen);
      final window = samples.sublist(start, start + letterLen);

      final win = _hann(window.length);
      for (var i = 0; i < window.length; i++) {
        window[i] *= win[i];
      }

      double bestFreq = _targetFreqs.first;
      double bestPow = double.negativeInfinity;
      for (final f in _targetFreqs) {
        final p = _goertzelPower(window, f, sampleRate);
        if (p > bestPow) {
          bestPow = p;
          bestFreq = f;
        }
      }
      detected.add(bestFreq);
      decoded.write(_freqToChar[bestFreq] ?? '?');
    }

    return (text: decoded.toString(), detectedFreqs: detected);
  }



  static List<double> _shortTimeEnergy(List<double> x, int frame) {
    final hop = frame;
    final out = <double>[];
    for (int i = 0; i + frame <= x.length; i += hop) {
      double s = 0;
      for (int n = 0; n < frame; n++) {
        final v = x[i + n];
        s += v * v;
      }
      out.add(s);
    }
    return out;
  }

  static List<(int, int)> _rangesAboveThreshold(
      List<double> env,
      double thr, {
        required int hop,
        required int minLenSamples,
      }) {
    final out = <(int, int)>[];
    bool inRange = false;
    int start = 0;

    for (int i = 0; i < env.length; i++) {
      final above = env[i] > thr;
      if (above && !inRange) {
        inRange = true;
        start = i * hop;
      } else if (!above && inRange) {
        inRange = false;
        final end = i * hop;
        if (end - start >= minLenSamples) {
          out.add((start, end));
        }
      }
    }
    if (inRange) {
      final end = env.length * hop;
      if (end - start >= minLenSamples) out.add((start, end));
    }
    return out;
  }

  static List<double> _hann(int n) {
    final w = List<double>.filled(n, 0);
    for (int i = 0; i < n; i++) {
      w[i] = 0.5 * (1 - math.cos(2 * math.pi * i / (n - 1)));
    }
    return w;
  }

  static double _goertzelPower(List<double> x, double targetFreq, int fs) {
    final w = 2 * math.pi * targetFreq / fs;
    final coeff = 2 * math.cos(w);
    double s0 = 0, s1 = 0, s2 = 0;
    for (final v in x) {
      s0 = v + coeff * s1 - s2;
      s2 = s1;
      s1 = s0;
    }
    return s1 * s1 + s2 * s2 - coeff * s1 * s2;
  }
}
