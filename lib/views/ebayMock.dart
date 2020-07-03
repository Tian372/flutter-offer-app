import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:offer_app/helper/authenticate.dart';
import 'package:offer_app/helper/helperfunctions.dart';
import 'package:offer_app/views/search.dart';
import 'package:offer_app/views/signin.dart';
import 'package:offer_app/views/userInfoView.dart';
import 'package:provider/provider.dart';

import 'addItem.dart';
import 'chatrooms.dart';

class EbayMock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This app is designed only to work vertically, so we limit
    // orientations to portrait up and down.
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

class _EbayMockPage extends State<EbayMockPage> {
  bool serverLogin;
  int _index;

  @override
  void initState() {
//    getLoggedInState();
    super.initState();
  }

//  getLoggedInState() async {
//    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
//      setState(() {
//        serverLogin = value;
//
//      });
//    });
//  }

  @override
  Widget build(BuildContext context) {
    final userIsLoggedIn = Provider.of<UserIsLoggedIn>(context);
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
//        onTap: (index) {
//          setState(() {
//            getLoggedInState();
//            serverLogin ? userIsLoggedIn.login() : userIsLoggedIn.logout();
//          });
//        },
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
            //login
            //TODO: Login
            returnValue = CupertinoTabView(builder: (context) {
              return userIsLoggedIn.log == null
                  ? Container(
                      child: Center(
                        child: Authenticate(),
                      ),
                    )
                  : userIsLoggedIn.log
                      ? CupertinoPageScaffold(
                          navigationBar: CupertinoNavigationBar(
                            middle: Text('Item Enter'),
                          ),
                          child: ItemView(),
                        )
                      : Authenticate();
            });
            break;
          //TODO:
          //my info
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
                          navigationBar: CupertinoNavigationBar(
                            middle: Text('User Info'),
                          ),
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
                  : userIsLoggedIn.log
                      ? CupertinoPageScaffold(
                          child: ChatRoom(),
                        )
                      : Authenticate();
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
}

class UserIsLoggedIn with ChangeNotifier {
  bool log = false;

  void login() {
    log = true;
    notifyListeners();
  }

  void logout() {
    log = false;
    notifyListeners();
  }
}
