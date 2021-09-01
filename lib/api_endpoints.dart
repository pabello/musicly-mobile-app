class ApiEndpoints {
  static const String _protocol = 'http';
  static const String _address = '10.0.2.2:8001';
  // static const String _address = '127.0.0.1:8000';

  static const String register = '$_protocol://$_address/api/register/';
  static const String login = '$_protocol://$_address/api/login/';
  static const String resetPassword = '$_protocol://$_address/api/resetPassword/';
  static const String changePassword = '$_protocol://$_address/api/changePassword/';

  static const String accountDetails = '$_protocol://$_address/api/account/';
  static const String changeUsername = '$_protocol://$_address/api/changeUsername/';
  static const String sendConfirmationMail = '$_protocol://$_address/api/confirmationMail/';
  static const String deleteAccount = '$_protocol://$_address/api/account/delete/';

  static const String artistList = '$_protocol://$_address/api/artist/';
  static const String artistDetails = '$_protocol://$_address/api/artist/';
  static const String recordingList = '$_protocol://$_address/api/recording/';
  static const String recordingDetails = '$_protocol://$_address/api/recording/';
  static const String playlistList = '$_protocol://$_address/api/playlist/filtered_list/';
  static const String playlistDetails = '$_protocol://$_address/api/playlist/';
  static const String createPlaylist = '$_protocol://$_address/api/playlist/';
  static const String addToPlaylist = '$_protocol://$_address/api/playlistMusic/';
  static const String changePlaylistPosition = '$_protocol://$_address/api/playlistMusic/';
  static const String deleteFromPlaylist = '$_protocol://$_address/api/playlistMusic/';
  static const String deletePlaylist = '$_protocol://$_address/api/playlist/';
  static const String userMusicList = '$_protocol://$_address/api/userMusic/';
  static const String musicReaction = '$_protocol://$_address/api/userMusic/';
  static const String recommendationList = '$_protocol://$_address/api/recommendations/';
  static const String nextRecommendation = '$_protocol://$_address/api/recommendation/';
}