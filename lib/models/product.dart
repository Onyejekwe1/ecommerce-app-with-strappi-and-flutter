import 'package:flutter/cupertino.dart';

class Product {
  String id;
  String name;
  String description;
  num price;
  dynamic picture;
  // Map<String, dynamic> picture;

  Product(
      {@required this.id,
      @required this.description,
      @required this.name,
      @required this.picture,
      @required this.price});


  Map<String, dynamic> toJson(){
    return {
      "id": id,
      "name":name,
      "description": description,
      "price": price,
      "picture": picture
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id: json['id'],
        description: json['description'],
        name: json['name'],
        picture: json['picture'],
        price: json['price']);
  }
}
