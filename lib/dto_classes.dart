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
    if(_length != null) {
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
  PlaylistSimpleDTO(this._id, this._name, this._length, this._musicCount);

  final int _id, _length, _musicCount;
  final String _name;

  int get id => _id;
  int get length => _length;
  int get musicCount => _musicCount;
  String get name => _name;

  int getLengthMinutes() {
    return ((_length / 1000).floor() / 60).floor();
  }

  int getLengthRemainingSeconds() {
    return ((_length / 1000).floor() % 60).floor();
  }

  String lengthStringParse() {
    if(_length != null) {
      final String strLength = '${getLengthMinutes()}:'
          '${getLengthRemainingSeconds().toString().padLeft(2, '0')}';
      return strLength;
    } else {
      return 'unknown';
    }
  }
}
