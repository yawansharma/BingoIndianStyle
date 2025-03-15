import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class BackgroundMusicService with ChangeNotifier {
  final AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  BackgroundMusicService(this._audioPlayer);

  bool get isPlaying => _isPlaying;

  Future<void> startMusic() async {
    if (!_isPlaying) {
      try {
        await _audioPlayer.play(AssetSource(
            'Loyalty_Freak_Music_-_01_-_Go_to_the_Picnicchosic.com_(chosic.com).mp3')); //Your background music file
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        _isPlaying = true;
        notifyListeners();
      } catch (e) {
        print('Error starting background music: $e');
      }
    }
  }

  Future<void> stopMusic() async {
    if (_isPlaying) {
      try {
        await _audioPlayer.stop();
        _isPlaying = false;
        notifyListeners();
      } catch (e) {
        print('Error stopping background music: $e');
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
