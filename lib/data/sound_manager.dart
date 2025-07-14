import 'package:just_audio/just_audio.dart';

class SoundManager {
  final clickPlayer = AudioPlayer();
  final levelWinPlayer = AudioPlayer();
  final buzzPlayer = AudioPlayer();

  void setup() {
    clickPlayer.setAsset('assets/audio/click-click.wav');
    levelWinPlayer.setAsset('assets/audio/click2.wav');
    buzzPlayer.setAsset('assets/audio/buzz.wav');
  }

  void playLevelCompleteSound() async {
    clickPlayer.stop();
    await clickPlayer.seek(Duration.zero);
    await clickPlayer.play();
    await clickPlayer.stop();
  }

  void playCorrectChoiceSound() async {
    levelWinPlayer.stop();
    await levelWinPlayer.seek(Duration.zero);
    await levelWinPlayer.play();
    await levelWinPlayer.stop();
  }

  void playBuzzSound() async {
    buzzPlayer.stop();
    await buzzPlayer.seek(Duration.zero);
    await buzzPlayer.play();
    await buzzPlayer.stop();
  }
}
