import '../helper/constants.dart';
import '../services/database.dart';
import '../views/buyerChat.dart';
import '../widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//TODO: search by items

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

//TODO: should not be able to search one's self
  initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await databaseMethods
          .searchByItem(searchEditingController.text, Constants.myName)
          .then((snapshot) {
        searchResultSnapshot = snapshot;
        //TODO: get rid of all elements == myName
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
            separatorBuilder: (context, index) => Divider(),
            shrinkWrap: true,
            itemCount: searchResultSnapshot.documents.length,
            itemBuilder: (context, index) {
              return userTile(
                searchResultSnapshot.documents[index].data['seller'],
                searchResultSnapshot.documents[index].data['itemName'],
                searchResultSnapshot.documents[index].data['itemDesc'],
                searchResultSnapshot.documents[index].documentID,
              );
            })
        : Container();
  }

  /// 1.create a chatroom, send user to the chatroom, other userdetails
  sendMessage(String userName, String itemId, String itemName) async {
    String chatRoomId = getChatRoomId(Constants.myName, userName, itemName);

    final snapShot = await Firestore.instance
        .collection('chatRoom')
        .document(chatRoomId)
        .get();

    bool declinedStatus = false;
    bool paymentStatus = false;
    if (snapShot.exists) {
      declinedStatus = snapShot.data['declined'];
      paymentStatus = snapShot.data['paid'];
    } else {
      DatabaseMethods().updateBuyerList(itemId, Constants.myName);
      Map<String, dynamic> chatRoom = {
        'itemName': itemName,
        'itemId': itemId,
        'seller' : userName,
        'buyer': Constants.myName,
        'chatRoomId': chatRoomId,
        'declined': declinedStatus,
        'paid': paymentStatus,
      };
      databaseMethods.addChatRoom(chatRoom, chatRoomId);
    }
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BuyerChat(
                  chatRoomId: chatRoomId,
                  sellerName: userName,
                  declined: declinedStatus,
                )));
//
//    if (snapShot == null || !snapShot.exists) {
//      // Document with id == docId doesn't exist.
//    }
  }

  Widget userTile(
      String userName, String itemName, String itemDesc, String itemId) {
    return GestureDetector(
      onTap: () {
        sendMessage(userName, itemId, itemName);
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
                  '$itemName',
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ),
                Text(
                  'seller: $userName. $itemDesc',
                  style: TextStyle(color: Colors.black, fontSize: 15),
                )
              ],
            ),
            Spacer(),
            Container(child: Icon(Icons.send))
          ],
        ),
      ),
    );
  }

  getChatRoomId(String a, b, itemName) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return '$b\_$a\_$itemName';
    } else {
      return '$a\_$b\_$itemName';
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
                        labelText: 'search item',
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
