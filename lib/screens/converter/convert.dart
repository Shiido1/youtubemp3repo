import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mp3_music_converter/database/model/log.dart';
import 'package:mp3_music_converter/database/repository/log_repository.dart';
import 'package:mp3_music_converter/screens/converter/provider/converter_provider.dart';
import 'package:mp3_music_converter/screens/dashboard/sample_dashboard.dart';
import 'package:mp3_music_converter/utils/color_assets/color.dart';
import 'package:mp3_music_converter/utils/helper/constant.dart';
import 'package:mp3_music_converter/utils/helper/helper.dart';
import 'package:mp3_music_converter/utils/string_assets/assets.dart';
import 'package:mp3_music_converter/widgets/bottom_playlist_indicator.dart';
import 'package:mp3_music_converter/widgets/red_background.dart';
import 'package:mp3_music_converter/widgets/text_view_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

const String musicPath = '.music';
bool debug = true;

class Convert extends StatefulWidget with WidgetsBindingObserver {
  final TargetPlatform platform;

  Convert({
    Key key,
    this.platform,
  }) : super(key: key);
  // loadSound() => createState()._loadSong();
  // playSound() => createState()._playSound();
  @override
  _ConvertState createState() => _ConvertState();
}

class _ConvertState extends State<Convert> {
  ConverterProvider _converterProvider;
  bool convertResult = false;
  TextEditingController controller = new TextEditingController();
  bool loading = false;
  int _progress;
  bool downloaded = false;
  int id;
  var val;
  bool _isLoading;
  bool _permissionReady;
  static String _localPath;
  ReceivePort _port = ReceivePort();
  String _fileName;

  AudioPlayer _player;
  AudioCache cache;

  Duration position = new Duration();
  Duration musicLength = new Duration();

  // Widget slider() {
  //   return Slider.adaptive(
  //       inactiveColor: AppColor.white,
  //       activeColor: AppColor.bottomRed,
  //       value: position.inSeconds.toDouble(),
  //       max: musicLength.inSeconds.toDouble(),
  //       onChanged: (value) {
  //         seekToSec(value.toInt());
  //       });
  // }

  // void seekToSec(int sec) {
  //   Duration newPos = Duration(seconds: sec);
  //   _player.seek(newPos);
  // }

  @override
  void initState() {
    super.initState();
    _converterProvider = Provider.of<ConverterProvider>(context, listen: false);
    _converterProvider.init(context);

    _bindBackgroundIsolate(); //
    FlutterDownloader.registerCallback(
        downloadCallback); // register our callbacks
    _isLoading = true;
    _permissionReady = false;
    _prepare();
  }

  @override
  void dispose() {
    controller.dispose();
    _unbindBackgroundIsolate();
    super.dispose();
  }

  // void _playSound() {
  //   AudioPlayer player = AudioPlayer();
  //   player.play(mp3);
  // }
  //
  // Future<void> _loadSong() async {
  //   final ByteData data = await rootBundle.load('$_localPath');
  //   Directory tempDir = await getTemporaryDirectory();
  //   File tempFile = File('${tempDir.path}/$_localPath');
  //   await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
  //   mp3 = tempFile.uri.toString();
  // }

  // static downloadingCallback(id, status, progress) {
  //   SendPort sendPort = IsolateNameServer.lookupPortByName('downloading');
  //   sendPort.send([id, status, progress]);
  //   _progresss = progress;
  // }

  void _download() {
    if (controller.text.isEmpty) {
      showToast(context, message: "Please input Url");
    } else {
      _converterProvider.convert('${controller.text}');
    }
  }

  // Future<bool> _checkPermission() async {
  //   if (Platform.isAndroid) {
  //     final status = await Permission.storage.status;
  //     if (status != PermissionStatus.granted) {
  //       final result = await Permission.storage.request();
  //       if (result == PermissionStatus.granted) {
  //         return true;
  //       }
  //     } else {
  //       return true;
  //     }
  //   } else {
  //     return true;
  //   }
  //   return false;
  // }

//* prepares the items we wish to download
//   Future<Null> _prepare() async {
//     _permissionReady = await _checkPermission(); // checks for users permission
//
//     _localPath = (await findLocalPath()) +
//         Platform.pathSeparator +
//         musicFolder; // gets users
//
//     final savedDir = Directory(_localPath);
//     bool hasExisted = await savedDir.exists();
//     if (!hasExisted) {
//       savedDir.create();
//     }
//
//     setState(() {
//       _isLoading = false;
//     });
//   }

  // _saveLib() async {}

