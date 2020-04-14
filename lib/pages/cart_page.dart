import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:materialgurl_store/models/app_state.dart';
import 'package:materialgurl_store/models/order.dart';
import 'package:materialgurl_store/models/paystack.dart';
import 'package:materialgurl_store/redux/actions.dart';
import 'package:materialgurl_store/widgets/product_item.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_paystack/flutter_paystack.dart';

class CartPage extends StatefulWidget {
  final void Function() onInit;

  CartPage({this.onInit});

  @override
  CartPageState createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmitting = false;

  var publicKey = 'pk_test_fd323208ec2b9374640ed6a7e1517b442f6bf712';

  void initState() {
    super.initState();
    widget.onInit();

    PaystackPlugin.initialize(publicKey: publicKey);
  }

  String calculateTotalPrice(cartProducts) {
    double totalPrice = 0.0;

    cartProducts.forEach((cartProduct) {
      totalPrice += cartProduct.price;
    });

    return totalPrice.toStringAsFixed(2);
  }

  Future _showSuccessDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Success!'),
            children: [
              Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                      'Order Successful! \n\n Check your email for a receipt of your purchase!\n\n Order Summary will Apprear in your orders tab',
                      style: Theme.of(context).textTheme.body1))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (_, state) {
          return ModalProgressHUD(
            child: DefaultTabController(
              length: 3,
              initialIndex: 0,
              child: Scaffold(
                key: _scaffoldKey,
                floatingActionButton: state.cartProducts.length > 0
                    ? FloatingActionButton(
                        child: Icon(Icons.local_atm, size: 30.0),
                        onPressed: () => _showCheckoutDialog(state),
                      )
                    : Text(''),
                appBar: AppBar(
                  title: Text(
                      'Summary: ${state.cartProducts.length} Item(s) . \₦${calculateTotalPrice(state.cartProducts)}'),
                  bottom: TabBar(
                    labelColor: Colors.deepPurpleAccent[600],
                    unselectedLabelColor: Colors.deepPurpleAccent[900],
                    tabs: [
                      Tab(icon: Icon(Icons.shopping_cart)),
                      Tab(icon: Icon(Icons.credit_card)),
                      Tab(icon: Icon(Icons.receipt))
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    _cartTab(state),
                    _cardsTab(state),
                    _ordersTab(state)
                  ],
                ),
              ),
            ),
            inAsyncCall: _isSubmitting,
          );
        });
  }

  Widget _ordersTab(state) {
    return ListView(
        children: state.orders.length > 0
            ? state.orders
                .map<Widget>((order) => (ListTile(
                    title: Text('\₦${order.amount}'),
                    subtitle: Text(order.createdAt),
                    leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.attach_money,
                          color: Colors.white,
                        )))))
                .toList()
            : [
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.close, size: 60.0),
                      Text(
                        'No Orders Yet',
                        style: Theme.of(context).textTheme.title,
                      )
                    ],
                  ),
                )
              ]);
  }

  Widget _cardsTab(state) {
    return Text('Cards');
  }

  Future<CheckoutResponse> _initializeTranzaction(ref, amount, email) async {
    String internaRef = ref;
    String internalAmount = amount;
    String internalEmail = email;
    String url = 'https://api.paystack.co/transaction/initialize/';
    final token = 'sk_test_17aa5701e0e7374936ae11611d1dbc211ef595f4';
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json", // or whatever
      HttpHeaders.authorizationHeader: "Bearer $token",
    };

    String data =
        '{"reference": "$internaRef", "amount": "$internalAmount", "email": "$internalEmail", "currency": "NGN"}';

    // make POST request
    http.Response response = await http.post(url, headers: headers, body: data);
    // check the status code for the result
    final Map parsed = json.decode(response.body);
    final paystackData = Paystack.fromJson(parsed);
    var cardAmount = double.parse(internalAmount).toStringAsFixed(0);
    
    Charge charge = Charge()
      ..amount = int.parse(cardAmount) * 100
      ..accessCode = paystackData.data.accessCode
      ..email = internalEmail;

    CheckoutResponse checkOutResponse = await PaystackPlugin.checkout(context,
        charge: charge, method: CheckoutMethod.selectable);
    return checkOutResponse;
  }

  // Future<void> _acceptPayment(amount) async {
  //   Charge charge = Charge()
  //     ..amount = amount
  //     ..reference = 'testRef'
  //     ..email = 'ifeanyiwisdom25@yahoo.com';

  //   CheckoutResponse response = await PaystackPlugin.checkout(context,
  //       charge: charge, method: CheckoutMethod.card);
  // }

  Widget _cartTab(state) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Column(
      children: [
        // Padding(padding: EdgeInsets.only(top: 10.0)),
        // RaisedButton(
        //     elevation: 8.0,
        //     child: Text('Check Out'),
        //     onPressed: () {
        //       //_acceptPayment(5000);
        //       _initializeTranzaction();
        //     }),
        Expanded(
            child: SafeArea(
                top: false,
                bottom: false,
                child: GridView.builder(
                    itemCount: state.cartProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            orientation == Orientation.portrait ? 2 : 3,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                        childAspectRatio:
                            orientation == Orientation.portrait ? 1.0 : 1.3),
                    itemBuilder: (context, i) =>
                        ProductItem(item: state.cartProducts[i]))))
      ],
    );
  }

  Future _showCheckoutDialog(AppState state) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          String cartSummary = '';

          state.cartProducts.forEach((cartProduct) {
            cartSummary += ". ${cartProduct.name}, \₦${cartProduct.price}\n";
          });

          var clientAddress = new RichText(
            text: new TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: new TextStyle(fontSize: 14.0, color: Colors.white),
              children: <TextSpan>[
                new TextSpan(
                    text: 'Address: ',
                    style: new TextStyle(fontWeight: FontWeight.bold)),
                new TextSpan(text: '${state.user.address}'),
              ],
            ),
          );

          var clientNumber = new RichText(
            text: new TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: new TextStyle(
                  fontSize: 14.0, color: Colors.white, height: 1.5),
              children: <TextSpan>[
                new TextSpan(
                    text: 'Phone Number: ',
                    style: new TextStyle(fontWeight: FontWeight.bold)),
                new TextSpan(text: '${state.user.phonenumber}\n'),
              ],
            ),
          );
          return AlertDialog(
            title: Text('Checkout'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('CART ITEMS (${state.cartProducts.length})\n',
                      style: Theme.of(context).textTheme.body1),
                  Text('$cartSummary',
                      style: Theme.of(context).textTheme.body1),

                  Text('CUSTOMER INFO',
                      style: Theme.of(context).textTheme.body1),
                  clientAddress,
                  clientNumber,
                  //  Text('Bustop: $primaryCard', style: Theme.of(context).textTheme.body1),

                  Text(
                      'ORDER TOTAL: \₦${calculateTotalPrice(state.cartProducts)}',
                      style: Theme.of(context).textTheme.body1)
                ],
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: () => Navigator.pop(context, false),
                  color: Colors.red,
                  child: Text('Close', style: TextStyle(color: Colors.white))),
              RaisedButton(
                  onPressed: () => Navigator.pop(context, true),
                  color: Colors.green,
                  child:
                      Text('Checkout', style: TextStyle(color: Colors.white)))
            ],
          );
        }).then((value) async {
      _checkoutCartProducts() async {
        var rng = new Random();
        var code = rng.nextInt(900000) + 100000;
        String ref = state.user.username + "-" + code.toString();
        final paymentResponse = await _initializeTranzaction(
            ref, calculateTotalPrice(state.cartProducts), state.user.email);

        if (paymentResponse.status == true &&
            paymentResponse.message == "Success") {
          http.Response response =
              await http.post('http://192.168.1.105:1337/orders', body: {
            "amount": calculateTotalPrice(state.cartProducts),
            "products": jsonEncode(state.cartProducts),
            "user": state.user.id
          }, headers: {
            'Authorization': 'Bearer ${state.user.jwt}'
          });

          final responseData = json.decode(response.body);
          return responseData;
        }
      }

      if (value == true) {
        setState(() => _isSubmitting = true);

        final newOrderData = await _checkoutCartProducts();

        Order newOrder = Order.fromJson(newOrderData);

        StoreProvider.of<AppState>(context).dispatch(AddOrderAction(newOrder));

        StoreProvider.of<AppState>(context).dispatch(clearCartProductsAction);

        setState(() => _isSubmitting = false);

        _showSuccessDialog();
      }
    });
  }
}
