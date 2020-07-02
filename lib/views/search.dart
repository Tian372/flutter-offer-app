import 'package:flutter/cupertino.dart';
import 'package:offer_app/helper/style.dart';

import '../helper/constants.dart';
import '../services/database.dart';
import '../views/buyerChat.dart';
import '../widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//TODO: search by items

class SearchTab extends StatefulWidget {
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController _controller;
  FocusNode _focusNode;
  QuerySnapshot searchResultSnapshot;

  String _terms = '';

  bool isLoading = false;
  bool haveUserSearched = false;

//TODO: should not be able to search one's self
  initiateSearch() async {
    if (_terms != '') {
      setState(() {
        isLoading = true;
      });
      await databaseMethods
          .searchByItem(_terms, Constants.myName)
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
        ? ListView.builder(
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

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SearchBar(
        controller: _controller,
        focusNode: _focusNode,
      ),
    );
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
        'seller': userName,
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
    _controller = TextEditingController()..addListener(_onTextChanged);
    _focusNode = FocusNode();
    super.initState();
  }

  void _onTextChanged() {
    setState(() {
      _terms = _controller.text;
      initiateSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Styles.scaffoldBackground,
      ),
      child: SafeArea(
        child: Container(
          child: Column(
            children: [
              _buildSearchBox(),
              isLoading ? CupertinoActivityIndicator() : userList()
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({
    @required this.controller,
    @required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Styles.searchBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 8,
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.search,
              color: Styles.searchIconColor,
            ),
            Expanded(
              child: CupertinoTextField(
                controller: controller,
                focusNode: focusNode,
                style: Styles.searchText,
                cursorColor: Styles.searchCursorColor,
              ),
            ),
            GestureDetector(
              onTap: controller.clear,
              child: const Icon(
                CupertinoIcons.clear_thick_circled,
                color: Styles.searchIconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
