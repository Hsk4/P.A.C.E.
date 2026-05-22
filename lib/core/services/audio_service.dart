import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> playCustomTone (String path) async{
    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(path));
  }

  static Future<void> playAssetTone(String assetPath) async{
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(assetPath));
  }

  static Future<void> stopTone() async{
    await _audioPlayer.stop();
  }
}