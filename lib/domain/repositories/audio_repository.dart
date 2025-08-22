import '../entities/decoded_message.dart';

abstract class AudioRepository {
  Future<DecodedMessage> decodeFromAsset(String assetPath);
}
