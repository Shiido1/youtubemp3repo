import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:mp3_music_converter/screens/converter/convert.dart';
import 'package:mp3_music_converter/screens/converter/model/youtube_model.dart';
import 'package:mp3_music_converter/utils/color_assets/color.dart';
import 'package:mp3_music_converter/utils/string_assets/assets.dart';
import 'package:mp3_music_converter/widgets/bottom_playlist_indicator.dart';
import 'package:mp3_music_converter/widgets/text_view_widget.dart';

class SongViewCLass extends StatefulWidget {
  @override
  _SongViewCLassState createState() => _SongViewCLassState();
}

class _SongViewCLassState extends State<SongViewCLass> {
  List<Convert> convert = List();
  var save;
  bool isSet = false;
  @override
  void initState() {
    super.initState();
    openDb();
  }

  Future<void> openDb() async {
    var saveI = await Hive.openBox('music_db');
    save.get('key');
    setState(() {
      save = saveI;
      isSet = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isSet) {
      print(save.get('key'));
    }
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.black,
        title: TextViewWidget(
          text: 'Song',
          color: AppColor.bottomRed,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_sharp,
            color: AppColor.bottomRed,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [1, 2, 3, 4, 5, 6, 7]
                    .map((mocked) => Column(
                          children: [
                            ListTile(
                              onTap: () {},
                              leading: Image.asset(AppAssets.image1),
                              title: TextViewWidget(
                                text: 'Something Fishy',
                                color: AppColor.white,
                                textSize: 18,
                              ),
                              subtitle: TextViewWidget(
                                text: 'Davido',
                                color: AppColor.white,
                                textSize: 14,
                              ),
                              trailing: SvgPicture.asset(
                                AppAssets.dot,
                                color: AppColor.white,
                              ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 70.0, right: 23),
                              child: Divider(
                                color: AppColor.white,
                              ),
                            )
                          ],
                        ))
                    .toList(),
              ),
            ),
            BottomPlayingIndicator()
          ],
        ),
      ),
    );
  }
}
