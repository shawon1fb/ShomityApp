import 'package:flutter/material.dart';
import '../../Constant/Constant_color.dart';
import '../../Constant/constant.dart';
import '../../component/Normal_TextField.dart';
import '../../component/password_input_textField.dart';
import 'package:shomity_app/AppScreen/Dashbord/DashBoard.dart';
import 'package:toast/toast.dart';
import '../../Helper/ensure_visible.dart';
import '../../component/LoginButton.dart';
import 'dart:io';
import '../../Logic/API/LoginAPI.dart';
import 'package:http/http.dart';
import 'Sign_up_UI.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login_UI extends StatefulWidget {
  @override
  _Login_UIState createState() => _Login_UIState();
}

class _Login_UIState extends State<Login_UI> {
  final storage = new FlutterSecureStorage();
  bool visiable = false;

  Future<bool> _onWillPop(message) {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text(
              'Report !!',
              style: TextStyle(color: Colors.red),
            ),
            content: new Text('$message'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }
  void ChangeVisiable(bool b) {
    setState(() {
      visiable = b;
    });
  }

  final FocusNode _EmailFocus = FocusNode();
  final FocusNode _PasswordFocus = FocusNode();
  static final TextEditingController _firstNameController =
      new TextEditingController();
  static final TextEditingController _lastNameController =
      new TextEditingController();

  final EmailKey = GlobalKey<FormState>();
  final PasswordKey = GlobalKey<FormState>();
  String _email, _password;



  void _submit() async {
    ChangeVisiable(true);
    if (EmailKey.currentState.validate()) {
      EmailKey.currentState.save();
      if (_email != null && _password != null) {
        LoginApi login = new LoginApi();
        var responce = await login.Login_Request(_email, _password);
        print('=============================');
        print("test     = = = = = = = =");
        print(responce);
        if (responce != null) {
          if (responce['access_token'] != null) {
            String UserToken = responce['access_token'];
            String member_Id = responce['member_id'];
            await storage.write(key: 'UserToken', value: UserToken);
            await storage.write(key: 'member_id', value: member_Id);
            ChangeVisiable(false);

            var temp = await Navigator.push(
                context, MaterialPageRoute(builder: (context) => DashBoard()));
            if (temp == null) {
              exit(0);
            }
          } else {
            ChangeVisiable(false);
            bool b = await _onWillPop(responce['message'].toString());

            Toast.show(responce['message'], context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          }
        } else {
          ChangeVisiable(false);
          bool b = await _onWillPop("Connection Error.");
        }
      } else {
        ChangeVisiable(false);
        bool b = await _onWillPop("Username or Password Incorrect.");
        Toast.show("Username or Password Incorrect.", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    } else {
      ChangeVisiable(false);
    }
  }

  Future<Null> _focusNodeListener() async {
    if (_PasswordFocus.hasFocus) {
      print('TextField got the focus');
    } else {
      print('TextField lost the focus');
    }

    if (_EmailFocus.hasFocus) {
      print('Email got the focus');
    } else {
      print('Email lost the focus');
    }
  }

  void Storage_clearA() async {
    await storage.deleteAll();
  }

  @override
  void initState() {
    // TODO: implement initState
    _PasswordFocus.addListener(_focusNodeListener);
    _EmailFocus.addListener(_focusNodeListener);
    Storage_clearA();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _PasswordFocus.removeListener(_focusNodeListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var Sk_hight = MediaQuery.of(context).size.height;
    var Sk_width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: login_UI_BacgroundColor,
      body: SafeArea(
        child: Container(
          padding: GolobalPadding,
          child: Stack(
            children: <Widget>[
              Container(
                height: Sk_hight * 0.5,
                width: Sk_width,
                child: Center(
                  child: Image.asset('images/logo.png'),
                ),
              ),
              Visibility(
                visible: visiable,
                child: Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !visiable,
                child: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: Sk_hight * 0.5,
                          width: Sk_width,
                        ),
                        Form(
                            key: EmailKey,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                  child: EnsureVisibleWhenFocused(
                                    child: new NormalTextField(
                                      focusNode: _EmailFocus,
                                      onFieldSubmitted: (term) {
                                        _EmailFocus.unfocus();
                                        FocusScope.of(context)
                                            .requestFocus(_PasswordFocus);
                                      },
                                      hint: 'Username',
                                      inputType: TextInputType.emailAddress,
                                      validator: (input) => input.length < 1
                                          ? 'Not a valid Email'
                                          : null,
                                      OnSaved: (input) => _email = input,
                                    ),
                                    focusNode: _EmailFocus,
                                  ),
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                  child: EnsureVisibleWhenFocused(
                                    child: new PasswordTextField(
                                      focusNode: _PasswordFocus,
                                      hint: 'Password',
                                      validator: (input) => input.length < 4
                                          ? 'You need at least 4 characters'
                                          : null,
                                      OnSaved: (input) => _password = input,
                                    ),
                                    focusNode: _PasswordFocus,
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        LoginButton(
                          text: "SIGN IN",
                          onPress: () {
                            _submit();

                            print('log in pressed');
                          },
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Container(
                          child: Center(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Sign_up_UI()));
                              },
                              child: Text(
                                "SIGN UP",
                                style: KRedFlatButtonStyle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
