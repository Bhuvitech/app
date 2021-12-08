import 'dart:async';
import 'dart:convert';
import '../../models/vendor/store_state_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import '../../models/app_state_model.dart';
import 'package:place_picker/entities/entities.dart';
import 'package:place_picker/uuid.dart';
import 'package:place_picker/widgets/widgets.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../config.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/services.dart';
import 'place_picker2.dart';

/// Place picker widget made with map widget from
/// [google_maps_flutter](https://github.com/flutter/plugins/tree/master/packages/google_maps_flutter)
/// and other API calls to [Google Places API](https://developers.google.com/places/web-service/intro)
///
/// API key provided should have `Maps SDK for Android`, `Maps SDK for iOS`
/// and `Places API`  enabled for it
class PlacePicker extends StatefulWidget {
  /// API key generated from Google Cloud Console. You can get an API key
  /// [here](https://cloud.google.com/maps-platform/)
  //final String apiKey;

  /// Location to be displayed when screen is showed. If this is set or not null, the
  /// map does not pan to the user's current location.
  //final LatLng displayLocation;

  final VoidCallback onPressStartShopping;

  PlacePicker({Key key, this.onPressStartShopping}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PlacePickerState();
}

/// Place picker state
class PlacePickerState extends State<PlacePicker> {
  final Completer<GoogleMapController> mapController = Completer();

  /// Indicator for the selected location
  final Set<Marker> markers = Set();

  /// Result returned after user completes selection
  LocationResult locationResult;

  /// Overlay to display autocomplete suggestions
  OverlayEntry overlayEntry;

  List<NearbyPlace> nearbyPlaces = List();

  /// Session token required for autocomplete API call
  String sessionToken = Uuid().generateV4();

  GlobalKey appBarKey = GlobalKey();

  bool hasSearchTerm = false;

  String previousSearchTerm = '';

  Config config = Config();
  AppStateModel appStateModel = AppStateModel();

  // constructor
  PlacePickerState();

  void onMapCreated(GoogleMapController controller) {
    this.mapController.complete(controller);
    moveToCurrentUserLocation();
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    getUserLocation();
    if (appStateModel.customerLocation.containsKey('latitude') &&
        appStateModel.customerLocation['latitude'] != null &&
        appStateModel.customerLocation['longitude'] != null) {
      markers.add(Marker(
        position: LatLng(
            double.parse(appStateModel.customerLocation['latitude']),
            double.parse(appStateModel.customerLocation['longitude'])),
        markerId: MarkerId("selected-location"),
      ));
    }
    super.initState();
  }

  @override
  void dispose() {
    this.overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        key: this.appBarKey,
        title: SearchInput(searchPlace),
        centerTitle: true,
        leading: null,
        automaticallyImplyLeading: false,
      ),*/
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 8,
            child: ScopedModelDescendant<AppStateModel>(
                builder: (context, child, model) {
              return GoogleMap(
                initialCameraPosition: model.customerLocation
                            .containsKey('latitude') &&
                        model.customerLocation.containsKey('latitude') != null
                    ? CameraPosition(
                        target: LatLng(
                            double.parse(model.customerLocation['latitude']),
                            double.parse(model.customerLocation['longitude'])),
                        zoom: 4)
                    : CameraPosition(target: LatLng(30.5595, 22.9375), zoom: 4),
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                onMapCreated: onMapCreated,
                onTap: (latLng) {
                  clearOverlay();
                  moveToLocation(latLng);
                  _getUserAddress(latLng);
                },
                markers: markers,
              );
            }),
          ),
          Expanded(
            flex: 5,
            child: ScopedModelDescendant<AppStateModel>(
                builder: (context, child, model) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                        height: 45,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          enableFeedback: false,
                          splashColor: Colors.transparent,
                          onTap: () async {
                            Future<dynamic> result = await Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) =>
                                        PlacePicker2(config.mapApiKey)));

