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

import 'addItem.dart';
import 'chatrooms.dart';

class EbayMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);


    return CupertinoApp(
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
    switch(state){
      case AppLifecycleState.paused:
        print('paused state');
        if(Constants.myName != ''){
          setOfflineStatus(Constants.myName);
        }
        break;
      case AppLifecycleState.resumed:
        print('resumed state');
        if(Constants.myName != ''){
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
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        onTap: (index) {
          setState(() {
            _index = index;
          });
          print(_index);
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
              return userIsLoggedIn.log == null
                  ? Container(
                      child: Center(
                        child: Authenticate(),
                      ),
                    )
                  : userIsLoggedIn.log
                      ? CupertinoPageScaffold(
                          navigationBar: appBarMain(context, 'Item Enter'),
                          child: ItemView(),
                        )
                      : Authenticate();
            });
            break;
          case 1:
            returnValue = CupertinoTabView(builder: (context) {
              return userIsLoggedIn.log == null
                  ? Container(
                      child: Center(
                        child: Authenticate(),
                      ),
                    )
                  : userIsLoggedIn.log
                      ? CupertinoPageScaffold(
                          navigationBar: appBarMain(context, 'User Info'),
                          child: UserInfoView())
                      : Authenticate();
            });
            break;
          case 2:
            returnValue = CupertinoTabView(builder: (context) {
              return userIsLoggedIn.log == null
                  ? Container(
                      child: Center(
                        child: Authenticate(),
                      ),
                    )
                  : userIsLoggedIn.log
                      ? CupertinoPageScaffold(
                          navigationBar: appBarMain(context, 'Search'),
                          child: SearchTab(),
                        )
                      : Authenticate();
            });
            break;
          case 3:
            returnValue = CupertinoTabView(builder: (context) {
              return userIsLoggedIn.log == null
                  ? Container(
                      child: Center(
                        child: Authenticate(),
                      ),
                    )
                  : userIsLoggedIn.log ? ChatRoom() : Authenticate();
            });
            break;
          case 4:
            returnValue = CupertinoTabView(builder: (context) {
              return userIsLoggedIn.log == null
                  ? Container(
                      child: Center(
                        child: Authenticate(),
                      ),
                    )
                  : userIsLoggedIn.log
                      ? CupertinoPageScaffold(
                          navigationBar: appBarMain(context, 'Selling'),
                          child: Center(
                            child: Text('Selling'),
                          ),
                        )
                      : Authenticate();
            });
            break;
        }
        return returnValue;
      },
    );
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

  void login() {
    log = true;
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
}