  Future<void> _showDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 170, 20, 250),
            child: AlertDialog(
                backgroundColor: AppColor.white.withOpacity(0.6),
                content: Container(
                  decoration: new BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(32.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 70),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(AppAssets.check),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          'Successfully Downloaded',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: AppColor.black),
                        ),
                      ],
                    ),
                  ),
                )),
          );
        });
  }

  // Future downloadNow() async {
  //   final status = await Permission.storage.request();
  //
  //   if (status.isGranted) {
  //     final externalDir = await getExternalStorageDirectory();
  //
  //     setState(() async {
  //       storagePath = externalDir.path;
  //     });
  //
  //     final idDownloadPath = await FlutterDownloader.enqueue(
  //         url: base_url + _converterProvider?.youtubeModel?.url,
  //         savedDir: externalDir.path,
  //         fileName: _converterProvider?.youtubeModel?.title,
  //         showNotification: true,
  //         openFileFromNotification: true);
  //
  //     IsolateNameServer.registerPortWithName(
  //         receivePort.sendPort, "downloading");
  //     setState(() {
  //       _progress = _progresss;
  //       downloaded = true;
  //       loading = true;
  //     });
  //     print(_progress);
  //     FlutterDownloader.registerCallback(downloadingCallback);
  //     if (_progress == 100) {
  //       _showDialog(context);
  //       setState(() {
  //         loading = false;
  //         _progress = 0;
  //       });
  //     }
  //   } else {
  //     showToast(context, message: 'problem connecting to network');
  //     setState(() {
  //       loading = false;
  //     });
  //   }
  // }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();

      setState(() {
        loading = true;
      });
      return;
    }
    _port.listen((dynamic data) async {
      if (debug) {
        print('UI Isolate Callback: $data');
      }

      String id = data[0];
      DownloadTaskStatus status = data[1];
      print(id);

      int progress = data[2];
      setState(() {
        _progress = progress;
      });
      print(_progress);
      if (_progress == 100) {
        _showDialog(context);
        setState(() {
          // _progress = 0;
          loading = false;
        });
      } else {
        showToast(context, message: 'problem connecting to network');
        setState(() {
          loading = false;
        });
      }
      if (status == DownloadTaskStatus.complete)
        LogRepository.addLogs(Log(
            fileName: _fileName,
            filePath: _localPath,
            image: _converterProvider?.youtubeModel?.image ?? ''));

      /// navigates user when download completes
      // PageRouter.gotoWidget(SongViewCLass(), context);
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  // void _bindBackgroundIsolate() {
  //   bool isSuccess = IsolateNameServer.registerPortWithName(
  //       _port.sendPort, 'downloader_send_port');
  //   if (!isSuccess) {
  //     _unbindBackgroundIsolate();
  //     _bindBackgroundIsolate();
  //     return;
  //   }
  //   _port.listen((dynamic data) {
  //     if (debug) {
  //       print('UI Isolate Callback: $data');
  //     }
  //     String id = data[0];
  //     DownloadTaskStatus status = data[1];
  //     int progress = data[2];
  //   });
  // }
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) async {
    if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }

    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    //  since this a static functions which runs in isolates
    // sends and updates the main isolates of the background isolates
    send.send([id, status, progress]);
  }

  // static void _cacheData() async {
  //   _localPath = (await findLocalPath()) + Platform.pathSeparator + musicFolder;
  //   print('Path: $_localPath');
  // }

  /// Our static callbacks
  // static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  //   if (debug) {
  //     print(
  //         'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
  //   }
  //   final SendPort send =
  //   IsolateNameServer.lookupPortByName('downloader_send_port');
  //   //  since this a static functions which runs in isolates
  //   // sends and updates the main isolates of the background isolates
  //   send.send([id, status, progress]);
  //
  //   if (status == DownloadTaskStatus.complete) _cacheData();
  //
  // }

  // handles the background process's so it communicates effectively with the main
// thread
  // removes our backgroung communications with the main