                            if (model.customerLocation.containsKey('latitude')) {
                              this.mapController.future.then((controller) {
                                controller.animateCamera(
                                  CameraUpdate.newCameraPosition(CameraPosition(
                                      target: LatLng(
                                          double.parse(
                                              model.customerLocation['latitude']),
                                          double.parse(
                                              model.customerLocation['longitude'])),
                                      zoom: 8.0)),
                                );
                              });
                              setState(() {
                                markers.clear();
                                markers.add(Marker(
                                    markerId: MarkerId("selected-location"),
                                    position: LatLng(
                                        double.parse(
                                            model.customerLocation['latitude']),
                                        double.parse(
                                            model.customerLocation['longitude']))));
                              });
                            }
                          },
                          child: TextField(
                            showCursor: false,
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: model.customerLocation['address'] != null
                                  ? model.customerLocation['address']
                                  : model.blocks.localeText.searchYourPlace,
                              hintStyle: Theme.of(context).textTheme.bodyText1,
                              //fillColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).inputDecorationTheme.fillColor : Colors.white,
                              filled: true,
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).focusColor,
                                  width: 0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).focusColor,
                                  width: 0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context).focusColor,
                                  width: 0,
                                ),
                              ),
                              contentPadding: EdgeInsets.all(6),
                              prefixIcon: Icon(
                                FontAwesomeIcons.search,
                                size: 18,
                                color: Theme.of(context).textTheme.bodyText1.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 0,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 0),
                      child: FlatButton(
                          onPressed: () => getUserLocation(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_searching, color: Colors.orange),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                model.blocks.localeText.useCurrentLocation,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(color: Colors.orange),
                              ),
                            ],
                          )),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8.0, 16, 8),
                      child: SizedBox(
                        width: double.maxFinite,
                        child: RaisedButton(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          onPressed: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text('Confirm Your Location'),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  /// Hides the autocomplete overlay
  void clearOverlay() {
    if (this.overlayEntry != null) {
      this.overlayEntry.remove();
      this.overlayEntry = null;
    }
  }

  /// Begins the search process by displaying a "wait" overlay then
  /// proceeds to fetch the autocomplete list. The bottom "dialog"
  /// is hidden so as to give more room and better experience for the
  /// autocomplete list overlay.
  void searchPlace(String place) {
    // on keyboard dismissal, the search was being triggered again
    // this is to cap that.
    if (place == this.previousSearchTerm) {
      return;
    }

    previousSearchTerm = place;

    if (context == null) {
      return;
    }

    clearOverlay();

    setState(() {
      hasSearchTerm = place.length > 0;
    });

    if (place.length < 1) {
      return;
    }

    final RenderBox renderBox = context.findRenderObject();
    final size = renderBox.size;

    final RenderBox appBarBox =
        this.appBarKey.currentContext.findRenderObject();

    this.overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: appBarBox.size.height,
        width: size.width,
        child: Material(
          elevation: 1,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              children: <Widget>[
                SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 3)),
                SizedBox(width: 24),
                Expanded(
                    child: Text("Finding place...",
                        style: TextStyle(fontSize: 16)))
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(this.overlayEntry);

    autoCompleteSearch(place);
  }

  /// Fetches the place autocomplete list with the query [place].
  void autoCompleteSearch(String place) async {
    try {
      place = place.replaceAll(" ", "+");

      var endpoint =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?" +
              "key=${config.mapApiKey}&" +
              "input={$place}&sessiontoken=${this.sessionToken}";
      if (this.locationResult != null) {
        endpoint += "&location=${this.locationResult.latLng.latitude}," +
            "${this.locationResult.latLng.longitude}";
      }

      final response = await http.get(endpoint);

      if (response.statusCode != 200) {
        throw Error();
      }

      final responseJson = jsonDecode(response.body);

      if (responseJson['predictions'] == null) {
        throw Error();
      }

      List<dynamic> predictions = responseJson['predictions'];

      List<RichSuggestion> suggestions = [];

      if (predictions.isEmpty) {
        AutoCompleteItem aci = AutoCompleteItem();
        aci.text = "No result found";
        aci.offset = 0;
        aci.length = 0;

        suggestions.add(RichSuggestion(aci, () {}));
      } else {
        for (dynamic t in predictions) {
          final aci = AutoCompleteItem()
            ..id = t['place_id']
            ..text = t['description']
            ..offset = t['matched_substrings'][0]['offset']
            ..length = t['matched_substrings'][0]['length'];

          suggestions.add(RichSuggestion(aci, () {
            FocusScope.of(context).requestFocus(FocusNode());
            decodeAndSelectPlace(aci.id);
          }));
        }
      }

      displayAutoCompleteSuggestions(suggestions);
    } catch (e) {
      print(e);
    }
  }

  /// To navigate to the selected place from the autocomplete list to the map,
  /// the lat,lng is required. This method fetches the lat,lng of the place and
  /// proceeds to moving the map to that location.
  void decodeAndSelectPlace(String placeId) async {
    clearOverlay();

    try {
      final response = await http.get(
          "https://maps.googleapis.com/maps/api/place/details/json?key=${config.mapApiKey}" +
              "&placeid=$placeId");

      if (response.statusCode != 200) {
        throw Error();
      }

      final responseJson = jsonDecode(response.body);

      if (responseJson['result'] == null) {
        throw Error();
      }

      final location = responseJson['result']['geometry']['location'];
      moveToLocation(LatLng(location['lat'], location['lng']));
    } catch (e) {
      print(e);
    }
  }

  /// Display autocomplete suggestions with the overlay.
  void displayAutoCompleteSuggestions(List<RichSuggestion> suggestions) {
    final RenderBox renderBox = context.findRenderObject();
    Size size = renderBox.size;

    final RenderBox appBarBox =
        this.appBarKey.currentContext.findRenderObject();

    clearOverlay();

    this.overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        top: appBarBox.size.height,
        child: Material(elevation: 1, child: Column(children: suggestions)),
      ),
    );

    Overlay.of(context).insert(this.overlayEntry);
  }

  /// Utility function to get clean readable name of a location. First checks
  /// for a human-readable name from the nearby list. This helps in the cases
  /// that the user selects from the nearby list (and expects to see that as a
  /// result, instead of road name). If no name is found from the nearby list,
  /// then the road name returned is used instead.
  String getLocationName() {
    if (this.locationResult == null) {
      return "Unnamed location";
    }

    for (NearbyPlace np in this.nearbyPlaces) {
      if (np.latLng == this.locationResult.latLng &&
          np.name != this.locationResult.locality) {
        this.locationResult.name = np.name;
        return "${np.name}, ${this.locationResult.locality}";
      }
    }

    return "${this.locationResult.name}, ${this.locationResult.locality}";
  }

  /// Moves the marker to the indicated lat,lng
  void setMarker(LatLng latLng) {
    // markers.clear();
    setState(() {
      markers.clear();
      markers.add(
          Marker(markerId: MarkerId("selected-location"), position: latLng));
    });
  }

  /// Fetches and updates the nearby places to the provided lat,lng
  void getNearbyPlaces(LatLng latLng) async {
    try {
      final response = await http.get(
          "https://maps.googleapis.com/maps/api/place/nearbysearch/json?" +
              "key=${config.mapApiKey}&" +
              "location=${latLng.latitude},${latLng.longitude}&radius=150");

      if (response.statusCode != 200) {
        throw Error();
      }

      final responseJson = jsonDecode(response.body);

      if (responseJson['results'] == null) {
        throw Error();
      }

      this.nearbyPlaces.clear();

      for (Map<String, dynamic> item in responseJson['results']) {
        final nearbyPlace = NearbyPlace()
          ..name = item['name']
          ..icon = item['icon']
          ..latLng = LatLng(item['geometry']['location']['lat'],
              item['geometry']['location']['lng']);

        this.nearbyPlaces.add(nearbyPlace);
      }

      // to update the nearby places
      setState(() {
        // this is to require the result to show
        this.hasSearchTerm = false;
      });
    } catch (e) {
      //
    }
  }

  /// This method gets the human readable name of the location. Mostly appears
  /// to be the road name and the locality.
  void reverseGeocodeLatLng(LatLng latLng) async {
    try {
      final response = await http.get(
          "https://maps.googleapis.com/maps/api/geocode/json?" +
              "latlng=${latLng.latitude},${latLng.longitude}&" +
              "key=${config.mapApiKey}");

      if (response.statusCode != 200) {
        throw Error();
      }

      final responseJson = jsonDecode(response.body);

      if (responseJson['results'] == null) {
        throw Error();
      }

      final result = responseJson['results'][0];

      setState(() {
        this.locationResult = LocationResult()
          ..name = result['address_components'][0]['short_name']
          ..locality = result['address_components'][1]['short_name']
          ..latLng = latLng
          ..formattedAddress = result['formatted_address']
          ..placeId = result['place_id']
          ..postalCode = result['address_components'][5]['short_name']
          ..country = AddressComponent.fromJson(result['address_components'][4])
          ..administrativeAreaLevel1 =
              AddressComponent.fromJson(result['address_components'][5])
          ..administrativeAreaLevel2 =
              AddressComponent.fromJson(result['address_components'][4])
          ..city = AddressComponent.fromJson(result['address_components'][3])
          ..subLocalityLevel1 =
              AddressComponent.fromJson(result['address_components'][2])
          ..subLocalityLevel2 =
              AddressComponent.fromJson(result['address_components'][1]);
      });
    } catch (e) {
      print(e);
    }
  }

  /// Moves the camera to the provided location and updates other UI features to
  /// match the location.
  void moveToLocation(LatLng latLng) {
    this.mapController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 15.0)),
      );
    });

    setMarker(latLng);

    reverseGeocodeLatLng(latLng);

    getNearbyPlaces(latLng);
  }

  void moveToCurrentUserLocation() {
    /*if (widget.displayLocation != null) {
      moveToLocation(widget.displayLocation);
      return;
    }*/

    Location().getLocation().then((locationData) {
      LatLng target = LatLng(locationData.latitude, locationData.longitude);
      moveToLocation(target);
    }).catchError((error) {
      // TODO: Handle the exception here
      print(error);
    });
  }

  getUserLocation() async {
    //call this async method from whereever you need

    LocationData myLocation;
    String error;
    Location location = new Location();
    try {
      myLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'please grant permission';
        print(error);
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'permission denied- please enable it from app settings';
        print(error);
      }
      myLocation = null;
    }

    final coordinates =
        new Coordinates(myLocation.latitude, myLocation.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    final result = addresses.first;

    if (result != null) {
      this.mapController.future.then((controller) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(
              target: LatLng(myLocation.latitude, myLocation.longitude),
              zoom: 8.0)),
        );
      });
      setState(() {
        markers.clear();
        markers.add(Marker(
            markerId: MarkerId("selected-location"),
            position: LatLng(myLocation.latitude, myLocation.longitude)));
      });

      var location = new Map<String, dynamic>();

      location['address'] = result.addressLine;
      location['postalCode'] = result.postalCode;
      location['city'] = result.locality;
      location['latitude'] = myLocation.latitude.toString();
      location['longitude'] = myLocation.longitude.toString();
      appStateModel.setPickedLocation(location);
    }
    //print(' ${first.locality}, ${first.adminArea},${first.subLocality}, ${first.subAdminArea},${first.addressLine}, ${first.featureName},${first.thoroughfare}, ${first.subThoroughfare}');
    //return first;
  }

  _getUserAddress(LatLng latLng) async {
    final coordinates = new Coordinates(latLng.latitude, latLng.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    final result = addresses.first;

    if (result != null) {
      this.mapController.future.then((controller) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(
              target: LatLng(latLng.latitude, latLng.longitude), zoom: 8.0)),
        );
      });
      setState(() {
        markers.clear();
        markers.add(Marker(
            markerId: MarkerId("selected-location"),
            position: LatLng(latLng.latitude, latLng.longitude)));
      });

      var location = new Map<String, dynamic>();

      location['address'] = result.addressLine;
      location['postalCode'] = result.postalCode;
      location['city'] = result.locality;
      location['latitude'] = latLng.latitude.toString();
      location['longitude'] = latLng.longitude.toString();
      appStateModel.setPickedLocation(location);
      StoreStateModel().getAllStores();
    }
  }
}
