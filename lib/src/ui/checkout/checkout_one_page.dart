import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:scoped_model/scoped_model.dart';
//import 'package:stripe_payment/stripe_payment.dart';
import '../widgets/buttons/button_text.dart';
import '../../blocs/checkout_bloc.dart';
import '../../functions.dart';
import '../../models/app_state_model.dart';
import '../../models/checkout/order_result_model.dart';
import '../../models/checkout/order_review_model.dart';
//import '../../models/checkout/stripeSource.dart' hide Card;
//import '../../models/checkout/stripe_token.dart' hide Card;
import '../../ui/checkout/webview.dart';
import '../color_override.dart';
import 'order_summary.dart';
import 'payment/payment_card.dart';
import 'package:intl/intl.dart';

class CheckoutOnePage extends StatefulWidget {
  final CheckoutBloc homeBloc;
  final appStateModel = AppStateModel();
  CheckoutOnePage({this.homeBloc});
  @override
  _CheckoutOnePageState createState() => _CheckoutOnePageState();
}

class _CheckoutOnePageState extends State<CheckoutOnePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  String _error;

  var isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.appStateModel.blocks.localeText.checkout),
      ),
      body: SafeArea(
        child: StreamBuilder<OrderReviewModel>(
            stream: widget.homeBloc.orderReview,
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? _buildCheckoutForm(snapshot, context)
                  : Center(
                      child: CircularProgressIndicator(),
                    );
            }),
      ),
    );
  }

  Widget _buildCheckoutForm(
      AsyncSnapshot<OrderReviewModel> snapshot, BuildContext context) {
    return ScopedModelDescendant<AppStateModel>(
        builder: (context, child, model) {
      return CustomScrollView(
        slivers: slivers(snapshot, context, model),
      );
    });
  }

  List<Widget> slivers(AsyncSnapshot<OrderReviewModel> snapshot,
      BuildContext context, AppStateModel model) {
    TextStyle subhead = Theme.of(context)
        .textTheme
        .subhead
        .copyWith(fontWeight: FontWeight.w600);

    List<Widget> list = new List<Widget>();

    if (snapshot.data.shipping.length > 0) {
      for (var i = 0; i < snapshot.data.shipping.length; i++) {
        if (snapshot.data.shipping[i].shippingMethods.length > 0) {
          list.add(SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
            child: Text(
              snapshot.data.shipping[i].packageName,
              style: subhead,
            ),
          )));

          list.add(_buildShippingList(snapshot, i));
        }
      }

      list.add(SliverToBoxAdapter(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
        child: Divider(
          color: Theme.of(context).dividerColor,
          height: 10.0,
        ),
      )));
    }

    if(model.deliveryDate?.bookableDates != null) {
      list.add(
          _buildDeliveryDate(model)
      );

      if(model.deliverySlot != null && model.deliverySlot[model.selectedDate]?.slots != null) {
        list.add(
            _buildDeliveryTimeSlot(model)
        );
      } else {
        list.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
        );
      }
    }



    list.add(SliverToBoxAdapter(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
      child: Text(
        widget.appStateModel.blocks.localeText.paymentMethod,
        // widget.appStateModel.blocks.localeText.payment,
        style: subhead,
      ),
    )));

    list.add(_buildPaymentList(snapshot));

    list.add(SliverToBoxAdapter(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 8.0),
      child: Text(
        widget.appStateModel.blocks.localeText.order,
        style: subhead,
      ),
    )));
    list.add(_buildOrderList(snapshot));

    list.add(SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RaisedButton(
              elevation: 0,
              child: ButtonText(
                  isLoading: isLoading,
                  text: widget
                      .appStateModel.blocks.localeText.localeTextContinue),
              onPressed: () => isLoading ? null : _placeOrder(snapshot),
            ),
            StreamBuilder<OrderResult>(
                stream: widget.homeBloc.orderResult,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.result == "failure") {
                    return Center(
                      child: Container(
                          padding: EdgeInsets.all(4.0),
                          child: Text(parseHtmlString(snapshot.data.messages),
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle
                                  .copyWith(
                                      color: Theme.of(context).errorColor))),
                    );
                  } else if (snapshot.hasData &&
                      snapshot.data.result == "success") {
                    return Container();
                  } else {
                    return Container();
                  }
                }),
          ],
        ),
      ),
    ));

    return list;
  }

  _buildDeliveryDate(AppStateModel model) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(8),
        height: 100.0,
        width: 120.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: model.deliveryDate.bookableDates.length,
          itemBuilder: (context, index) {
            List<String> str =
            model.deliveryDate.bookableDates[index].split('/');
            DateTime now = new DateTime(
                int.parse(str[2]), int.parse(str[1]), int.parse(str[0]));
            final DateFormat formatter = DateFormat('EEEE, dd MMM');
            final String formatted = formatter.format(now);
            // DateFormat.yMMMEd().format(dt);
            //final String formatted = DateFormat.MMMEd().format(now);
            String date = str[2] + str[1] + str[0];
            return Container(
              width: MediaQuery.of(context).size.width * 0.32,
              child: GestureDetector(
                child: Card(
                  color: model.selectedDate == date
                      ? Color(0xff027dcb)
                      : Colors.white,
                  child: InkWell(
                    highlightColor: Colors.lightGreen,
                    borderRadius: BorderRadius.circular(4.0),
                    onTap: () async {
                      setState(() {
                        isLoading = false;
                      });
                      model.setDate(date, model.deliveryDate.bookableDates[index]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: ListTile(
                        //title: Text(widget.appStateModel.blocks.localeText.address, style: Theme.of(context).textTheme.subtitle),
                        subtitle: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Center(
                              child: Text(
                                formatted,
                                style: TextStyle(
                                  color: model.selectedDate ==
                                      date
                                      ? Colors.white
                                      : Color(0xff027dcb),
                                ),
                              )),
                        ),
                      ),

                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _buildDeliveryTimeSlot(AppStateModel model) {
    double cWidth = MediaQuery.of(context).size.width * 0.8;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          return RadioListTile(
            value: model
                .deliverySlot[model.selectedDate]
                .slots[index]
                .value,
            groupValue: model.selectedTime,
            onChanged: (String value) {
              setState(() {
                isLoading = false;
              });
              model.setDeliveryTime(value);
            },
            title: Container(
                width: cWidth,
                child: Text(model
                    .deliverySlot[model.selectedDate]
                    .slots[index]
                    .formatted)),
          );
        },
        childCount: model
            .deliverySlot[model.selectedDate]
            .slots
            .length,
      ),
    );
  }

  _buildShippingList(AsyncSnapshot<OrderReviewModel> snapshot, int i) {
    print(snapshot.data.shipping[i].shippingMethods.length);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          print(snapshot.data.shipping[i].shippingMethods[index].label);
          return RadioListTile<String>(
            value: snapshot.data.shipping[i].shippingMethods[index].id,
            groupValue: snapshot.data.shipping[i].chosenMethod,
            onChanged: (String value) {
              setState(() {
                snapshot.data.shipping[i].chosenMethod = value;
              });
              widget.homeBloc.updateOrderReview2();
            },
            title: Text(snapshot.data.shipping[i].shippingMethods[index].label +
                ' ' +
                parseHtmlString(
                    snapshot.data.shipping[i].shippingMethods[index].cost)),
          );
        },
        childCount: snapshot.data.shipping[i].shippingMethods.length,
      ),
    );
  }

  _buildPaymentList(AsyncSnapshot<OrderReviewModel> snapshot) {
    double cWidth = MediaQuery.of(context).size.width * 0.8;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          Widget paymentTitle = snapshot.data.paymentMethods[index].id ==
                  'wallet'
              ? Row(
                  children: [
                    Text(parseHtmlString(
                        snapshot.data.paymentMethods[index].title)),
                    SizedBox(width: 8),
                    Text(
                      parseHtmlString(snapshot.data.balanceFormatted),
                      style: Theme.of(context).textTheme.subtitle2,
                    )
                  ],
                )
              : Text(
                  parseHtmlString(snapshot.data.paymentMethods[index].title));
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Radio<String>(
                  value: snapshot.data.paymentMethods[index].id,
                  groupValue: widget.homeBloc.formData['payment_method'],
                  onChanged: (String value) {
                    setState(() {
                      isLoading = false;
                      widget.homeBloc.formData['payment_method'] = value;
                    });
                    widget.homeBloc.updateOrderReview2();
                  },
                ),
                Container(width: cWidth, child: paymentTitle),
              ],
            ),
          );
        },
        childCount: snapshot.data.paymentMethods.length,
      ),
    );
  }

  _buildOrderList(AsyncSnapshot<OrderReviewModel> snapshot) {
    final smallAmountStyle = Theme.of(context).textTheme.body1;
    final largeAmountStyle = Theme.of(context).textTheme.title;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                      widget.appStateModel.blocks.localeText.subtotal + ':'),
                ),
                Text(
                  parseHtmlString(snapshot.data.totals.subtotal),
                  style: smallAmountStyle,
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                      widget.appStateModel.blocks.localeText.shipping + ':'),
                ),
                Text(
                  parseHtmlString(snapshot.data.totals.shippingTotal),
                  style: smallAmountStyle,
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Expanded(
                  child: Text(widget.appStateModel.blocks.localeText.tax + ':'),
                ),
                Text(
                  parseHtmlString(snapshot.data.totals.totalTax),
                  style: smallAmountStyle,
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(widget.appStateModel.blocks.localeText.discount),
                ),
                Text(
                  parseHtmlString(snapshot.data.totals.discountTotal),
                  style: smallAmountStyle,
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.appStateModel.blocks.localeText.total,
                    style: largeAmountStyle,
                  ),
                ),
                Text(
                  parseHtmlString(snapshot.data.totals.total),
                  style: largeAmountStyle,
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: PrimaryColorOverride(
                      child: TextFormField(
                        maxLines: 2,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText:
                              widget.appStateModel.blocks.localeText.orderNote,
                          errorMaxLines: 1,
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 0.5),
                          ),
                        ),
                        onChanged: (value) {
                          print(value);
                          widget.homeBloc.formData['order_comments'] = value;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  openWebView(String url) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewPage(
                url: url,
                selectedPaymentMethod:
                    widget.homeBloc.formData['payment_method'])));
  }

  void orderDetails(OrderResult orderResult) {
    String str = orderResult.redirect;
    int pos1 = str.lastIndexOf("/order-received/");
    int pos2 = str.lastIndexOf("/?key=wc_order");
    var orderId = str.substring(pos1 + 16, pos2);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OrderSummary(
                  id: orderId,
                )));
  }

  _placeOrder(AsyncSnapshot<OrderReviewModel> snapshot) async {
    setState(() {
      isLoading = true;
    });
    if (widget.homeBloc.formData['payment_method'] == 'stripe') {
      
    } else {
      OrderResult orderResult = await widget.homeBloc.placeOrder();
      if (orderResult.result == 'success') {
        if (widget.homeBloc.formData['payment_method'] == 'cod' ||
            widget.homeBloc.formData['payment_method'] == 'wallet' ||
            widget.homeBloc.formData['payment_method'] == 'cheque' ||
            widget.homeBloc.formData['payment_method'] == 'bacs' ||
            widget.homeBloc.formData['payment_method'] == 'paypalpro') {
          orderDetails(orderResult);
          setState(() {
            isLoading = false;
          });
        } else if (widget.homeBloc.formData['payment_method'] == 'payuindia' ||
            widget.homeBloc.formData['payment_method'] == 'paytm') {
          openWebView(orderResult.redirect);
          setState(() {
            isLoading = false;
          });
          //Navigator.push(context, MaterialPageRoute(builder: (context) => PaytmPage()));
        } else if (widget.homeBloc.formData['payment_method'] == 'woo_mpgs') {
          bool status = await widget.homeBloc
              .processCredimaxPayment(orderResult.redirect);
          openWebView(orderResult.redirect);
          setState(() {
            isLoading = false;
          });
        } else if (widget.homeBloc.formData['payment_method'] == 'razorpay') {
          openWebView(orderResult.redirect);
          //processRazorPay(snapshot, orderResult); // Uncomment this for SDK Payment
          //openWebView(orderResult.redirect); // Uncomment this for Webview Payment
        } else if (widget.homeBloc.formData['payment_method'] == 'paystack') {
          openWebView(orderResult.redirect);
          //processPayStack(snapshot, orderResult); // Uncomment this for SDK Payment
          //openWebView(orderResult.redirect); // Uncomment this for Webview Payment
        } else {
          openWebView(orderResult.redirect);
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        // Order result is faliure
      }
    }
  }

  /// PayStack Payment.
  Future<void> processPayStack(
      AsyncSnapshot<OrderReviewModel> snapshot, OrderResult orderResult) async {
    String str = orderResult.redirect;
    int pos1 = str.lastIndexOf("/order-pay/");
    int pos2 = str.lastIndexOf("/?key=wc_order");
    var orderId = str.substring(pos1 + 11, pos2);
    var publicKey = snapshot.data.paymentMethods
        .singleWhere((method) => method.id == 'paystack')
        .payStackPublicKey;
    await PaystackPlugin.initialize(publicKey: publicKey);
    setState(() {
      isLoading = false;
    });
    Charge charge = Charge()
      ..amount = num.parse(snapshot.data.totalsUnformatted.total).round() * 100
      ..reference = orderId
      ..email = widget.homeBloc.formData['billing_email'];
    CheckoutResponse response = await PaystackPlugin.checkout(
      context,
      method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
      charge: charge,
    );
    if (response.message == 'success') {}
  }

  /// RazorPay Payment.
  Future<void> processRazorPay(
      AsyncSnapshot<OrderReviewModel> snapshot, OrderResult orderResult) {
    /*String str = orderResult.redirect;
    int pos1 = str.lastIndexOf("/order-pay/");
    int pos2 = str.lastIndexOf("/?key=wc_order");
    var orderId = str.substring(pos1 + 11, pos2);
    Razorpay _razorPay;
    _razorPay = Razorpay();
    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
    Fluttertoast.showToast(msg: "SUCCESS"+response.paymentId);
      orderDetails(orderResult);
    });
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    var options = {
      'key': snapshot.data.paymentMethods.singleWhere((method) => method.id == 'razorpay').settings.razorPayKeyId,
      'amount': num.parse(snapshot.data.totalsUnformatted.total) * 100,
      'name': widget.homeBloc.formData['billing_name'],
      'description': 'Payment for Order' + orderId,
      'profile': {'contact': '', 'email': widget.homeBloc.formData['billing_email'],
        'external': {
          'wallets': ['paytm']
        }}
    };
    try{
      _razorPay.open(options);
      setState(() { isLoading = false; });
    }
    catch(e){
      setState(() { isLoading = false; });
      debugPrint(e);
    }*/
  }

  /*void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(msg: "SUCCESS"+response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "ERROR"+response.code.toString()+ '-' + response.message) ;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "EXTERNAL WALLET" + response.walletName);
  }*/

  

  void setError(dynamic error) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(error.toString())));
    setState(() {
      _error = error.toString();
    });
  }
}
