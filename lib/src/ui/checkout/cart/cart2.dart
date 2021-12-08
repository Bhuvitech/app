import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../../functions.dart';
import '../../../models/app_state_model.dart';
import '../../../blocs/checkout_bloc.dart';
import '../../../models/cart/cart_model.dart';
import 'package:intl/intl.dart';
import '../../../models/checkout/checkout_form_model.dart';
import '../../../models/country_model.dart';
import '../../../resources/countires.dart';
import '../address.dart';

const double _leftColumnWidth = 60.0;

class CartPage extends StatefulWidget {
  final homeBloc = CheckoutBloc();
  final appStateModel = AppStateModel();
  CartPage({Key key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    widget.appStateModel.getCart();
    widget.homeBloc.getCheckoutForm();
    widget.homeBloc.checkoutForm.listen((onData) => setAddressCountry(onData));
  }

  List<Widget> _createShoppingCartRows(CartModel shoppingCart) {
    int id;
    return shoppingCart.cartContents
        .map(
          (CartContent content) => ShoppingCartRow(
            product: content,
            quantity: content.quantity,
            onPressed: () {
              widget.appStateModel.removeItemFromCart(content.key);
            },
            onIncreaseQty: () {
              widget.appStateModel.increaseQty(content.key, content.quantity);
            },
            onDecreaseQty: () {
              widget.appStateModel.decreaseQty(content.key, content.quantity);
            },
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData localTheme = Theme.of(context);
    return SafeArea(
      child: ScopedModelDescendant<AppStateModel>(
          builder: (context, child, model) {
        if (model.shoppingCart?.cartContents == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (model.shoppingCart.cartContents.length != 0) {
          return buildCart(localTheme, model.shoppingCart);
        } else {
          return Center(
            child: Text(widget.appStateModel.blocks.localeText.emptyCart),
          );
        }
        ;
      }),
    );
  }

  Stack buildCart(ThemeData localTheme, CartModel shoppingCart) {
    return Stack(children: <Widget>[
      ListView(
        children: <Widget>[
          SizedBox(height: 16.0),
          Column(
            children: _createShoppingCartRows(shoppingCart),
          ),
        ],
      ),
      buildTotals(context, shoppingCart)
    ]);
  }

  setAddressCountry(CheckoutFormModel onData) {
    if (onData.billingCountry != null && onData.billingCountry.isNotEmpty) {
      widget.homeBloc.initialSelectedCountry = onData.billingCountry;
    }
    if (onData.billingState != null && onData.billingState.isNotEmpty) {
      List<CountryModel> countries =
          countryModelFromJson(JsonStrings.listOfSimpleObjects);
      CountryModel country =
          countries.singleWhere((item) => item.value == onData.billingCountry);
      if (country.regions != null &&
          country.regions.any((item) => item.value == onData.billingState)) {
        widget.homeBloc.formData['billing_state'] = onData.billingState;
      } else
        widget.homeBloc.formData['billing_state'] = null;
    }
  }

  Positioned buildTotals(BuildContext context, CartModel shoppingCart) {
    return Positioned(
        bottom: 0,
        height: 120,
        width: MediaQuery.of(context).size.width,
        child: Container(
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width - 24,
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        widget.appStateModel.blocks.localeText.total,
                        style: TextStyle(
                          fontFamily: 'Bold',
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            parseHtmlString(shoppingCart.cartTotals.total),
                            style: TextStyle(
                              fontFamily: 'Bold',
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 24,
                  child: RaisedButton(
                    child: Text(
                      widget.appStateModel.blocks.localeText.checkout,
                      style: TextStyle(
                        fontFamily: 'Bold',
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Address(homeBloc: widget.homeBloc)));
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      // side: BorderSide(color: Colors.red)
                    ),
                  ),
                ),
              ],
            )));
  }
}

class ShoppingCartRow extends StatelessWidget {
  const ShoppingCartRow(
      {@required this.product,
      @required this.quantity,
      this.onPressed,
      this.onIncreaseQty,
      this.onDecreaseQty});

  final CartContent product;
  final int quantity;
  final VoidCallback onPressed;
  final VoidCallback onIncreaseQty;
  final VoidCallback onDecreaseQty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Container(
            height: 125,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Image.network(
                  product.thumb,
                  fit: BoxFit.cover,
                  width: 80.0,
                  height: 130.0,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                      padding: EdgeInsets.all(2),
                      height: 120,
                      width: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16.0,
                            ),
                          ),
                          Container(
                            height: 30,
                            width: 160,
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: OutlineButton(
                                      child: Icon(
                                        Icons.remove,
                                        color: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .color,
                                        size: 25,
                                      ),
                                      padding: EdgeInsets.all(1),
                                      color: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .color,
                                      onPressed: onDecreaseQty,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(0),
                                              topLeft: Radius.circular(0)))),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 3),
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        width: 0.0,
                                        color: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .color,
                                      ),
                                      bottom: BorderSide(
                                        width: 0.0,
                                        color: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .color,
                                      ),
                                    ),
                                  ),
                                  child: product.loadingQty
                                      ? Container(
                                          width: 30,
                                          height: 30,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1.0,
                                              ),
                                            ),
                                          ))
                                      : Container(
                                          width: 30,
                                          height: 30,
                                          child: Center(
                                              child: Text(
                                            product.quantity.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16),
                                          ))), /*Text(
                                        product.quantity.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),*/
                                ),
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: OutlineButton(
                                      child: Icon(
                                        Icons.add,
                                        color: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .color,
                                        size: 25,
                                      ),
                                      padding: EdgeInsets.all(1),
                                      onPressed: onIncreaseQty,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(0),
                                              topRight: Radius.circular(0)))),
                                )
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Container(
                      height: 120,
                      width: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                              child: Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              onTap: onPressed,
                              child: Icon(Icons.clear),
                            ),
                          )),
                          Container(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                parseHtmlString(product.formattedPrice),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                )
              ],
            ),
          ),
        ),
        Divider(height: 0.0),
      ],
    );
  }
}
