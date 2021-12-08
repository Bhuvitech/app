import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:scoped_model/scoped_model.dart';

import './../../blocs/products_bloc.dart';
import './../../functions.dart';
import './../../models/app_state_model.dart';
import './../../models/category_model.dart';
import './../../models/product_model.dart';
import './../../ui/checkout/cart/cart4.dart';
import './../../ui/products/clipper_design.dart';
import './../../ui/products/product_filter/filter_product.dart';
import './../../ui/products/product_grid/product_item1.dart';

class ProductsWidget extends StatefulWidget {
  final ProductsBloc productsBloc = ProductsBloc();
  final Map<String, dynamic> filter;
  final String name;
  AppStateModel model = AppStateModel();

  ProductsWidget({Key key, this.filter, this.name}) : super(key: key);

  @override
  _ProductsWidgetState createState() => _ProductsWidgetState();
}

class _ProductsWidgetState extends State<ProductsWidget>
    with TickerProviderStateMixin {
  ScrollController _scrollController = new ScrollController();
  TabController _tabController;
  Category selectedCategory;
  List<Category> subCategories;
  @override
  void initState() {
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
    widget.model.selectedRange =
        RangeValues(0, widget.model.blocks.maxPrice.toDouble());
    widget.productsBloc.productsFilter = widget.filter;
    subCategories = widget.model.blocks.categories
        .where((cat) =>
            cat.parent.toString() == widget.productsBloc.productsFilter['id'])
        .toList();
    if (subCategories.length != 0) {
      subCategories.insert(
          0, Category(name: 'All', id: int.parse(widget.filter['id'])));
    }
    _tabController = TabController(vsync: this, length: subCategories.length);
    _tabController.index = 0;
    widget.productsBloc.fetchAllProducts(widget.productsBloc.productsFilter['id']);
    widget.productsBloc.fetchProductsAttributes();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        String id = subCategories.length > 0 ? subCategories[_tabController.index].id.toString() : widget.productsBloc.productsFilter['id'];
        widget.productsBloc.loadMore(id);
      }
    });
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if(widget.productsBloc.productsFilter['id'] != subCategories[_tabController.index].id.toString()) {
      //widget.productsBloc.productsFilter = new Map<String, dynamic>();
      widget.productsBloc.productsFilter['id'] =
          subCategories[_tabController.index].id.toString();
      widget.model.selectedRange =
          RangeValues(0, widget.model.blocks.maxPrice.toDouble());
      widget.productsBloc.fetchAllProducts(subCategories[_tabController.index].id.toString());
      if(_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
      setState(() {
        selectedCategory = subCategories[_tabController.index];
      });
    }
  }

  _onSelectSubcategory(int id) {
    widget.productsBloc.fetchAllProducts(id.toString());
    _scrollController.jumpTo(0.0);
    setState(() {
      selectedCategory = subCategories[_tabController.index];
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.productsBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        //brightness: Brightness.dark,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
        ),
        //centerTitle: true,
        title: widget.name != null
            ? Text(parseHtmlString(widget.name))
            : Text(parseHtmlString(widget.name)),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.tune,
              semanticLabel: 'filter',
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => FilterProduct(
                        productsBloc: widget.productsBloc,
                        categories: subCategories,
                        onSelectSubcategory: _onSelectSubcategory),
                  ));
            },
          ),
          Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  FlutterIcons.shopping_cart_fea,
                  semanticLabel: 'filter',
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => CartPage(),
                      ));
                },
              ),
              Positioned(
                // draw a red marble
                top: 2,
                right: 2.0,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => CartPage(),
                        ));
                  },
                  child: ScopedModelDescendant<AppStateModel>(
                      builder: (context, child, model) {
                    if (model.count != 0) {
                      return Card(
                          elevation: 0,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          color: Colors.redAccent,
                          child: Container(
                              padding: EdgeInsets.all(2),
                              constraints: BoxConstraints(minWidth: 20.0),
                              child: Center(
                                  child: Text(
                                model.count.toString(),
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    backgroundColor: Colors.redAccent),
                              ))));
                    } else
                      return Container();
                  }),
                ),
              )
            ],
          ),
        ],
      ),
      body: Stack(
        overflow: Overflow.visible,
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            height: double.infinity,
            width: double.infinity,
          ),
          Container(
              height: 180,
              width: double.infinity,
              child: CustomPaint(
                painter: CurvePainter(),
              )),
          Positioned(
            top: 0,
            child: Container(
                color: Theme.of(context).primaryColor,
                height: 45,
                width: MediaQuery.of(context).size.width,
                child: subCategories.length != 0 ? buildTabBar() : null),
          ),
          Positioned(
            top: 45,
            child: StreamBuilder(
                stream: widget.productsBloc.allProducts,
                builder: (context, AsyncSnapshot<List<Product>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length != 0) {
                      return CustomScrollView(
                        controller: _scrollController,
                        slivers: buildLisOfBlocks(snapshot),
                      );
                    } else {
                      return StreamBuilder<bool>(
                          stream: widget.productsBloc.isLoadingProducts,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data == true) {
                              return Center(child: CircularProgressIndicator());
                            } else
                              return Center(
                                child: Icon(
                                  FlutterIcons.smile_o_faw,
                                  size: 150,
                                  color: Theme.of(context).focusColor,
                                ),
                              );
                          });
                    }
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  return Center(child: CircularProgressIndicator());
                }),
          )
        ],
      ),
    );
  }

  List<Widget> buildLisOfBlocks(AsyncSnapshot<List<Product>> snapshot) {
    List<Widget> list = new List<Widget>();

    /// UnComment this if you use rounded corner category list in body.
    //list.add(buildSubcategories());
    if (snapshot.data != null) {
      list.add(ProductGrid(products: snapshot.data));

      list.add(SliverPadding(
          padding: EdgeInsets.all(0.0),
          sliver: SliverList(
              delegate: SliverChildListDelegate([
            Container(
                height: 60,
                child: StreamBuilder(
                    stream: widget.productsBloc.hasMoreItems,
                    builder: (context, AsyncSnapshot<bool> snapshot) {
                      return snapshot.hasData && snapshot.data == false
                          ? Center(child: Text('No more products!'))
                          : Center(child: CircularProgressIndicator());
                    }
                    //child: Center(child: CircularProgressIndicator())
                    ))
          ]))));
    }

    return list;
  }

  TabBar buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      //labelPadding: EdgeInsets.symmetric(horizontal: 10),
      unselectedLabelColor: Colors.white.withOpacity(.5),
      labelColor: Colors.white,
      labelStyle: TextStyle(
          fontSize: 16.0, fontWeight: FontWeight.w900, fontFamily: 'Lato'),
      unselectedLabelStyle: TextStyle(fontSize: 16.0, fontFamily: 'Lato'),
      indicator: MD2Indicator(
          //it begins here
          indicatorHeight: 5,
          indicatorColor: Colors.orangeAccent,
          indicatorSize:
              MD2IndicatorSize.normal //3 different modes tiny-normal-full
          ),
      tabs: subCategories
          .map<Widget>((Category category) =>
              Tab(text: category.name.replaceAll(new RegExp(r'&amp;'), '&')))
          .toList(),
    );
  }
}

