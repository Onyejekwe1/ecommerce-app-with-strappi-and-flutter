import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:materialgurl_store/models/app_state.dart';
import 'package:materialgurl_store/redux/actions.dart';
import 'package:materialgurl_store/widgets/product_item.dart';
import 'package:badges/badges.dart';

final gradientBackground = BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        stops: [
      0.1,
      0.3,
      0.5,
      0.7,
      0.9
    ],
        colors: [
      Colors.indigo[300],
      Colors.indigo[400],
      Colors.indigo[500],
      Colors.indigo[600],
      Colors.indigo[700],
    ]));

class ProductsPage extends StatefulWidget {
  final void Function() onInit;

  ProductsPage({this.onInit});

  @override
  ProductsPageState createState() => ProductsPageState();
}

class ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  final _appBar = PreferredSize(
      preferredSize: Size.fromHeight(60.0),
      child: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return AppBar(
            centerTitle: true,
            leading: state.user != null
                ? BadgeIconButton(
                    itemCount: state.cartProducts.length,
                    badgeColor: Colors.lime,
                    badgeTextColor: Colors.black,
                    icon: Icon(Icons.store),
                    hideZeroCount: false,
                    onPressed: () => Navigator.pushNamed(context, '/cart'))
                : Text(''),
            title: SizedBox(
                child: state.user != null
                    ? Text(state.user.username)
                    : FlatButton(
                        child: Text('Register Here',
                            style: Theme.of(context).textTheme.body1),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'))),
            actions: [
              Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: StoreConnector<AppState, VoidCallback>(
                    converter: (store) {
                      return () => store.dispatch(logoutUserAction);
                    },
                    builder: (_, callback) {
                      return state.user != null
                          ? IconButton(
                              icon: Icon(Icons.exit_to_app),
                              onPressed: callback)
                          : Text('');
                    },
                  ))
            ],
          );
        },
      ));

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
        appBar: _appBar,
        body: Container(
            decoration: gradientBackground,
            child: StoreConnector<AppState, AppState>(
              converter: (store) => store.state,
              builder: (_, state) {
                return Column(
                  children: [
                    Expanded(
                        child: SafeArea(
                            top: false,
                            bottom: false,
                            child: GridView.builder(
                                itemCount: state.products.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            orientation == Orientation.portrait
                                                ? 2
                                                : 3,
                                        crossAxisSpacing: 4.0,
                                        mainAxisSpacing: 4.0,
                                        childAspectRatio:
                                            orientation == Orientation.portrait
                                                ? 1.0
                                                : 1.3),
                                itemBuilder: (context, i) =>
                                    ProductItem(item: state.products[i]))))
                  ],
                );
              },
            )));
  }
}
