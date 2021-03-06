import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:offer_app/helper/constants.dart';
import 'package:provider/provider.dart';

import '../helper/helperfunctions.dart';
import '../services/auth.dart';
import '../services/database.dart';
import '../views/chatrooms.dart';
import '../widget/widget.dart';
import 'package:flutter/material.dart';

import 'ebayMock.dart';

class SignUp extends StatefulWidget {
  final Function toggleView;

  SignUp(this.toggleView);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  TextEditingController usernameEditingController = new TextEditingController();

  AuthService authService = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  @override
  void dispose() {
    this.emailEditingController.dispose();
    this.passwordEditingController.dispose();
    this.usernameEditingController.dispose();
    super.dispose();
  }
  singUp(UserIsLoggedIn provider) async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      await authService
          .signUpWithEmailAndPassword(
              emailEditingController.text, passwordEditingController.text)
          .then((result) {
        if (result != null) {
          Map<String, String> userDataMap = {
            "userName": usernameEditingController.text,
            "userEmail": emailEditingController.text
          };

          databaseMethods.addUserInfo(userDataMap);

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserNameSharedPreference(
              usernameEditingController.text);
          HelperFunctions.saveUserEmailSharedPreference(
              emailEditingController.text);
          Constants.myName = usernameEditingController.text;
          setOnlineStatus(Constants.myName);
          provider.login();
          print('provider.login()');

//          Navigator.pushReplacement(
//              context, MaterialPageRoute(builder: (context) => ChatRoom()));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userIsLoggedIn = Provider.of<UserIsLoggedIn>(context);
    return CupertinoPageScaffold(
      navigationBar: loginAppBar(context),
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Spacer(),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        CupertinoTextField(
                          style: simpleTextStyle(),
                          controller: usernameEditingController,
                          placeholder: 'Username',
//                          validator: (val) {
//                            return val.isEmpty || val.length < 3
//                                ? "Enter Username 3+ characters"
//                                : null;
//                          },
//                          decoration: textFieldInputDecoration("username"),
                        ),
                        CupertinoTextField(
                          controller: emailEditingController,
                          style: simpleTextStyle(),
                          placeholder: 'Email',
//                          validator: (val) {
//                            return RegExp(
//                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
//                                    .hasMatch(val)
//                                ? null
//                                : "Enter correct email";
//                          },
//                          decoration: textFieldInputDecoration("email"),
                        ),
                        CupertinoTextField(
                          obscureText: true,
                          style: simpleTextStyle(),
                          placeholder: 'Password',
//                          decoration: textFieldInputDecoration("password"),
                          controller: passwordEditingController,
//                          validator: (val) {
//                            return val.length < 6
//                                ? "Enter Password 6+ characters"
//                                : null;
//                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: () {
                      singUp(userIsLoggedIn);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "Sign Up",
                        style: biggerTextStyle(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  // Container(
                  //   padding: EdgeInsets.symmetric(vertical: 16),
                  //   decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(30),
                  //       color: Colors.white),
                  //   width: MediaQuery.of(context).size.width,
                  //   child: Text(
                  //     "Sign Up with Google",
                  //     style:
                  //         TextStyle(fontSize: 17, color: CustomTheme.textColor),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: simpleTextStyle(),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.toggleView();
                        },
                        child: Text(
                          "SignIn now",
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
