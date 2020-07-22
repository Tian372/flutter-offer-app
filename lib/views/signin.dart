import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:offer_app/helper/constants.dart';
import 'package:provider/provider.dart';

import '../helper/helperfunctions.dart';
import '../services/auth.dart';
import '../services/database.dart';
import '../views/forgot_password.dart';
import '../widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'addItem.dart';
import 'ebayMock.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  SignIn(this.toggleView);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();

  AuthService authService = new AuthService();

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  void dispose() {
    this.passwordEditingController.dispose();
    this.emailEditingController.dispose();
    super.dispose();
  }
  signIn(UserIsLoggedIn provider) async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      await authService
          .signInWithEmailAndPassword(
              emailEditingController.text, passwordEditingController.text)
          .then((result) async {
        if (result != null) {
          QuerySnapshot userInfoSnapshot =
              await DatabaseMethods().getUserInfo(emailEditingController.text);

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserNameSharedPreference(
              userInfoSnapshot.documents[0].data["userName"]);
          HelperFunctions.saveUserEmailSharedPreference(
              userInfoSnapshot.documents[0].data["userEmail"]);
          Constants.myName =
              await HelperFunctions.getUserNameSharedPreference();
          provider.login();
          setOnlineStatus(Constants.myName);
        } else {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userIsLoggedIn = Provider.of<UserIsLoggedIn>(context);
    return CupertinoPageScaffold(
      child: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                children: [
                  Spacer(
                    flex: 1,
                  ),
                  Container(
                    child: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/EBay_logo.svg/800px-EBay_logo.svg.png', height: 100),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50,
                          child: CupertinoTextField(
                            placeholder: "Email",
                            controller: emailEditingController,
                            style: simpleTextStyle(),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 50,
                          child: CupertinoTextField(
                            placeholder: "Password",
                            obscureText: true,
//                          validator: (val) {
//                            return val.length >= 6
//                                ? null
//                                : "Enter Password 6+ characters";
//                          },
                            style: simpleTextStyle(),
                            controller: passwordEditingController,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => ForgotPassword()));
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              "Forgot Password?",
                              style: simpleTextStyle(),
                            )),
                      )
                    ],
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 1.0),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: CupertinoButton(
                      onPressed: () {
                        if (emailEditingController.text.isEmpty ||
                            passwordEditingController.text.isEmpty) {
                          showCupertinoDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: Text('error'),
                                  content: Text('Email Field is Empty'),
                                  actions: <Widget>[
                                    FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('ok'))
                                  ],
                                );
                              });
                        } else if (!RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(emailEditingController.text)) {
                          showCupertinoDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  title: Text('error'),
                                  content: Text('Please Enter Currect Email.'),
                                  actions: <Widget>[
                                    FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('ok'))
                                  ],
                                );
                              });
                        } else {
                          try {
                            signIn(userIsLoggedIn);
                          } catch (Exception) {
                            showCupertinoDialog(
                                context: context,
                                builder: (context) {
                                  return CupertinoAlertDialog(
                                    title: Text('error'),
                                    content: Text(Exception.toString()),
                                    actions: <Widget>[
                                      FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('ok'))
                                    ],
                                  );
                                });
                          }
                        }
                      },
                      child: Text(
                        "Sign In",
                        style:
                            TextStyle(color: Colors.blueAccent, fontSize: 17),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have account? ",
                        style: simpleTextStyle(),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.toggleView();
                        },
                        child: Text(
                          "Register now",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  Spacer(
                    flex: 1,
                  ),
                ],
              ),
            ),
    );
  }

  void setOnlineStatus(String userId) async {
    DatabaseReference rf = FirebaseDatabase.instance.reference();

    rf.child('userStatus').child(userId).set({
      'status': 'online',
      'lastTime': DateTime.now().toUtc().toString(),
    });
  }
}
