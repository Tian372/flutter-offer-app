import 'package:flutter/cupertino.dart';
import 'package:offer_app/helper/style.dart';

import '../helper/constants.dart';
import '../services/database.dart';
import 'Rooms/buyerChat.dart';
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

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

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

  Widget itemList() {
    return haveUserSearched
        ? ListView.separated(
            separatorBuilder: (context, index) => Divider(
                  color: Styles.productRowDivider,
                  thickness: 1,
                ),
            shrinkWrap: true,
            itemCount: searchResultSnapshot.documents.length,
            itemBuilder: (context, index) {
              return itemTile(
                searchResultSnapshot.documents[index].data['seller'],
                searchResultSnapshot.documents[index].data['itemName'],
                searchResultSnapshot.documents[index].data['itemDesc'],
                searchResultSnapshot.documents[index].data['listPrice'],
                searchResultSnapshot.documents[index].documentID,
                searchResultSnapshot.documents[index].data['offerNum'],
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
    Navigator.push(
        context,
        CupertinoPageRoute(
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

  Widget itemTile(String userName, String itemName, String itemDesc,
      String price, String itemId, int offerNum) {
    return GestureDetector(
      onTap: () {
        sendMessage(userName, itemId, itemName);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FutureBuilder(
                future: getImage(context, 'images/$itemId.jpg'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done)
                    return Container(
                      child: snapshot.data,
                    );
                  else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '$itemName',
                  style: Styles.searchText,
                ),
                SizedBox(height: 5),
                Text(
                  '$itemDesc . brand',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                SizedBox(height: 15),
                Text(
                  '\$ $price',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '$offerNum people are interested.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                )
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              children: [
                CupertinoButton(
                  child: Text('Offer'),
                  onPressed: () {
                    sendMessage(userName, itemId, itemName);
                  },
                ),
                SizedBox(
                  height: 5,
                ),
                CupertinoButton(
                  child: Text('Auction'),
                  onPressed: () {
//                    sendAuction(userName, itemId, itemName);
                  },
                ),
              ],
            )
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

  getAuctionId(String itemName, sellerName) {
    return '$itemName\_$sellerName';
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
              isLoading ? CupertinoActivityIndicator() : itemList()
            ],
          ),
        ),
      ),
    );
  }
//
//  sendAuction(String userName, String itemId, String itemName) async {
//    String auctionId = getAuctionId(userName, itemName);
//
//    final snapShot = await Firestore.instance
//        .collection('auctionRoom')
//        .document(auctionId)
//        .get();
//
//    bool ongoing= false;
//
//    if (snapShot.exists) {
//      ongoing = snapShot.data['declined'];
//    } else {
//      DatabaseMethods().updateAucionList(itemId, Constants.myName);
//      Map<String, dynamic> auction= {
//        'itemName': itemName,
//        'itemId': itemId,
//        'seller': userName,
//        'auctionId': auctionId,
//        'finished':ongoing,
//
//      };
//      databaseMethods.addAuction(auction, auctionId);
//    }
//
//    Navigator.push(
//        context,
//        CupertinoPageRoute(
//            builder: (context) => Auction(
//              auctionId: auctionId,
//              sellerName: userName,
//              declined: ongoing,
//            )));
//  }
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
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: CupertinoTextField(
                autofocus: true,
                controller: controller,
                focusNode: focusNode,
                style: Styles.searchText,
                cursorColor: Styles.searchCursorColor,
                decoration: BoxDecoration(
                  color: Styles.searchBackground,
                ),
              ),
            ),
            SizedBox(
              width: 5,
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
