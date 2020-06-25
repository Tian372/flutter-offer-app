import '../helper/constants.dart';
import '../services/database.dart';
import '../views/chat.dart';
import '../widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchEditingController = new TextEditingController();
  QuerySnapshot searchResultSnapshot;

  bool isLoading = false;
  bool haveUserSearched = false;

  initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await databaseMethods
          .searchByName(searchEditingController.text)
          .then((snapshot) {
        searchResultSnapshot = snapshot;
        print("$searchResultSnapshot");
        setState(() {
          isLoading = false;
          haveUserSearched = true;
        });
      });
    }
  }

  Widget userList() {
    return haveUserSearched
        ? ListView.separated(
        separatorBuilder: (context, index) => Divider(
        ),
            shrinkWrap: true,
            itemCount: searchResultSnapshot.documents.length,
            itemBuilder: (context, index) {
              return userTile(
                searchResultSnapshot.documents[index].data["userName"],
                searchResultSnapshot.documents[index].data["userEmail"],
              );
            })
        : Container();
  }

  /// 1.create a chatroom, send user to the chatroom, other userdetails
  sendMessage(String userName) {
    List<String> users = [Constants.myName, userName];

    String chatRoomId = getChatRoomId(Constants.myName, userName);

    Map<String, dynamic> chatRoom = {
      "users": users,
      "chatRoomId": chatRoomId,
      "declined": false,
    };

    databaseMethods.addChatRoom(chatRoom, chatRoomId);
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                  chatRoomId: chatRoomId,
                  userName: users[1],
                  declined: false,
                )));
  }

  Widget userTile(String userName, String userEmail) {
    return GestureDetector(
      onTap: () {
        sendMessage(userName);
      },
      child: Container(
        color: Colors.blueGrey[100],
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
                Text(
                  userEmail,
                  style: TextStyle(color: Colors.black, fontSize: 15),
                )
              ],
            ),
            Spacer(),
            Container(
                //padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                decoration: BoxDecoration(
//                    color: Colors.blue,
//                    borderRadius: BorderRadius.circular(40)),
                child: Icon(Icons.send))
          ],
        ),
      ),
    );
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    color: Color(0x54FFFFFF),
                    child: TextField(
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) {
                        initiateSearch();
                      },
                      maxLength: 42,
                      controller: searchEditingController,
                      style: simpleTextStyle(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'search username',
                      ),
                    ),
                  ),
                  userList()
                ],
              ),
            ),
    );
  }
}

