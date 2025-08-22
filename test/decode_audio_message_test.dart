import 'package:flutter_test/flutter_test.dart';
import 'package:audio_decoder_clean/data/frequency_mapper.dart';

void main() {
  test('Frequency mapping tolerance', () {
    expect(FrequencyMapper.charFromFrequency(440.0), 'A');
    // within tolerance
    expect(FrequencyMapper.charFromFrequency(446.0), 'A');
    expect(FrequencyMapper.charFromFrequency(631.0), 'T');
    // outside tolerance -> '?'
    expect(FrequencyMapper.charFromFrequency(460.0), '?');
  });
}
