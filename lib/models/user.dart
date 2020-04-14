import 'package:flutter/cupertino.dart';

class User {
  String id;
  String username;
  String email;
  String jwt;
  String cartId;
  String customerId;
  String address;
  String phonenumber;

  User(
      {@required this.id,
      @required this.username,
      @required this.email,
      @required this.jwt,
      @required this.cartId,
      @required this.customerId,
      @required this.address,
      @required this.phonenumber});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        email: json['email'],
        id: json['_id'],
        username: json['username'],
        jwt: json['jwt'],
        cartId: json['cart_id'],
        customerId: json['customer_id'],
        address: json['address'],
        phonenumber: json['PhoneNumber']);
  }
}
