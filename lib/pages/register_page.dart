import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  bool _isSubmitting, _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  final _scafoldKey = GlobalKey<ScaffoldState>();

  String _username, _email, _password, _address, _phoneNumber;

  Widget _showTitle() {
    return Text('Register', style: Theme.of(context).textTheme.headline);
  }

  Widget _showUsenameInput() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: TextFormField(
        onSaved: (val) => _username = val,
        validator: (val) => val.length < 6 ? 'Username too short' : null,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Username',
            hintText: 'Enter Username, min length 6',
            icon: Icon(
              Icons.face,
              color: Colors.grey,
            )),
      ),
    );
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

  Widget _showAddressInput() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: TextFormField(
        onSaved: (val) => _address = val,
        validator: (val) => val.isEmpty ? 'Enter Delivery Address' : null,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Address',
            hintText: 'Enter Full Delivery Address',
            icon: Icon(
              Icons.home,
              color: Colors.grey,
            )),
      ),
    );
  }

  Widget _showAPhoneNumberInput() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: TextFormField(
        onSaved: (val) => _phoneNumber = val,
        keyboardType: TextInputType.number,
        validator: (val) => val.isEmpty ? 'Enter Phone No.' : null,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Phone Number',
            hintText: 'Enter a valid Phone Number',
            icon: Icon(
              Icons.phone,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldKey,
      appBar: AppBar(title: Text('Crafts By MG')),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _showTitle(),
                  _showUsenameInput(),
                  _showEmailInput(),
                  _showPasswordInput(),
                  _showAddressInput(),
                  _showAPhoneNumberInput(),
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
          _isSubmitting == true
              ? CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation(Theme.of(context).primaryColor))
              : RaisedButton(
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
                  color: Theme.of(context).primaryColor),
          FlatButton(
            child: Text('Existing User? Login'),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
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

  void _registerUser() async {
    setState(() {
      _isSubmitting = true;
    });

    http.Response cartResponse =
        await http.post('http://192.168.1.105:1337/carts');
    final cartResponseData = json.decode(cartResponse.body);

    
    // http.Response stripeResponse =
    //     await http.get('http://192.168.1.105:3000/weather?email=' + _email);

    // final stripeResponseData = json.decode(stripeResponse.body);


    // print(stripeResponseData);

    //final stripeData = addCustomerId(_email);

    //print('customer stripe Id: '+ stripeData.toString());

    http.Response response =
        await http.post('http://192.168.1.105:1337/auth/local/register', body: {
      "username": _username,
      "email": _email,
      "password": _password,
      "cart_id": cartResponseData['id'],
      //"customer_id": stripeResponseData['customerId'],
      "address": _address,
      "PhoneNumber": _phoneNumber
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

      final String errorMsg = responseData['message'];

      _showErrorSnack(errorMsg);
    }
  }

  void _showSuccessSnack() {
    final snackbar = SnackBar(
        content: Text('User $_username successfully created!',
            style: TextStyle(color: Colors.green)));

    _scafoldKey.currentState.showSnackBar(snackbar);

    _formKey.currentState.reset();
  }

  void _redirectUser() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  void _showErrorSnack(String errorMsg) {
    final snackbar =
        SnackBar(content: Text(errorMsg, style: TextStyle(color: Colors.red)));

    _scafoldKey.currentState.showSnackBar(snackbar);

    throw Exception('Error registering: $errorMsg');
  }

  Future addCustomerId(String email) async {
    final url = 'http://192.168.1.105:3000/weather?email=' + email;
    http.Response stripeResponse = await http.get(url);
    final data = json.decode(stripeResponse.body);

    var customerId = data['customerId'];
    return customerId;
  }

  void _storeUserData(responseData) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> user = responseData['user'];
    user.putIfAbsent('jwt', () => responseData['jwt']);

    prefs.setString('user', json.encode(user));
  }
}
