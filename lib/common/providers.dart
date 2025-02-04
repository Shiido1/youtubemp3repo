import 'package:mp3_music_converter/screens/bookworm/provider/bookworm_provider.dart';
import 'package:mp3_music_converter/screens/change_password/provider/change_password_provider.dart';
import 'package:mp3_music_converter/screens/converter/provider/converter_provider.dart';
import 'package:mp3_music_converter/screens/login/provider/login_provider.dart';
import 'package:mp3_music_converter/screens/otp/provider/otp_provider.dart';
import 'package:mp3_music_converter/screens/search_follow/search_provider.dart';
import 'package:mp3_music_converter/screens/recorded/provider/record_provider.dart';
import 'package:mp3_music_converter/screens/signup/provider/sign_up_provider.dart';
import 'package:mp3_music_converter/screens/split/provider/split_song_provider.dart';
import 'package:mp3_music_converter/screens/split/split_loader.dart';
import 'package:mp3_music_converter/screens/world_radio/provider/radio_play_provider.dart';
import 'package:mp3_music_converter/screens/world_radio/provider/radio_provider.dart';
import 'package:mp3_music_converter/utils/helper/timer_helper.dart';
import 'package:mp3_music_converter/screens/song/provider/music_provider.dart';
import 'package:mp3_music_converter/widgets/red_background_backend/provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:mp3_music_converter/screens/search_follow/search_user_profile/provider.dart';

class Providers {
  static List<SingleChildWidget> getProviders = [
    ChangeNotifierProvider<LoginProviders>(create: (_) => LoginProviders()),
    ChangeNotifierProvider<SignUpProviders>(create: (_) => SignUpProviders()),
    ChangeNotifierProvider<OtpProviders>(create: (_) => OtpProviders()),
    ChangeNotifierProvider<UtilityProvider>(create: (_) => UtilityProvider()),
    ChangeNotifierProvider<BookwormProvider>(create: (_) => BookwormProvider()),
    ChangeNotifierProvider<ConverterProvider>(
        create: (_) => ConverterProvider()),
    ChangeNotifierProvider<RadioProvider>(create: (_) => RadioProvider()),
    ChangeNotifierProvider<MusicProvider>(create: (_) => MusicProvider()),
    ChangeNotifierProvider<RadioPlayProvider>(
        create: (_) => RadioPlayProvider()),
    ChangeNotifierProvider<SplitLoaderProvider>(
        create: (_) => SplitLoaderProvider()),
    ChangeNotifierProvider<SplitSongProvider>(
        create: (_) => SplitSongProvider()),
    ChangeNotifierProvider<RecordProvider>(create: (_) => RecordProvider()),
    ChangeNotifierProvider<SearchProvider>(create: (_) => SearchProvider()),
    ChangeNotifierProvider<ChangePasswordProvider>(
        create: (_) => ChangePasswordProvider()),
    ChangeNotifierProvider<SearchUserProfileProvider>(
        create: (_) => SearchUserProfileProvider()),
    ChangeNotifierProvider<RedBackgroundProvider>(
        create: (_) => RedBackgroundProvider()),
  ];
}
