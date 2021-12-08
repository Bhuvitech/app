class Config {
  /* Replace your sire url and api keys */

  //String url = 'http://bhuvitech.co.in/Bhuvitech';
  //String consumerKey = 'ck_0b8b1395d717f5a9c5276ee89e530198df693325';
  //String consumerSecret = 'cs_2f0edc6423a5b9be173e6b71f031cc707711e0e5';


  String url = 'https://emaligai.com/'; 
   String consumerKey = 'ck_ec630c95399e74e59f14c31d7e61987a47ef4fb0';
  String consumerSecret = 'cs_ba7128cc5b5e975bcbd52d125a4b4f14295ee5ee';



//efoodoo
//String consumerKey = 'ck_d5bd0ae921ef2f77f393f4a71900ce2a97518248';
 // String consumerSecret = 'cs_3026a33397de6d4844e8df4b4be318e04fa22ec9';

  //Android MAP API Key
  String mapApiKey = 'AIzaSyDMQKeNtSpC5iwuxx2bFmB0CFrCdc8WCVc';
  

  //iOS MAP API Key
  //String mapApiKey = 'AIzaSyDMQKeNtSpC5iwuxx2bFmB0CFrCdc8WCVc';

  static Config _singleton = new Config._internal();

  factory Config() {
    return _singleton;
  }

  Config._internal();

  Map<String, dynamic> appConfig = Map<String, dynamic>();

  Config loadFromMap(Map<String, dynamic> map) {
    appConfig.addAll(map);
    return _singleton;
  }

  dynamic get(String key) => appConfig[key];

  bool getBool(String key) => appConfig[key];

  int getInt(String key) => appConfig[key];

  double getDouble(String key) => appConfig[key];

  String getString(String key) => appConfig[key];

  void clear() => appConfig.clear();

  @Deprecated("use updateValue instead")
  void setValue(key, value) => value.runtimeType != appConfig[key].runtimeType
      ? throw ("wrong type")
      : appConfig.update(key, (dynamic) => value);

  void updateValue(String key, dynamic value) {
    if (appConfig[key] != null &&
        value.runtimeType != appConfig[key].runtimeType) {
      throw ("The persistent type of ${appConfig[key].runtimeType} does not match the given type ${value.runtimeType}");
    }
    appConfig.update(key, (dynamic) => value);
  }

  void addValue(String key, dynamic value) =>
      appConfig.putIfAbsent(key, () => value);

  add(Map<String, dynamic> map) => appConfig.addAll(map);
}