// process's

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ConverterProvider>(builder: (_, model, __) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: AppColor.background,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RedBackground(
                        iconButton: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_outlined,
                            color: AppColor.white,
                          ),
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Sample()),
                          ),
                        ),
                        text: 'Converter',
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 6, bottom: 6, left: 30),
                        child: TextViewWidget(
                            color: AppColor.white,
                            text: 'Enter Youtube Url',
                            textSize: 23,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Stack(children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 58.0),
                            child: TextFormField(
                              style: TextStyle(color: AppColor.white),
                              decoration: new InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                border: new OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                labelText: 'Enter Youtube Url',
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                              cursorColor: AppColor.white,
                              controller: controller,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(23.0),
                                border: Border.all(color: AppColor.white),
                              ),
                              child: ClipOval(
                                child: InkWell(
                                  splashColor: Colors.white, // inkwell color
                                  child: Container(
                                      height: 55,
                                      width: 54,
                                      child: Icon(
                                        Icons.check,
                                        color: AppColor.white,
                                        size: 35,
                                      )),
                                  onTap: () {
                                    _download();
                                  },
                                ),
                              ),
                            ),
                          )
                        ]),
                      ),
                      _converterProvider.problem == true
                          ? Container(
                              child: Column(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.4),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(2),
                                              child: Image.network(
                                                model?.youtubeModel?.image ??
                                                    '',
                                                width: 115,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        model?.youtubeModel
                                                                ?.title ??
                                                            '',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                        )),
                                                    SizedBox(height: 10),
                                                    Text(
                                                        'File Size: ${model?.youtubeModel?.filesize ?? '0'}',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                        )),
                                                    SizedBox(height: 30),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 50),
                                  Builder(
                                      builder: (context) => _isLoading
                                          ? new Center(
                                              child:
                                                  new CircularProgressIndicator(),
                                            )
                                          : _permissionReady
                                              ? Center(
                                                  child: RaisedButton(
                                                    onPressed: () {
                                                      _requestDownload(
                                                          link: base_url +
                                                              _converterProvider
                                                                  ?.youtubeModel
                                                                  ?.url); // todo: replace with ur actuall link to download
                                                    },
                                                    color: AppColor.green,
                                                    child: TextViewWidget(
                                                      text: 'Download',
                                                      color: AppColor.white,
                                                      textSize: 20,
                                                    ),
                                                  ),
                                                )
                                              : _buildNoPermissionWarning()),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                  //   children: [
                                  //     _isLoading ? new Center(
                                  //       child: new CircularProgressIndicator(),
                                  //     ):_permissionReady
                                  //         ?
                                  //     FlatButton(
                                  //         onPressed: () {
                                  //           _requestDownload();
                                  //         },
                                  //         color: Colors.green,
                                  //         child: Text(
                                  //           'Download',
                                  //           style: TextStyle(
                                  //               color: Colors.white, fontSize: 20),
                                  //         )): _buildNoPermissionWarning(),
                                  //     SizedBox(width: 20),
                                  //     // FlatButton(
                                  //     //     color: Colors.red,
                                  //     //     onPressed: () {
                                  //     //       // _saveLib();
                                  //     //       // print(storagePath);
                                  //     //     },
                                  //     //     child: Text(
                                  //     //       'Save to lib',
                                  //     //       style: TextStyle(
                                  //     //         color: Colors.white,
                                  //     //         fontSize: 20,
                                  //     //       ),
                                  //     //     ))
                                  //   ],
                                  // ),
                                ],
                              ),
                            )
                          : Container(),
                      SizedBox(height: 60),
                      loading == false
                          ? Container()
                          : Center(child: downloadProgress()),
                      // FlatButton(
                      //     onPressed: () {},
                      //     color: Colors.green,
                      //     child: Text(
                      //       'Download',
                      //       style: TextStyle(color: Colors.white, fontSize: 20),
                      //     )),
                    ],
                  ),
                ),
              ),
              BottomPlayingIndicator(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNoPermissionWarning() => Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Please grant accessing storage permission to continue -_-',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey, fontSize: 18.0),
                ),
              ),
              SizedBox(
                height: 32.0,
              ),
              FlatButton(
                  onPressed: () {
                    _checkPermission().then((hasGranted) {
                      setState(() {
                        _permissionReady = hasGranted;
                      });
                    });
                  },
                  child: Text(
                    'Retry',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ))
            ],
          ),
        ),
      );

  void _requestDownload({@required String link}) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      _fileName = getStringPathName(link);
      setState(() {});
      await FlutterDownloader.enqueue(
          url: link,
          headers: {"auth": "test_for_sql_encoding"},
          savedDir: _localPath,
          fileName: _fileName,
          showNotification: true,
          openFileFromNotification: false);
    }
  }

//* checks for users permission
//* and returns true if the permission is granted and false if no permission is granted to our application

  Widget downloadProgress() {
    return Text(
      'Downloading $_progress%',
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.bold, color: AppColor.white),
    );
  }

  // _saveLib() async {
  //   DownloadedFile file = DownloadedFile(
  //       read(base_url + _converterProvider?.youtubeModel?.url),
  //       path: storagePath,
  //       image: _converterProvider?.youtubeModel?.image,
  //       title: _converterProvider?.youtubeModel?.title);
  //   final downBox = Hive.box('music_db');
  //   await downBox.add(file.toJson());
  // }

  //* checks for users permission
//* and returns true if the permission is granted and false if no permission is granted to our application
  Future<bool> _checkPermission() async {
    if (widget.platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

//* prepares the items we wish to download
  Future<Null> _prepare() async {
    _permissionReady = await _checkPermission(); // checks for users permission

    _localPath = (await _findLocalPath()) +
        Platform.pathSeparator +
        musicPath; // gets users

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    setState(() {
      _isLoading = false;
    });
  }

//* finds available space for storage on users device
  Future<String> _findLocalPath() async {
    final directory = widget.platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
