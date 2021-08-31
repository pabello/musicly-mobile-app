class RecordingSimpleDTO {
  RecordingSimpleDTO(this._id, this._title, this._length);

  final int _id;
  final String _title;
  final int _length;

  int get id => _id;

  String get title => _title;

  int get length => _length;

  int getLengthMinutes() {
    return ((_length / 1000).floor() / 60).floor();
  }

  int getLengthRemainingSeconds() {
    return ((_length / 1000).floor() % 60).floor();
  }

  String lengthStringParse() {
    if (_length != null) {
      final String strLength = '${getLengthMinutes()}:'
          '${getLengthRemainingSeconds().toString().padLeft(2, '0')}';
      return strLength;
    } else {
      return 'unknown';
    }
  }
}

class ArtistSimpleDTO {
  ArtistSimpleDTO(this._id, this._stageName);

  final int _id;
  final String _stageName;

  int get id => _id;

  String get stageName => _stageName;
}

class PlaylistSimpleDTO {
  PlaylistSimpleDTO(this._id, this.name, this.length, this.musicCount);

  final int _id;
  int length, musicCount;
  String name;

  int get id => _id;

  int getLengthMinutes() {
    return ((length / 1000).floor() / 60).floor();
  }

  int getLengthRemainingSeconds() {
    return ((length / 1000).floor() % 60).floor();
  }

  String lengthStringParse() {
    if (length != null) {
      int hours;
      int minutes = getLengthMinutes();
      if (minutes > 120) {
        hours = (minutes / 60).floor();
        minutes -= hours * 60;
      }
      String lengthStr = '';
      if (hours != null) {
        lengthStr += '$hours godz. ';
      }
      return '$lengthStr${'$minutes min.'} '
          '${'${getLengthRemainingSeconds().toString().padLeft(2, '0')} sek.'}';
    } else {
      return 'unknown';
    }
  }
}
