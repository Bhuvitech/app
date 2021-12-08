import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../blocs/checkout_bloc.dart';
import '../../resources/api_provider.dart';
import 'order_summary.dart';

class WebViewPage2 extends StatefulWidget {
  final String url;
  final String selectedPaymentMethod;
  final CheckoutBloc homeBloc;

  const WebViewPage2(
      {Key key, this.url, this.selectedPaymentMethod, this.homeBloc})
      : super(key: key);

  @override
  _WebViewPage2State createState() => _WebViewPage2State(url: url);
}

class _WebViewPage2State extends State<WebViewPage2> {
  String url;
  final apiProvider = ApiProvider();
  bool _isLoadingPage;
  String orderId;
  String redirect;
  List<Cookie> cookies = [];
  String sessionId;
  String redirectUrl;

  Map<String, String> headers = {
    "content-type": "application/x-www-form-urlencoded; charset=utf-8"
  };

  // InAppWebViewController webView;
  // final CookieManager cookieManager = CookieManager.instance();
  double progress = 0;
  bool sessionCookiesSet = false;

  @override
  void initState() {
    super.initState();
    setSessionCookies();
    _isLoadingPage = true;
    orderId = '0';
    if (url.lastIndexOf("/order-pay/") != -1 &&
        url.lastIndexOf("/?key=wc_order") != -1) {
      var pos1 = url.lastIndexOf("/order-pay/");
      var pos2 = url.lastIndexOf("/?key=wc_order");
      orderId = url.substring(pos1 + 11, pos2);
    }

    if (widget.selectedPaymentMethod == 'woo_mpgs' &&
        url.lastIndexOf("sessionId=") != -1 &&
        url.lastIndexOf("&order=") != -1) {
      var pos1 = url.lastIndexOf("sessionId=");
      var pos2 = url.lastIndexOf("&order=");
      String sessionId = url.substring(pos1 + 10, pos2);
      redirectUrl =
          'https://credimax.gateway.mastercard.com/checkout/pay/' + sessionId;
    } else {
      redirectUrl = url;
    }
    //CookieManager.instance().setCookie(path: '/woocommerce/', domain: '35.238.248.227', url: 'http://35.238.248.227', name: 'woocommerce_items_in_cart', value: '1');
    //CookieManager.instance().setCookie(path: '/woocommerce/', domain: '35.238.248.227', url: 'http://35.238.248.227', name: 'wp_woocommerce_session_df77acd57965c662a89399a300433952', value: '1%7C%7C1578226242%7C%7C1578222642%7C%7C4746c37976b78cf6503cbc02599ed453');
    //CookieManager.instance().setCookie(path: '/woocommerce/', domain: '35.238.248.227', url: 'http://35.238.248.227', name: 'woocommerce_cart_hash', value: 'dce32496c9fba6d0b18cb97591d1090e', expiresDate: 1578594600000);
  }

  Future setSessionCookies() async {
    /*for (var key in apiProvider.cookies.keys) {
      await CookieManager.instance().setCookie(path: '/woocommerce/', domain: '35.238.248.227', url: 'http://35.238.248.227', name: key, value: apiProvider.cookies[key], expiresDate: 1578625795000, isSecure: true, maxAge: 172800);
    }*/
    //CookieManager.instance().deleteAllCookies();
    /* var expiresDate = DateTime.parse("2020-01-08T05:12:18.314Z").millisecondsSinceEpoch;
    await cookieManager.setCookie(path: '/woocommerce/', domain: '35.238.248.227', url: 'http://35.238.248.227', name: 'woocommerce_cart_hash', value: '84337ed45f65479853ac9c64d47cb249', expiresDate: expiresDate);
    await cookieManager.setCookie(path: '/woocommerce/', domain: '35.238.248.227', url: 'http://35.238.248.227', name: 'wp_woocommerce_session_df77acd57965c662a89399a300433952', value: "c9ea3e8004706c6e1bbb8ec48c638bdd%7C%7C1578460338%7C%7C1578456738%7C%7C7b72e09b8aacdb88b294718d82aaab74", expiresDate: expiresDate);
    await cookieManager.setCookie(path: '/woocommerce/', domain: '35.238.248.227', url: 'http://35.238.248.227', name: 'woocommerce_items_in_cart', value: '1', expiresDate: expiresDate);
    await cookieManager.setCookie(path: '/woocommerce/', domain: '35.238.248.227', url: 'http://35.238.248.227', name: 'PHPSESSID', value: 'b94dad1253f62ce2fb89cc916acd1b71', expiresDate: expiresDate);
    setState(() {
      sessionCookiesSet = true;
    });
    getCooks();*/
  }

