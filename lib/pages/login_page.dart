import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _scafoldKey = GlobalKey<ScaffoldState>();

  bool _isSubmitting, _obscureText = true;

  String _email, _password;

  Widget _showTitle() {
    return Text('Login', style: Theme.of(context).textTheme.headline);
  }

  Widget _showEmailInput() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: TextFormField(
        onSaved: (val) => _email = val,
        validator: (val) => !val.contains('@') ? 'Invalid Email' : null,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Email',
            hintText: 'Enter a valid email',
            icon: Icon(
              Icons.mail,
              color: Colors.grey,
            )),
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: TextFormField(
        onSaved: (val) => _password = val,
        validator: (val) => val.length < 6 ? 'Password too short' : null,
        obscureText: _obscureText,
        decoration: InputDecoration(
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() => _obscureText = !_obscureText);
              },
              child:
                  Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
            ),
            border: OutlineInputBorder(),
            labelText: 'Password',
            hintText: 'Enter Password, min length 6',
            icon: Icon(
              Icons.face,
              color: Colors.grey,
            )),
      ),
    );
  }

      void _showSuccessSnack() {
      final snackbar = SnackBar(
          content: Text('User successfully logged in!',
              style: TextStyle(color: Colors.green)));

      _scafoldKey.currentState.showSnackBar(snackbar);

      _formKey.currentState.reset();
    }

    void _redirectUser() {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/');
      });
    }

    void _showErrorSnack(dynamic errorMsg) {
      final snackbar = SnackBar(
          content: Text(errorMsg.toString(), style: TextStyle(color: Colors.red)));

      _scafoldKey.currentState.showSnackBar(snackbar);
      String err = errorMsg.toString();
      throw Exception('Error logging in: $err');
    }

        void _registerUser() async {
      setState(() {
        _isSubmitting = true;
      });
      http.Response response = await http
          .post('http://192.168.1.105:1337/auth/local', body: {
        "identifier": _email,
        "password": _password
      });

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _isSubmitting = false;
        });
        
        _storeUserData(responseData);
        _showSuccessSnack();
        _redirectUser();
        print(responseData);
      } else {
        setState(() {
          _isSubmitting = false;
        });

        final dynamic errorMsg = responseData['message'];

        _showErrorSnack(errorMsg);
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldKey,
      appBar: AppBar(title: Text('Login')),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _showTitle(),
                  _showEmailInput(),
                  _showPasswordInput(),
                  _showFormActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _showFormActions() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          _isSubmitting == true ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),) : RaisedButton(
              onPressed: _submit,
              child: Text(
                'Submit',
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Colors.black),
              ),
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              color: Theme.of(context).accentColor),
          FlatButton(
            child: Text('New User? Register'),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/register'),
          )
        ],
      ),
    );
  }

  void _submit() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      _registerUser();
    }

  }

    void _storeUserData(responseData) async {
          final prefs = await SharedPreferences.getInstance();
          Map<String, dynamic> user =  responseData['user'];
          user.putIfAbsent('jwt', () => responseData['jwt']);

          prefs.setString('user', json.encode(user));
        }
}
