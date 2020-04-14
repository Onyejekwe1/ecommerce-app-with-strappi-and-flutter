import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:materialgurl_store/models/app_state.dart';
import 'package:materialgurl_store/models/product.dart';
import 'package:materialgurl_store/pages/product_detail_page.dart';
import 'package:materialgurl_store/redux/actions.dart';

class ProductItem extends StatelessWidget {
  final Product item;

  ProductItem({this.item});

  @override
  Widget build(BuildContext context) {
    final String pictureUrl =
        'http://192.168.1.105:1337${item.picture[0]['url']}';
    return InkWell(
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return ProductDetailPage(item: item);
            })),
        child: GridTile(
            footer: GridTileBar(
              title: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(item.name, style: TextStyle(fontSize: 20.0)),
              ),
              subtitle:
                  Text("\₦${item.price}", style: TextStyle(fontSize: 16.0)),
              backgroundColor: Color(0xBB000000),
              trailing: StoreConnector<AppState, AppState>(
                converter: (store) => store.state,
                builder: (_, state) {
                  return state.user != null
                      ? IconButton(
                          icon: Icon(Icons.shopping_cart),
                          color: _isInCart(state, item.id) ? Colors.cyan[700] : Colors.white,
                                                    onPressed: () {
                                                      StoreProvider.of<AppState>(context)
                                                          .dispatch(toggleCartProductAction(item));
                                                    })
                                                : Text('');
                                          },
                                        ),
                                      ),
                                      child: Hero(
                                          tag: item,
                                          child: Image.network(pictureUrl, fit: BoxFit.cover))));
                            }
                          }
                          
                         bool _isInCart(AppState state, String id) {
                           final List<Product> cartProducts = state.cartProducts;

                           return cartProducts.indexWhere((cartProduct) => cartProduct.id == id) > -1;
}
