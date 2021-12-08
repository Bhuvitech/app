import '../../models/vendor/store_model.dart';
import '../../resources/api_provider.dart';
import 'package:rxdart/rxdart.dart';

class StoresBloc {
  List<StoreModel> data;
  var filter = new Map<String, dynamic>();
  int _page = 1;
  bool hasMoreItems = false;

  final apiProvider = ApiProvider();
  final _dataFetcher = BehaviorSubject<List<StoreModel>>();

  ValueStream<List<StoreModel>> get allData => _dataFetcher.stream;

  fetchData([String query]) async {
    filter['page'] = '1';
    final response = await apiProvider.post(
        '/wp-admin/admin-ajax.php?action=mstore_flutter-vendors', filter);
    if(response.statusCode == 200) {
      hasMoreItems = true;
      data = storeModelFromJson(response.body);
    } else {
      _dataFetcher.sink.addError('Server error');
    }
    _dataFetcher.sink.add(data);
    if (data.length < 10) {
      hasMoreItems = false;
    }
  }

  loadMore() async {
    _page = _page + 1;
    filter['page'] = _page.toString();
    final response = await apiProvider.post(
        '/wp-admin/admin-ajax.php?action=mstore_flutter-vendors', filter);
    if(response.statusCode == 200) {
      List<StoreModel> moreData = storeModelFromJson(response.body);
      data.addAll(moreData);
      _dataFetcher.sink.add(data);
      _dataFetcher.sink.add(data);
      if (data.length < 10) {
        hasMoreItems = false;
      }
    } else {
      _dataFetcher.sink.addError('Server error');
    }
  }

  dispose() {
    _dataFetcher.close();
  }
}