  Future<void> getCooks() async {
    //CookieManager.instance().deleteAllCookies();
    // List<Cookie> listCook = await CookieManager.instance().getCookies(url: 'http://35.238.248.227');
    // for (var i = 0; i < listCook.length; i++) {
    //print(listCook[i].name);
    //print(listCook[i].value);
    // }
  }

  _WebViewPage2State({this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      body: Container(
          child: Column(children: <Widget>[
        Expanded(
          child: Container(
              /*child: InAppWebView(
                  initialUrl: "http://35.238.248.227/woocommerce",
                  initialHeaders: {},
                  initialOptions: InAppWebViewWidgetOptions(
                      inAppWebViewOptions: InAppWebViewOptions(
                        debuggingEnabled: true,
                      ),
                      iosInAppWebViewOptions: IosInAppWebViewOptions(
                        sharedCookiesEnabled: true,
                      ),
                    androidInAppWebViewOptions: AndroidInAppWebViewOptions(
                        thirdPartyCookiesEnabled: true,
                    )
                  ),
                  onWebViewCreated: (InAppWebViewController controller) async {
                    webView = controller;
                    await webView.evaluateJavascript(source: 'document.cookie = "woocommerce_cart_hash=84337ed45f65479853ac9c64d47cb249;"');
                  },
                  onLoadStart: (InAppWebViewController controller, String url) {
                    getCooks();
                  },
                  onLoadStop: (InAppWebViewController controller, String url) async {
                    
                  },
                ),*/
              ),
        )
      ])),
    );
    /*Container(
        child: Stack(
          children: <Widget>[
            WebView(
              navigationDelegate: (NavigationRequest request) {
                _controller.currentUrl().then(onValue);
                return NavigationDecision.navigate;
              },
              initialUrl: redirectUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController wvc) {
                //
              },
              onPageFinished: (finish) {
                setState(() {
                  _isLoadingPage = false;
                });
              },
              //debuggingEnabled: true,
            ),
            _isLoadingPage
                ? Container(
                    alignment: FractionalOffset.center,
                    child: CircularProgressIndicator(),
                  )
                : Container(),
          ],
        ),
      ),*/
  }

  Future onValue(String url) {
    if (url.contains('/order-received/')) {
      orderSummary(url);
    }

    if (url.contains('cancel_order=') ||
        url.contains('failed') ||
        url.contains('type=error') ||
        url.contains('cancelled=1') ||
        url.contains('cancelled') ||
        url.contains('cancel_order=true')) {
      // Navigator.of(context).pop();
    }

    if (url.contains('?errors=true')) {
      // Navigator.of(context).pop();
    }

    // Start of PayUIndia Payment
    if (url.contains('payumoney.com/transact')) {
      // Show WebView
    }

    if (url.contains('/order-received/') &&
        url.contains('key=wc_order_') &&
        orderId != null) {
      navigateOrderSummary(url);
    }
    // End of PayUIndia Payment

    // Start of PAYTM Payment
    if (url.contains('securegw-stage.paytm.in/theia')) {
      //Show WebView
    }

    if (url.contains('type=success') && orderId != null) {
      navigateOrderSummary(url);
    }
  }

  void orderSummary(String url) {
    var str = url;
    var pos1 = str.lastIndexOf("/order-received/");
    var pos2 = str.lastIndexOf("/?key=wc_order");
    orderId = str.substring(pos1 + 16, pos2);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OrderSummary(
                  id: orderId,
                )));
  }

  void navigateOrderSummary(String url) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OrderSummary(
                  id: orderId,
                )));
  }
}
