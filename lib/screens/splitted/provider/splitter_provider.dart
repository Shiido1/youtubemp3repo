// import 'package:flutter/material.dart';
// import 'package:mp3_music_converter/widgets/progress_indicator.dart';
//
// // final SplitterRepo _repository = SplitterRepo();
//
// class SplitterProvider extends ChangeNotifier {
//   BuildContext _context;
//   CustomProgressIndicator _progressIndicator;
//   bool problem = false;
//
//   void init(BuildContext context) {
//     this._context = context;
//     this._progressIndicator = CustomProgressIndicator(this._context);
//   }
//
//   void split(String token) async {
//     // try {
//     //   _progressIndicator.show();
//     //   // final _response = await _repository.split(token);
//     //   // _response.when(success: (success, _, statusMessage) async {
//     //     await _progressIndicator.dismiss();
//     //     // splitter = success;
//     //     problem = true;
//     //     notifyListeners();
//     //   }, failure: (NetworkExceptions error, _, statusMessage) async {
//     //     await _progressIndicator.dismiss();
//     //     problem = false;
//     //     showToast(this._context, message: statusMessage);
//     //     notifyListeners();
//     //   });
//     // } catch (e) {
//     //   await _progressIndicator.dismiss();
//     //   showToast(_context, message: "please check your token");
//     //   notifyListeners();
//     // }
//   }
// }
