import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/decoded_message.dart';
import '../../domain/usecases/decode_audio_message.dart';
import '../../data/datasources/audio_decoder.dart';
import '../../data/repositories/audio_repository_impl.dart';

final decodeControllerProvider =
StateNotifierProvider<DecodeController, AsyncValue<DecodedMessage?>>(
      (ref) {
    final decoder = AudioDecoder();
    final repo = AudioRepositoryImpl(decoder);
    final usecase = DecodeAudioMessage(repo);
    return DecodeController(usecase);
  },
);

class DecodeController extends StateNotifier<AsyncValue<DecodedMessage?>> {
  final DecodeAudioMessage _usecase;
  DecodeController(this._usecase) : super(const AsyncData(null));

  Future<void> decode() async {
    state = const AsyncLoading();
    try {
      final result =
      await _usecase('assets/audio/hidden_message.wav');
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
