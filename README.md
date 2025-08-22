# Hidden Audio Decoder (Flutter • Clean Architecture)

This app decodes a secret text message embedded in a WAV file where each character
is a tone (~300ms) separated by ~100ms silence. FFT detects the dominant frequency
per window which is mapped back to characters via a fixed dictionary.

## Architecture
- Domain
    - Entity: DecodedMessage
    - Use case: DecodeAudioMessage
    - Repository interface: AudioRepository
- Data
    - Data source: AudioDecoder (WAV parsing + FFT)
    - FrequencyMapper (freq -> char with ±10Hz tolerance)
    - Repository impl: AudioRepositoryImpl
- Presentation
    - State: Riverpod StateNotifier (decodeController)
    - UI: DecodePage with play/stop + decode button
    - Visualization: simple bar chart for per-symbol frequencies

## Packages
- wav — parse PCM WAV from assets
- fft — 1D FFT in Dart (zero-padded, Hann window)
- just_audio — playback
- flutter_riverpod — state management

## How it works
1) Load `assets/audio/hidden_message.wav`
2) Split the signal into windows of 300ms with 400ms stride (tone+gap)
3) Apply Hann window + zero-pad to next pow2
4) FFT -> magnitude spectrum; pick max bin (ignore DC)
5) Convert bin index to frequency; map to nearest dictionary frequency
6) Concatenate chars => DecodedMessage

## Decoded Output (from given WAV)
`CRUDDY APP IS THE BEST IN THE WORLD`

## Run
flutter pub get
flutter run

## Tests
flutter test

## Limitations
- Works best with clean tones; strong noise may require adaptive thresholding.
- Fixed timing (300ms+100ms). If files vary, auto-segmentation via envelope detection is needed.
- Simple nearest-neighbour matching; could be improved with peak interpolation and tolerance per-band.

## Ideas
- Live spectrum visualizer
- Microphone live decode
- Export decoded text as file
