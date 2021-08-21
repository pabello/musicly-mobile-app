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

class LikeStatusDTO {
  LikeStatusDTO(this._recordingId, this._likeStatus);

  final int _recordingId;
  final int _likeStatus;

  int get recordingId => _recordingId;
  int get likeStatus => _likeStatus;
}
