import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:materialgurl_store/models/app_state.dart';
import 'package:materialgurl_store/models/product.dart';
import 'package:materialgurl_store/pages/products_page.dart';
import 'package:materialgurl_store/redux/actions.dart';

class ProductDetailPage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Product item;

  ProductDetailPage({this.item});

  bool _isInCart(AppState state, String id) {
    final List<Product> cartProducts = state.cartProducts;

    return cartProducts.indexWhere((cartProduct) => cartProduct.id == id) > -1;
  }

  @override
  Widget build(BuildContext context) {
    final String pictureUrl =
        'http://192.168.1.105:1337${item.picture[0]['url']}';
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: Container(
        decoration: gradientBackground,
        child: Column(
          children: [
            Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Hero(
                  tag: item,
                  child: Image.network(
                    pictureUrl,
                    fit: BoxFit.cover,
                    width: orientation == Orientation.portrait ? 600 : 250,
                    height: orientation == Orientation.portrait ? 400 : 200,
                  ),
                )),
            Text(item.name, style: Theme.of(context).textTheme.title),
            Text('\₦${item.price}', style: Theme.of(context).textTheme.body1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: StoreConnector<AppState, AppState>(
                converter: (store) => store.state,
                builder: (_, state) {
                  return state.user != null
                      ? IconButton(
                          icon: Icon(Icons.shopping_cart),
                          color: _isInCart(state, item.id)
                              ? Colors.cyan[700]
                              : Colors.white,
                          onPressed: () {
                            StoreProvider.of<AppState>(context)
                                .dispatch(toggleCartProductAction(item));
                            final snackBar = SnackBar(
                                duration: Duration(seconds: 2),
                                content: Text('Cart Updated!', style: TextStyle(color: Colors.green),));
                                _scaffoldKey.currentState.showSnackBar(snackBar);
                          })
                      : Text('');
                },
              ),
            ),
            Flexible(
                child: SingleChildScrollView(
                    child: Padding(
                        child: Text(item.description),
                        padding: EdgeInsets.only(
                            bottom: 32.0, right: 32.0, left: 32.0, top: 32.0))))
          ],
        ),
      ),
    );
  }
}
