import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mp3_music_converter/chat/available_users..dart';
import 'package:mp3_music_converter/chat/chat_screen.dart';
import 'package:mp3_music_converter/chat/database_service.dart';
import 'package:mp3_music_converter/utils/color_assets/color.dart';
import 'package:mp3_music_converter/widgets/text_view_widget.dart';

class ChatHome extends StatefulWidget {
  ChatHome({Key key}) : super(key: key);

  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  bool search = false;
  String userName = 'Rita';
  List<MessageData> users = [];
  List<MessageData> userSearchResult = [];
  StreamSubscription userStream;
  bool newMessage = false;
  int newMessageCount = 0;

  searchUsers(String value) {
    List<MessageData> usersPlaceholder = [];
    if (value == null || value.isEmpty) {
      setState(() {
        userSearchResult = users;
      });
      return;
    }
    for (MessageData user in users) {
      if (user.name.toLowerCase().contains(value.toLowerCase()))
        usersPlaceholder.add(user);
    }
    setState(() {
      userSearchResult = usersPlaceholder;
    });
  }

  checkUnreadMessages(List<MessageData> message) {
    List newMessages = [];
    for (MessageData data in message) {
      if (data.unreadCount > 0) newMessages.add(data);
    }
    if (mounted)
      setState(() {
        newMessageCount = newMessages.length;
        newMessage = newMessageCount > 0 ? true : false;
      });
  }

  getUsers(String id) {
    userStream = DatabaseService().allStream(id).listen((event) {
      Map<int, MessageData> userIDs = {};
      List<MessageData> userData = [];

      if (event != null) {
        Map data = event.snapshot.value;
        if (data == null && event.snapshot.key == id)
          setState(() {
            users = [];
          });

        data.forEach((key, value) {
          int count = 0;
          value.forEach((key2, value2) {
            if (key2 != 'name' &&
                key2 != 'time' &&
                key2 != 'lastMessage' &&
                value2['id'] != id &&
                value2['read'] == false) count += 1;
          });
          userIDs.putIfAbsent(
              value['time'],
              () => MessageData(
                  id: event.snapshot.key,
                  message: value['lastMessage'],
                  peerId: key,
                  time: value['time'].toString(),
                  name: value['name'],
                  unreadCount: count));
        });

        List userIdKey = userIDs.keys.toList();
        if (userIdKey.length > 1) userIdKey.sort((b, a) => a.compareTo(b));

        for (int key in userIdKey) {
          userData.add(userIDs[key]);
        }
        if (mounted)
          setState(() {
            users = userData;
          });
        checkUnreadMessages(users);
      }
    });
  }

  @override
  void initState() {
    getUsers('70');
    super.initState();
  }

  @override
  void dispose() {
    userStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (search) {
          setState(() {
            search = false;
          });
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: AppColor.background,
        appBar: AppBar(
          actions: [
            IconButton(
                icon: Icon(
                  search ? Icons.cancel_outlined : Icons.search,
                  color: AppColor.white,
                  size: 25,
                ),
                onPressed: () {
                  setState(() {
                    search = !search;
                  });
                }),
            SizedBox(width: 10),
          ],
          backgroundColor: AppColor.black,
          title: Row(
            children: [
              TextViewWidget(
                text: 'Chat',
                color: AppColor.bottomRed,
              ),
              SizedBox(width: 10),
              if (newMessage)
                Container(
                  width: 35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$newMessageCount',
                    style: TextStyle(color: Colors.black),
                  ),
                )
            ],
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
        body: Theme(
          data: Theme.of(context).copyWith(accentColor: Colors.transparent),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Stack(
              children: [
                ListView(
                  children: [
                    if (search)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: TextFormField(
                          onChanged: (val) {
                            searchUsers(val);
                          },
                          decoration: decoration.copyWith(
                            prefixIcon: Icon(Icons.search,
                                color: Color.fromRGBO(0, 0, 0, 0.5)),
                          ),
                          cursorColor: AppColor.black,
                          cursorHeight: 18,
                        ),
                      ),
                    SizedBox(height: 20),
                    ListView.builder(
                        itemCount:
                            search ? userSearchResult.length : users.length,
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          MessageData user =
                              search ? userSearchResult[index] : users[index];
                          return Card(
                            color: AppColor.white,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(7))),
                            margin: EdgeInsets.only(bottom: 20),
                            child: ListTile(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              onTap: () {
                                search = false;
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                              userName: userName,
                                              peerName: user.name,
                                              imageUrl: '',
                                              id: user.id,
                                              pid: user.peerId,
                                            )));
                              },
                              leading: CircleAvatar(
                                child: Icon(Icons.person),
                                radius: 25,
                              ),
                              title: TextViewWidget(
                                text: user.name ?? '',
                                color: AppColor.black,
                                fontWeight: FontWeight.w500,
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  user.message ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Color.fromRGBO(0, 0, 0, 0.5),
                                      fontSize: 14),
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      user.time != null
                                          ? checkDates(user.time)
                                          : '',
                                      style: TextStyle(color: Colors.black)),
                                  if (user.unreadCount > 0)
                                    Container(
                                      decoration: BoxDecoration(
                                          color:
                                              Color.fromRGBO(196, 196, 196, 1),
                                          shape: BoxShape.circle),
                                      padding: EdgeInsets.all(5),
                                      child: Text(
                                        user.unreadCount > 99
                                            ? '99+'
                                            : user.unreadCount.toString(),
                                        style: TextStyle(
                                            color: AppColor.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ],
                ),
                Positioned(
                  bottom: 15,
                  right: 5,
                  child: InkWell(
                    onTap: () {
                      search = false;
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => AvailableUsers()));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.red,
                      ),
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.add, color: AppColor.white, size: 40),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String checkDates(String key) {
    String currentItemDate = DateFormat.yMd()
        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(key)));

    String currentItemDay = currentItemDate.split('/')[1];
    String currentItemMonth = currentItemDate.split('/')[0];
    String currentItemYear = currentItemDate.split('/')[2];

    String currentDate = DateFormat.yMd().format(DateTime.now());
    String currentDay = currentDate.split('/')[1];
    String currentMonth = currentDate.split('/')[0];
    String currentYear = currentDate.split('/')[2];

    if (currentItemDate == currentDate) {
      DateTime time = DateTime.fromMillisecondsSinceEpoch(int.parse(key));
      return DateFormat.Hm().format(time).toString();
    } else if (currentItemYear == currentYear &&
        currentItemMonth == currentMonth &&
        int.parse(currentItemDay) == int.parse(currentDay) - 1) {
      return 'yesterday';
    } else
      return DateFormat.yMd()
          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(key)));
  }
}

const decoration = InputDecoration(
  filled: true,
  fillColor: AppColor.white,
  hintText: "Search",
  hintStyle: TextStyle(
      color: Color.fromRGBO(0, 0, 0, 0.6),
      fontSize: 14,
      fontWeight: FontWeight.w400),
  contentPadding: EdgeInsets.all(15),
  border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(7)),
      borderSide: BorderSide(color: Colors.transparent)),
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(7)),
      borderSide: BorderSide(color: Colors.transparent)),
);

class MessageData {
  String message;
  String id;
  String peerId;
  String time;
  String name;
  int unreadCount;
  MessageData(
      {@required this.id,
      @required this.message,
      @required this.peerId,
      @required this.time,
      @required this.name,
      @required this.unreadCount});
}
