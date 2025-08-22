import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/decoded_message.dart';
import '../../domain/repositories/audio_repository.dart';
import '../datasources/audio_decoder.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioDecoder _decoder;
  const AudioRepositoryImpl(this._decoder);

  @override
  Future<DecodedMessage> decodeFromAsset(String assetPath) async {
    final bd = await rootBundle.load(assetPath);
    final bytes = bd.buffer.asUint8List();

    final parsed = _parsePcmWav(bytes);
    final res = _decoder.decode(parsed.samples, parsed.sampleRate);

    return DecodedMessage(text: res.text, peaks: res.detectedFreqs);
  }

  ({List<double> samples, int sampleRate}) _parsePcmWav(Uint8List data) {
    final b = ByteData.sublistView(data);

    String _tag(int off) =>
        String.fromCharCodes(data.sublist(off, off + 4));
    if (_tag(0) != 'RIFF' || _tag(8) != 'WAVE') {
      throw StateError('Not a RIFF/WAVE file');
    }

    int pos = 12;
    int? sampleRate;
    int? numChannels;
    int? bitsPerSample;
    int dataOffset = -1;
    int dataSize = 0;

    while (pos + 8 <= data.length) {
      final id = _tag(pos);
      final size = b.getUint32(pos + 4, Endian.little);
      pos += 8;

      if (id == 'fmt ') {
        final audioFormat = b.getUint16(pos + 0, Endian.little);
        numChannels = b.getUint16(pos + 2, Endian.little);
        sampleRate = b.getUint32(pos + 4, Endian.little);
        bitsPerSample = b.getUint16(pos + 14, Endian.little);
        if (audioFormat != 1) {
          throw StateError('Only PCM WAV supported');
        }
      } else if (id == 'data') {
        dataOffset = pos;
        dataSize = size;
      }

      pos += size;
    }

    if (sampleRate == null ||
        numChannels == null ||
        bitsPerSample == null ||
        dataOffset < 0) {
      throw StateError('Invalid WAV');
    }

    final bytesPerSample = bitsPerSample ~/ 8;
    final totalSamples = dataSize ~/ (bytesPerSample * numChannels);
    final out = List<double>.filled(totalSamples, 0);

    int readPos = dataOffset;
    for (int i = 0; i < totalSamples; i++) {
      double acc = 0;
      for (int ch = 0; ch < numChannels; ch++) {
        if (bitsPerSample == 16) {
          final v = b.getInt16(readPos, Endian.little);
          acc += v / 32768.0;
        } else if (bitsPerSample == 32) {
          final v = b.getInt32(readPos, Endian.little);
          acc += v / 2147483648.0;
        } else {
          throw StateError('Unsupported bitsPerSample: $bitsPerSample');
        }
        readPos += bytesPerSample;
      }
      out[i] = acc / numChannels;
    }

    return (samples: out, sampleRate: sampleRate!);
  }
}
