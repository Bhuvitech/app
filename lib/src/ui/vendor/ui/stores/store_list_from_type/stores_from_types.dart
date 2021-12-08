import '../../../../../blocs/vendor/stores_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../search_store.dart';
import '../../../../../models/vendor/store_model.dart';
import 'package:flutter/material.dart';
import 'store_list.dart';

class StoresTypes extends StatefulWidget {
  final Map<String, dynamic> filter;
  final StoresBloc storesBloc = StoresBloc();

  StoresTypes({Key key, this.filter}) : super(key: key);
  @override
  _StoresTypesState createState() => _StoresTypesState();
}

class _StoresTypesState extends State<StoresTypes> {
  ScrollController _scrollController = new ScrollController();
  @override
  void initState() {
    super.initState();
    if(widget.filter != null) {
      widget.storesBloc.filter = widget.filter;
    }
    widget.storesBloc.fetchData();
    _scrollController.addListener(_loadMoreItems);
  }

  _loadMoreItems() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        widget.storesBloc.hasMoreItems) {
      widget.storesBloc.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMoreItems);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: buildStoreTitle(context),),
      body: RefreshIndicator(
        onRefresh: () async {
          await widget.storesBloc.fetchData();
          return;
        },
        child: StreamBuilder(
            stream: widget.storesBloc.allData,
            builder: (context, AsyncSnapshot<List<StoreModel>> snapshot) {
              if (snapshot.hasData) {
                return CustomScrollView(
                      controller: _scrollController,
                      slivers: buildListOfBlocks(snapshot.data),
                    );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            })),
      );
  }

  List<Widget> buildListOfBlocks(List<StoreModel> stores) {
    List<Widget> list = new List<Widget>();
    if(stores.length > 0)
    list.add(StoresList(stores: stores));
    return list;
  }

  Row buildStoreTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
            height: 55,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(0, 8, 24, 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              enableFeedback: false,
              splashColor: Colors.transparent,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SearchStores();
                }));
              },
              child: TextField(
                showCursor: false,
                enabled: false,
                decoration: InputDecoration(
                  hintText: 'Search Store',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Circular',
                  ),
                  //fillColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).inputDecorationTheme.fillColor : Colors.white,
                  filled: true,
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      color: Theme.of(context).focusColor,
                      width: 0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      color: Theme.of(context).focusColor,
                      width: 0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      color: Theme.of(context).focusColor,
                      width: 0,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(6),
                  prefixIcon: Icon(
                    FontAwesomeIcons.search,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
