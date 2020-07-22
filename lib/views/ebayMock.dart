import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:offer_app/helper/authenticate.dart';
import 'package:offer_app/helper/constants.dart';
import 'package:offer_app/helper/helperfunctions.dart';
import 'package:offer_app/views/search.dart';
import 'package:offer_app/views/signin.dart';
import 'package:offer_app/views/userInfoView.dart';
import 'package:offer_app/widget/widget.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'addItem.dart';
import 'chatrooms.dart';
import 'eBaySearchAPI.dart';

const clientId = 'NathanTi-offerApp-PRD-4c8ec878c-d960497f';
const clientSecret = 'PRD-c8ec878c1af0-a176-463b-bd23-428d';
const authority = 'https://api.ebay.com/identity/v1/oauth2/token';
const scope = 'https://api.ebay.com/oauth/api_scope';

class EbayMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return CupertinoApp(
      theme: CupertinoThemeData(
        // Define the default brightness and colors.
        primaryColor: Colors.lightBlue[800],
        primaryContrastingColor: Colors.transparent,
        // Define the default font family.
      ),
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider<UserIsLoggedIn>(
          create: (context) => UserIsLoggedIn(), child: EbayMockPage()),
    );
  }
}

class EbayMockPage extends StatefulWidget {
  @override
  _EbayMockPage createState() => _EbayMockPage();
}

class _EbayMockPage extends State<EbayMockPage> with WidgetsBindingObserver {
  int _index;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        print('paused state');
        if (Constants.myName != '') {
          setOfflineStatus(Constants.myName);
        }
        break;
      case AppLifecycleState.resumed:
        print('resumed state');
        if (Constants.myName != '') {
          setOnlineStatus(Constants.myName);
        }
        break;
      case AppLifecycleState.inactive:
        print('inactive state');
        break;
      case AppLifecycleState.detached:
        print('detached state');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userIsLoggedIn = Provider.of<UserIsLoggedIn>(context);
    return userIsLoggedIn.log
        ? CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              onTap: (index) {
                setState(() {
                  _index = index;
                });
              },
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.home),
                  title: Text('Home'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person),
                  title: Text('My eBay'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.search),
                  title: Text('Search'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.bell),
                  title: Text('Notifications'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.tag),
                  title: Text('Selling'),
                ),
              ],
            ),
            tabBuilder: (context, index) {
              CupertinoTabView returnValue;
              switch (index) {
                case 0:
                  returnValue = CupertinoTabView(builder: (context) {
                    return CupertinoPageScaffold(
                      navigationBar: appBarMain(context, 'eBay SearchAPI'),
                      child: SearchAPI(),
                    );
                  });
                  break;
                case 1:
                  returnValue = CupertinoTabView(builder: (context) {
                    return CupertinoPageScaffold(
                        navigationBar: appBarMain(context, 'User Info'),
                        child: UserInfoView());
                  });
                  break;
                case 2:
                  returnValue = CupertinoTabView(builder: (context) {
                    return CupertinoPageScaffold(
                      navigationBar: appBarMain(context, 'Search'),
                      child: SearchTab(),
                    );
                  });
                  break;
                case 3:
                  returnValue = CupertinoTabView(builder: (context) {
                    return ChatRoom();
                  });
                  break;
                case 4:
                  returnValue = CupertinoTabView(builder: (context) {
                    return CupertinoPageScaffold(
                      navigationBar: appBarMain(context, 'Selling'),
                      child: Center(
                        child: Text('Selling'),
                      ),
                    );
                  });
                  break;
              }
              return returnValue;
            },
          )
        : Authenticate();
  }

  void setOnlineStatus(String userId) async {
    DatabaseReference rf = FirebaseDatabase.instance.reference();

    rf.child('userStatus').child(userId).set({
      'status': 'online',
      'lastTime': DateTime.now().toUtc().toString(),
    });
  }

  void setOfflineStatus(String userId) async {
    DatabaseReference rf = FirebaseDatabase.instance.reference();

    rf.child('userStatus').child(userId).set({
      'status': 'offline',
      'lastTime': DateTime.now().toUtc().toString(),
    });
  }
}

class UserIsLoggedIn with ChangeNotifier {
  bool log = false;
  String token = '';

  Future<void> login() async {
    log = true;
    getToken();
    notifyListeners();
  }

  void logout() {
    log = false;
    DatabaseReference rf = FirebaseDatabase.instance.reference();
    rf.child('userStatus').child(Constants.myName).set({
      'status': 'offline',
      'lastTime': DateTime.now().toUtc().toString(),
    });
    notifyListeners();
  }

  getToken() async {
    String credentials = '$clientId:$clientSecret';
    String encoded = base64.encode(utf8.encode(credentials));
    String encodedScope = Uri.encodeFull(scope);
    var response = await http.post(authority,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
          HttpHeaders.authorizationHeader: 'Basic $encoded',
        },
        body: 'grant_type=client_credentials&scope=$encodedScope');
    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);

      this.token = body['access_token'];
      print('Token Generated');
    }
  }
}
