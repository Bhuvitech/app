import '../../ui/vendor/ui/stores/store_list_from_type/stores_from_types.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../ui/blocks/ExpandableCategoriesList.dart';
import '../../ui/categories/categories9.dart';
import '../../ui/products/product_grid/products_scroll.dart';
import '../vendor/ui/stores_nearby/store_list.dart';
import '../blocks/stores/store_grid_list.dart';
import '../blocks/stores/store_scroll_list.dart';
import '../vendor/ui/stores_nearby/stores.dart';
import 'place_picker.dart';
import 'search.dart';
import '../blocks/count_down.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../data/gallery_options.dart';
import '../../models/app_state_model.dart';
import '../products/product_grid/product_item4.dart';
import '../../models/product_model.dart';
import '../blocks/banner_slider.dart';
import '../blocks/banner_slider2.dart';
import '../blocks/banner_slider3.dart';
import '../blocks/banner_grid_list.dart';
import '../blocks/banner_scroll_list.dart';
import '../blocks/banner_slider1.dart';
import '../blocks/category_grid_list.dart';
import '../blocks/category_scroll_list.dart';
import '../blocks/product_grid_list.dart';
import '../blocks/product_scroll_list.dart';
import '../../models/category_model.dart';
import '../products/product_detail/product_detail.dart';
import '../products/products.dart';
import '../../models/blocks_model.dart' hide Image, Key, Theme;
import 'package:flutter/rendering.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ScrollController _scrollController = new ScrollController();
  AppStateModel appStateModel = AppStateModel();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        appStateModel.loadMoreRecentProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppStateModel>(
        builder: (context, child, model) {
      return RefreshIndicator(
        onRefresh: () async {
          await model.fetchAllBlocks();
          return;
        },
        child: ScopedModelDescendant<AppStateModel>(
          builder: (context, child, model) {
            return model.blocks != null
                ? Container(
                    //color: Theme.of(context).brightness == Brightness.light ? Color(0xFFf2f3f7) : Colors.black,
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: buildLisOfBlocks(model.blocks),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ),
      );
    });
  }

  List<Widget> buildLisOfBlocks(BlocksModel snapshot) {
    List<Widget> list = new List<Widget>();

    list.add(SliverAppBar(
        expandedHeight: 10.0,
        //pinned: true,
        floating: true,
        //snap: true,
        titleSpacing: 5,
        //centerTitle: false,
        flexibleSpace: FlexibleSpaceBar(
          //centerTitle: false,
          titlePadding: EdgeInsetsDirectional.only(start: 0, bottom: 16),
          title: Container(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return PlacePicker();
                }));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    FlutterIcons.location_pin_sli,
                    color: Theme.of(context).primaryIconTheme.color,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 180,
                    child: ScopedModelDescendant<AppStateModel>(
                        builder: (context, child, model) {
                      if (model.customerLocation['address'] != null)
                        return Text(
                          model.customerLocation['address'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      else
                        return Text('Select your location');
                    }),
                  ),
                  Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    enableFeedback: false,
                    splashColor: Colors.transparent,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Search();
                      }));
                    },
                    child: Icon(
                      FlutterIcons.search_fea,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                  )
                ],
              ),
            ),
          ),
        )));

    for (var i = 0; i < snapshot.blocks.length; i++) {
      if (snapshot.blocks[i].blockType == 'banner_block') {
        if (snapshot.blocks[i].style == 'grid') {
          list.add(buildGridHeader(snapshot, i));
          list.add(BannerGridList(
              block: snapshot.blocks[i], onBannerClick: onBannerClick));
        }

        if (snapshot.blocks[i].style == 'scroll') {
          list.add(BannerScrollList(
              block: snapshot.blocks[i], onBannerClick: onBannerClick));
        }

        if (snapshot.blocks[i].style == 'slider') {
          list.add(BannerSlider(
              block: snapshot.blocks[i], onBannerClick: onBannerClick));
        }

        if (snapshot.blocks[i].style == 'slider1') {
          list.add(BannerSlider1(
              block: snapshot.blocks[i], onBannerClick: onBannerClick));
        }

        if (snapshot.blocks[i].style == 'slider2') {
          list.add(BannerSlider2(
              block: snapshot.blocks[i], onBannerClick: onBannerClick));
        }

        if (snapshot.blocks[i].style == 'slider3') {
          list.add(BannerSlider3(
              block: snapshot.blocks[i], onBannerClick: onBannerClick));
        }
      }

      //For MultiVendor Stores
      if (snapshot.blocks[i].blockType == 'vendor_block' &&
          snapshot.blocks[i].style == 'scroll' &&
          snapshot.blocks[i].stores.length != 0) {
        if (snapshot.blocks[i].borderRadius == 50) {
          //list.add(StoreScrollStadiumList(block: snapshot.blocks[i]));
        } else {
          list.add(StoreScrollList(block: snapshot.blocks[i]));
        }
      }

      /*if (snapshot.blocks[i].blockType == 'vendor_block' &&
          snapshot.blocks[i].style == 'grid' && snapshot.blocks[i].stores.length != 0) {
        list.add(buildGridHeader(snapshot, i));
        if (snapshot.blocks[i].borderRadius == 50) {
          list.add(StoreStadiumGridList(block: snapshot.blocks[i]));
        } else {
          list.add(StoreGridList(block: snapshot.blocks[i]));
        }
      }*/
      //End of MultiVendor Stores

      if (snapshot.blocks[i].blockType == 'category_block' &&
          snapshot.blocks[i].style == 'scroll') {
        if (snapshot.blocks[i].borderRadius == 50) {
          list.add(CategoryScrollStadiumList(
              block: snapshot.blocks[i],
              categories: snapshot.categories,
              onCategoryClick: onCategoryClick));
        } else {
          list.add(CategoryScrollList(
              block: snapshot.blocks[i],
              categories: snapshot.categories,
              onCategoryClick: onCategoryClick));
        }
      }

      if (snapshot.blocks[i].blockType == 'category_block' &&
          snapshot.blocks[i].style == 'grid') {
        list.add(buildGridHeader(snapshot, i));
        if (snapshot.blocks[i].borderRadius == 50) {
          list.add(CategoryStadiumGridList(
              block: snapshot.blocks[i],
              categories: snapshot.categories,
              onCategoryClick: onCategoryClick));
        } else {
          list.add(CategoryGridList(
              block: snapshot.blocks[i],
              categories: snapshot.categories,
              onCategoryClick: onCategoryClick));
        }
      }

      if (snapshot.blocks[i].blockType == 'category_block' &&
          snapshot.blocks[i].style == 'expandable') {
        list.add(ExpandableCategoryList(block: snapshot.blocks[i], categories: snapshot.categories));
      }

      if ((snapshot.blocks[i].blockType == 'product_block' ||
              snapshot.blocks[i].blockType == 'flash_sale_block') &&
          snapshot.blocks[i].style == 'scroll') {
        list.add(ProductScrollList(
            block: snapshot.blocks[i], onProductClick: onProductClick));
      }

      if ((snapshot.blocks[i].blockType == 'product_block' ||
              snapshot.blocks[i].blockType == 'flash_sale_block') &&
          snapshot.blocks[i].style == 'grid') {
        list.add(buildGridHeader(snapshot, i));
        list.add(ProductGridList(
            block: snapshot.blocks[i], onProductClick: onProductClick));
      }
    }

    if (snapshot.settings.showOnsale == 1 && snapshot.onSale.length > 0) {
      var filter = new Map<String, dynamic>();
      filter['on_sale'] = '1';
      list.add(ProductScroll(
          products: snapshot.onSale,
          context: context,
          title: snapshot.localeText.sale,
          viewAllTitle: snapshot.localeText.viewAll,
          filter: filter));
    }

    if (snapshot.settings.showFeatured == 1 && snapshot.featured.length > 0) {
      var filter = new Map<String, dynamic>();
      filter['featured'] = true;
      list.add(ProductScroll(
          products: snapshot.featured,
          context: context,
          title: snapshot.localeText.featured,
          viewAllTitle: snapshot.localeText.viewAll,
          filter: filter));
    }

    if (snapshot.settings.showBestSelling == 1 &&
        snapshot.bestSelling.length > 0) {
      var filter = new Map<String, dynamic>();
      filter['popularity'] = true;
      list.add(ProductScroll(
          products: snapshot.bestSelling,
          context: context,
          title: snapshot.localeText.bestSelling,
          viewAllTitle: snapshot.localeText.viewAll,
          filter: filter));
    }

    if (snapshot.stores.length > 0 && snapshot.settings.showStoreList == 1) {
      list.add(StoresList(stores: snapshot.stores));
    }

    if (snapshot.recentProducts != null && snapshot.settings.showLatest == 1) {
      list.add(buildRecentProductGridList(snapshot));
      list.add(SliverPadding(
          padding: EdgeInsets.all(0.0),
          sliver: SliverList(
              delegate: SliverChildListDelegate([
            Container(
                height: 60,
                child: ScopedModelDescendant<AppStateModel>(
                    builder: (context, child, model) {
                  if (model.blocks?.recentProducts != null &&
                      model.hasMoreRecentItem == false) {
                    return Center(
                      child: Text(
                        model.blocks.localeText.noMoreProducts,
                      ),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }))
          ]))));
    }

    return list;
  }

  double _headerAlign(String align) {
    switch (align) {
      case 'top_left':
        return -1;
      case 'top_right':
        return 1;
      case 'top_center':
        return 0;
      case 'floating':
        return 2;
      case 'none':
        return null;
      default:
        return -1;
    }
  }

  Widget buildRecentProductGridList(BlocksModel snapshot) {
    return ProductGrid(products: snapshot.recentProducts);
  }

  Widget buildListHeader(AsyncSnapshot<BlocksModel> snapshot, int childIndex) {
    Color bgColor = HexColor(snapshot.data.blocks[childIndex].bgColor);
    double textAlign =
        _headerAlign(snapshot.data.blocks[childIndex].headerAlign);
    return textAlign != null
        ? SliverToBoxAdapter(child: ScopedModelDescendant<AppStateModel>(
            builder: (context, child, model) {
            return Container(
                padding: EdgeInsets.fromLTRB(
                    snapshot.data.blocks[childIndex].paddingBetween,
                    double.parse(
                        snapshot.data.blocks[childIndex].paddingTop.toString()),
                    snapshot.data.blocks[childIndex].paddingBetween,
                    16.0),
                color: GalleryOptions.of(context).themeMode == ThemeMode.light
                    ? bgColor
                    : Theme.of(context).canvasColor,
                alignment: Alignment(textAlign, 0),
                child: Text(
                  snapshot.data.blocks[childIndex].title,
                  textAlign: TextAlign.start,
                  style: GalleryOptions.of(context).themeMode == ThemeMode.light
                      ? Theme.of(context).textTheme.headline6.copyWith(
                            color: HexColor(
                                snapshot.data.blocks[childIndex].titleColor),
                          )
                      : Theme.of(context).textTheme.headline6,
                ));
          }))
        : SliverToBoxAdapter(
            child: ScopedModelDescendant<AppStateModel>(
                builder: (context, child, model) {
              return Container(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.fromLTRB(
                    snapshot.data.blocks[childIndex].paddingBetween,
                    double.parse(
                        snapshot.data.blocks[childIndex].paddingTop.toString()),
                    snapshot.data.blocks[childIndex].paddingBetween,
                    0.0),
                color: GalleryOptions.of(context).themeMode == ThemeMode.light
                    ? bgColor
                    : Theme.of(context).canvasColor,
              );
            }),
          );
  }

  Widget buildGridHeader(BlocksModel snapshot, int childIndex) {
    double textAlign = _headerAlign(snapshot.blocks[childIndex].headerAlign);
    TextStyle subhead = Theme.of(context).brightness != Brightness.dark
        ? Theme.of(context)
            .textTheme
            .headline6
            .copyWith(color: HexColor(snapshot.blocks[childIndex].titleColor))
        : Theme.of(context).textTheme.headline6;

    TextStyle _textStyleCounter = Theme.of(context)
        .textTheme
        .bodyText2
        .copyWith(color: Colors.white, fontSize: 12);

    if (snapshot.blocks[childIndex].blockType == 'flash_sale_block') {
      var dateTo = DateFormat('M/d/yyyy mm:ss')
          .parse(snapshot.blocks[childIndex].saleEnds);
      var dateFrom = DateTime.now();
      final difference = dateTo.difference(dateFrom).inSeconds;

      return !difference.isNegative
          ? SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                      snapshot.blocks[childIndex].paddingBetween + 4,
                      double.parse(
                          snapshot.blocks[childIndex].paddingTop.toString()),
                      snapshot.blocks[childIndex].paddingBetween + 4,
                      0.0),
                  alignment: Alignment(textAlign, 0),
                  height: 60,
                  child: Countdown(
                    duration: Duration(seconds: difference),
                    builder: (BuildContext ctx, Duration remaining) {
                      return Row(
                        mainAxisAlignment:
                            snapshot.blocks[childIndex].headerAlign ==
                                    'top_center'
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              child: Text(
                            snapshot.blocks[childIndex].title,
                            textAlign: TextAlign.start,
                            style: subhead,
                          )),
                          Row(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              //crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: new BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: new BorderRadius.all(
                                          Radius.circular(2.0))),
                                  margin: EdgeInsets.all(4),
                                  child: Center(
                                      child: Text(
                                          '${remaining.inHours.clamp(0, 99)}',
                                          maxLines: 1,
                                          style: _textStyleCounter)),
                                ),
                                Container(
                                  width: 24,
                                  height: 24,
                                  margin: EdgeInsets.all(4),
                                  decoration: new BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: new BorderRadius.all(
                                          Radius.circular(2.0))),
                                  child: Center(
                                      child: Text(
                                          '${remaining.inMinutes.remainder(60)}',
                                          style: _textStyleCounter)),
                                ),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: new BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: new BorderRadius.all(
                                          Radius.circular(2.0))),
                                  margin: EdgeInsets.all(4),
                                  child: Center(
                                      child: Text(
                                          '${remaining.inSeconds.remainder(60)}',
                                          style: _textStyleCounter)),
                                ),
                              ]),
                        ],
                      );
                    },
                  ),
                ),
              ),
            )
          : Container();
    }

    return textAlign != null
        ? SliverToBoxAdapter(
            child: Container(
                padding: EdgeInsets.fromLTRB(
                    double.parse(snapshot.blocks[childIndex].paddingLeft
                            .toString()) +
                        4,
                    double.parse(
                        snapshot.blocks[childIndex].paddingTop.toString()),
                    double.parse(snapshot.blocks[childIndex].paddingRight
                            .toString()) +
                        4,
                    16.0),
                alignment: Alignment(textAlign, 0),
                child: Text(
                  snapshot.blocks[childIndex].title,
                  textAlign: TextAlign.start,
                  style: subhead,
                )))
        : SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  snapshot.blocks[childIndex].paddingBetween,
                  double.parse(
                      snapshot.blocks[childIndex].paddingTop.toString()),
                  snapshot.blocks[childIndex].paddingBetween,
                  0.0),
            ),
          );
  }

  onProductClick(product) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProductDetail(product: product);
    }));
  }

  onBannerClick(Child data) {
    //Naviaget yo product or product list depend on type
    if (data.url.isNotEmpty) {
      if (data.description == 'category') {
        var filter = new Map<String, dynamic>();
        filter['id'] = data.url;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProductsWidget(filter: filter, name: data.title)));
      } else if (data.description == 'product') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetail(
                      product: Product(
                        id: int.parse(data.url),
                        name: data.title,
                      ),
                    )));
      } else if (data.description == 'stores') {
        var filter = new Map<String, String>();
        filter['mstoreapp_vendor_type'] = data.url;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    StoresTypes(filter: filter)));
      }
    }
  }

  onCategoryClick(Category category, List<Category> categories) {
    var filter = new Map<String, dynamic>();
    filter['id'] = category.id.toString();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProductsWidget(filter: filter, name: category.name)));
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
