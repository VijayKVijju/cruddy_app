import '../entities/decoded_message.dart';
import '../repositories/audio_repository.dart';

class DecodeAudioMessage {
  final AudioRepository repo;
  const DecodeAudioMessage(this.repo);

  Future<DecodedMessage> call(String assetPath) {
    return repo.decodeFromAsset(assetPath);
  }
}