enum MD2IndicatorSize {
  tiny,
  normal,
  full,
}

class MD2Indicator extends Decoration {
  final double indicatorHeight;
  final Color indicatorColor;
  final MD2IndicatorSize indicatorSize;

  const MD2Indicator(
      {@required this.indicatorHeight,
      @required this.indicatorColor,
      @required this.indicatorSize});

  @override
  _MD2Painter createBoxPainter([VoidCallback onChanged]) {
    return new _MD2Painter(this, onChanged);
  }
}

class _MD2Painter extends BoxPainter {
  final MD2Indicator decoration;

  _MD2Painter(this.decoration, VoidCallback onChanged)
      : assert(decoration != null),
        super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);

    Rect rect;
    if (decoration.indicatorSize == MD2IndicatorSize.full) {
      rect = Offset(offset.dx,
              (configuration.size.height - decoration.indicatorHeight ?? 3)) &
          Size(configuration.size.width, decoration.indicatorHeight ?? 3);
    } else if (decoration.indicatorSize == MD2IndicatorSize.normal) {
      rect = Offset(offset.dx + 25,
              (configuration.size.height - decoration.indicatorHeight ?? 3)) &
          Size(configuration.size.width - 50, decoration.indicatorHeight ?? 3);
    } else if (decoration.indicatorSize == MD2IndicatorSize.tiny) {
      rect = Offset(offset.dx + configuration.size.width / 2 - 8,
              (configuration.size.height - decoration.indicatorHeight ?? 3)) &
          Size(16, decoration.indicatorHeight ?? 3);
    }

    final Paint paint = Paint();
    paint.color = decoration.indicatorColor ?? Color(0xff1967d2);
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndCorners(rect,
            topRight: Radius.circular(8),
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8)),
        paint);
  }
}
