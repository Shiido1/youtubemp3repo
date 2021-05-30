import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SplitAssistant {
  static Future<dynamic> splitFile(
      {String filePath, BuildContext context, String userToken}) async {
    print('In the split function');
    print(filePath);
    String baseUrl = "http://67.205.165.56/api/splitter?";

    try {
      var postUri = Uri.parse(baseUrl);
      var request = new http.MultipartRequest("POST", postUri);
      // request.fields['token'] = Provider.of<LoginProviders>(context).userToken;
      request.headers['Content-Type'] = 'multipart/form-data';
      request.fields['token'] = userToken;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        String jsonData = await response.stream.bytesToString();
        print(jsonData);
        var decodedData = jsonDecode(jsonData);
        print(decodedData);
        String errorMessage = decodedData["message"] ?? null;
        if (errorMessage == null) {
          return decodedData;
        } else
          return "Failed";
      } else {
        print('failed');
        print(response.statusCode);
        print(await response.stream.bytesToString());
        return "Failed";
      }
    } catch (e) {
      print(e);
      return "Failed";
    }
  }

  static Future<bool> saveSplitFiles(
      {var decodedData, BuildContext context, String userToken}) async {
    String baseUrl = "http://67.205.165.56/api/savesplit";

    var body = jsonEncode({
      // "token2": Provider.of<LoginProviders>(context, listen: false).userToken,
      "token": userToken,
      "bass": decodedData['files']['bass'],
      "voice": decodedData['files']['voice'],
      "drum": decodedData['files']['drums'],
      "others": decodedData['files']['other'],
      "title": decodedData['title'],
      "id": decodedData['id'],
    });

    try {
      final _response = await http.post(baseUrl,
          headers: {
            'Content-Type': 'application/json',
          },
          body: body);

      if (_response.statusCode == 200) {
        return Future.value(true);
      } else {
        return Future.value(false);
      }
    } catch (e) {
      return Future.value(false);
    }
  }
}
