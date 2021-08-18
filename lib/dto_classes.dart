class RecordingSimpleDTO {
  RecordingSimpleDTO(this.id, this.title, this.length);

  final int id;
  final String title;
  final int length;

  int getLengthMinutes() {
    return ((length / 1000).floor() / 60).floor();
  }

  int getLengthRemainingSeconds() {
    return ((length / 1000).floor() % 60).floor();
  }

  String lengthStringParse() {
    final int secondsLength = (length / 1000).floor();
    final String strLength = '${getLengthMinutes()}:'
        '${getLengthRemainingSeconds().toString().padLeft(2, '0')}';
    return strLength;
  }
}
