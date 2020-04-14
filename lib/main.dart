import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:materialgurl_store/models/app_state.dart';
import 'package:materialgurl_store/pages/cart_page.dart';
import 'package:materialgurl_store/pages/login_page.dart';
import 'package:materialgurl_store/pages/products_page.dart';
import 'package:materialgurl_store/pages/register_page.dart';
import 'package:materialgurl_store/redux/actions.dart';
import 'package:materialgurl_store/redux/reducers.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';

void main() {
  final store = Store<AppState>(appReducer,
      initialState: AppState.initial(),
      middleware: [thunkMiddleware, LoggingMiddleware.printer()]);
  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  MyApp({this.store});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
        store: store,
        child: MaterialApp(
          title: 'MaterialGurl Store',
          routes: {
            '/': (BuildContext context) => ProductsPage(onInit: () {
                  StoreProvider.of<AppState>(context).dispatch(getUserAction);
                  StoreProvider.of<AppState>(context)
                      .dispatch(getProductsAction);

                   StoreProvider.of<AppState>(context)
                      .dispatch(getCartProductsAction);

                }),
            '/login': (BuildContext context) => LoginPage(),
            '/register': (BuildContext context) => RegisterPage(),
            '/cart': (BuildContext context) => CartPage(
              onInit: (){
                StoreProvider.of<AppState>(context).dispatch(getCardsAction);
              },
            )
          },
          theme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: Colors.brown[200],
              accentColor: Colors.green[800],
              textTheme: TextTheme(
                  headline:
                      TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
                  title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
                  body1: TextStyle(fontSize: 18.0))),
        ));
  }
}
