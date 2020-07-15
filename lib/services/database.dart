import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class DatabaseMethods {
  Future<void> addUserInfo(userData) async {
    Firestore.instance.collection("users").add(userData).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> addItemHelper(itemData) async {
    Firestore.instance.collection("mockData").add(itemData).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> declineJob(String jobId) async {
    DocumentReference dr =
        Firestore.instance.collection("chatRoom").document(jobId);

    dr.updateData(<String, dynamic>{
      'declined': true,
    });
//    dr.collection("chats").getDocuments().then((snapshot) {
//      for (DocumentSnapshot ds in snapshot.documents) {
//        ds.reference.delete();
//      }
//    });
//    await Firestore.instance.runTransaction((Transaction myTransaction) async {
//      await myTransaction.delete(dr);
//    });
  }

  Future<void> paidJob(String jobId) async {
    DocumentReference dr =
        Firestore.instance.collection("chatRoom").document(jobId);

    dr.updateData(<String, dynamic>{
      'paid': true,
      'declined': true,
    });
//    dr.collection("chats").getDocuments().then((snapshot) {
//      for (DocumentSnapshot ds in snapshot.documents) {
//        ds.reference.delete();
//      }
//    });
//    await Firestore.instance.runTransaction((Transaction myTransaction) async {
//      await myTransaction.delete(dr);
//    });
  }

  Future<void> updateApproval(String chatRoomId, chatId) async {
    DocumentReference dr = Firestore.instance
        .collection('chatRoom')
        .document(chatRoomId)
        .collection('chats')
        .document(chatId);
    bool temp;
    await dr.get().then((value) => {temp = value.data['sellerApproved']});
    dr.updateData(<String, bool>{
      'sellerApproved': !temp,
    });
    print('Price Approved');
  }

  Future<void> updateBuyerList(String itemId, buyerName) async {
    DocumentReference dr =
        Firestore.instance.collection('mockData').document(itemId);

    dr.updateData(<String, dynamic>{
      'offerNum': FieldValue.increment(1),
      'buyers': FieldValue.arrayUnion([buyerName]),
    });
    print('Buyer added');
  }

  updateAuctionBuyerList(String itemId, buyerName) {
    DocumentReference dr =
        Firestore.instance.collection('auctionRoom').document(itemId);

    dr.updateData(<String, dynamic>{
      'buyers': FieldValue.arrayUnion([buyerName]),
    });
    print('Buyer added');
  }

  Future<void> rejectJob(String jobId) async {
    DocumentReference dr =
        Firestore.instance.collection("chatRoom").document(jobId);

    dr.collection("chats").getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
    });
    await Firestore.instance.runTransaction((Transaction myTransaction) async {
      await myTransaction.delete(dr);
    });
  }

  getUserInfo(String email) async {
    return Firestore.instance
        .collection("users")
        .where("userEmail", isEqualTo: email)
        .getDocuments()
        .catchError((e) {
      print(e.toString());
    });
  }

  getLatestPriceFrom(String itemName) async {
    return Firestore.instance
        .collection("auctionRoom")
        .document(itemName)
        .collection("bids")
        .orderBy('time', descending: true)
        .limit(1)
        .snapshots();
  }

  getChats(String chatRoomId) async {
    return Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection("chats")
        .orderBy('time', descending: true)
        .snapshots();
  }

  getBids(String itemName) async {
    return Firestore.instance
        .collection('auctionRoom')
        .document(itemName)
        .collection("bids")
        .orderBy('time', descending: true)
        .snapshots();
  }

  searchByName(String searchField) {
    return Firestore.instance
        .collection("users")
        .where('userName', isEqualTo: searchField)
        .getDocuments();
  }

  getItemInfo(String itemId) {
    return Firestore.instance
        .collection("mockData")
        .document(itemId);
  }

  searchByItem(String item, String myName) {
    return Firestore.instance
        .collection("mockData")
//        .where('itemName', isEqualTo: item)
        .where("searchParam", arrayContains: item)
        .getDocuments();
  }

  addChatRoom(chatRoom, chatRoomId) {
    Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .setData(chatRoom)
        .catchError((e) {
      print(e);
    });
  }

  addAuctionRoom(auctionRoom, itemName) {
    Firestore.instance
        .collection("auctionRoom")
        .document(itemName)
        .setData(auctionRoom)
        .catchError((e) {
      print(e);
    });
  }

  addMessage(String chatRoomId, chatMessageData) {
    Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection("chats")
        .add(chatMessageData)
        .catchError((e) {
      print(e.toString());
    });
  }

  addBid(String itemName, bidData) {
    Firestore.instance
        .collection("auctionRoom")
        .document(itemName)
        .collection("bids")
        .add(bidData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getUserSellerChats(String myName) async {
    return Firestore.instance
        .collection("chatRoom")
        .where('seller', isEqualTo: myName)
        .snapshots();
  }

  getUserBuyerChats(String myName) async {
    return Firestore.instance
        .collection("chatRoom")
        .where('buyer', isEqualTo: myName)
        .snapshots();
  }

  getUserBids(String myName) async {
    return Firestore.instance
        .collection("auctionRoom")
        .where('buyers', arrayContains: myName)
        .snapshots();
  }

  isChatroomExist(String chatRoomId) {
    Firestore.instance
        .collection('chatRoom')
        .where('chatRoomId', isEqualTo: chatRoomId);
  }

  Future<void> addWinner(String itemId, userName) async {
    DocumentReference dr =
        Firestore.instance.collection('mockData').document(itemId);
    dr.updateData(<String, dynamic>{'sold': true, 'winner': userName});
    print('Winner updated');
  }
}

Future<Widget> getImage(BuildContext context, String image) async {
  Image m;
  await FireStorageService.loadImage(context, image).then((downloadUrl) {
    m = Image.network(
      downloadUrl.toString(),
      fit: BoxFit.scaleDown,
      height: 150,
      width: 150,
    );
  });

  return m;
}

class FireStorageService extends ChangeNotifier {
  FireStorageService();

  static Future<dynamic> loadImage(BuildContext context, String image) async {
    return await FirebaseStorage.instance.ref().child(image).getDownloadURL();
  }
}
