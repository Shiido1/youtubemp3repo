import 'package:flutter/cupertino.dart';

class RadioModel {
  String message;
  String token;
  List<Radio> radio = [];
  List<Favourite> favourite = [];

  RadioModel({this.message, this.radio, this.favourite, this.token});

  RadioModel.fromJson(Map<String, dynamic> json) {
    message = json['message'] == null ? "" : json['message'];
    token = json['token'] == null ? "" : json['token'];

    if (json['radio'] != null) {
      radio = <Radio>[];
      json['radio'].forEach((v) {
        try {
          radio.add(Radio.fromJson(v));
        } catch (e) {}
      });
    }
    if (json['favourite'] != null) {
      favourite = <Favourite>[];
      json['favourite'].forEach((v) {
        try {
          favourite.add(new Favourite.fromJson(v));
        } catch (e) {}
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['token'] = this.token;
    if (this.radio != null) {
      data['radio'] = this.radio.map((v) => v.toJson()).toList();
    }
    if (this.favourite != null) {
      data['favourite'] = this.favourite.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Radio {
  String uid;
  String id;
  String name;
  String slug;
  String website;
  String placeName;
  String placeLat;
  String placeLong;
  String functioning;
  String secure;
  String countryName;
  String countryCode;
  String mp3;
  String createdAt;

  Radio(
      {this.uid,
      this.id,
      this.name,
      this.slug,
      this.website,
      this.placeName,
      this.placeLat,
      this.placeLong,
      this.functioning,
      this.secure,
      this.countryName,
      this.countryCode,
      this.mp3,
      this.createdAt});

  Radio.fromJson(Map<String, dynamic> json) {
    uid = json['uid'] == null ? null : json['uid'];
    id = json['id'] == null ? null : json['id'].toString();
    name = json['name'] == null ? null : json['name'];
    slug = json['slug'] == null ? null : json['slug'];
    website = json['website'] == null ? null : json['website'];
    placeName = json['place_name'] == null ? null : json['place_name'];
    placeLat = json['place_lat'] == null ? null : json['place_lat'];
    placeLong = json['place_long'] == null ? null : json['place_long'];
    functioning = json['functioning'] == null ? null : json['functioning'];
    secure = json['secure'] == null ? null : json['secure'];
    countryName = json['country_name'] == null ? null : json['country_name'];
    countryCode = json['country_code'] == null ? null : json['country_code'];
    mp3 = json['mp3'] == null ? null : json['mp3'];
    createdAt = json['created_at'] == null ? null : json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['website'] = this.website;
    data['place_name'] = this.placeName;
    data['place_lat'] = this.placeLat;
    data['place_long'] = this.placeLong;
    data['functioning'] = this.functioning;
    data['secure'] = this.secure;
    data['country_name'] = this.countryName;
    data['country_code'] = this.countryCode;
    data['mp3'] = this.mp3;
    data['created_at'] = this.createdAt;
    return data;
  }

  static Map<String, dynamic> mapToJson(
      {@required String token, String searchData}) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = token;
    data['search'] = searchData;
    return data;
  }
}

class Favourite {
  String uid;
  String id;
  String name;
  String slug;
  String website;
  String placeName;
  String placeLat;
  String placeLong;
  String functioning;
  String secure;
  String countryName;
  String countryCode;
  String mp3;
  String createdAt;

  Favourite(
      {this.uid,
      this.id,
      this.name,
      this.slug,
      this.website,
      this.placeName,
      this.placeLat,
      this.placeLong,
      this.functioning,
      this.secure,
      this.countryName,
      this.countryCode,
      this.mp3,
      this.createdAt});

  Favourite.fromJson(Map<String, dynamic> json) {
    if (json == null) return;
    uid = json['uid'];
    id = json['id'].toString();
    name = json['name'];
    slug = json['slug'];
    website = json['website'];
    placeName = json['place_name'];
    placeLat = json['place_lat'];
    placeLong = json['place_long'];
    functioning = json['functioning'];
    secure = json['secure'];
    countryName = json['country_name'];
    countryCode = json['country_code'];
    mp3 = json['mp3'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['website'] = this.website;
    data['place_name'] = this.placeName;
    data['place_lat'] = this.placeLat;
    data['place_long'] = this.placeLong;
    data['functioning'] = this.functioning;
    data['secure'] = this.secure;
    data['country_name'] = this.countryName;
    data['country_code'] = this.countryCode;
    data['mp3'] = this.mp3;
    data['created_at'] = this.createdAt;
    return data;
  }
}
