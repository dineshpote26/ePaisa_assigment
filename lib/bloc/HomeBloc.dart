import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mpaisa_app/pref/PrefsSingleton.dart';
import 'package:mpaisa_app/util/AppConstant.dart';

import 'BlocBase.dart';

class HomeBloc extends BlocBase {
  //default source location
  LatLng sourceLocation = LatLng(19.0760, 72.8777);

  //default destination location
  LatLng destinationLocation = LatLng(19.0178, 72.8478);

  StreamController<bool> _streamController = StreamController<bool>.broadcast();
  Stream<bool> get isCalled => _streamController.stream;

  StreamController<String> _fcmStreamController =
      StreamController<String>.broadcast();
  Stream<String> get token => _fcmStreamController.stream;

  StreamController<String> _adderssStreamController =
      StreamController<String>.broadcast();
  Stream<String> get address => _adderssStreamController.stream;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();


  StreamController<bool> _logoutStreamController = StreamController<bool>.broadcast();
  Stream<bool> get logoutAll => _logoutStreamController.stream;

  //create points for polyline
  List<LatLng> getPoints(LatLng _center) {
    List<LatLng> latlng = List();

    latlng.add(_center != null ? _center : sourceLocation);

    latlng.add(destinationLocation);

    print("getPoints called");

    return latlng;
  }

  //set polyline here
  Set<Polyline> getPolyLine(LatLng _center) {
    Set<Polyline> _polyline = {};
    _polyline.add(Polyline(
      polylineId: PolylineId("polyOne"),
      visible: true,
      width: 2,
      points: getPoints(_center),
      color: Colors.red,
    ));

    print("getPolyLine called");

    return _polyline;
  }

  //set markers base on position
  Set<Marker> getMarkers(LatLng _center) {
    Set<Marker> _markers = {};
    //source marker
    _markers.add(Marker(
      markerId: MarkerId("SourceMarker"),
      position: _center,
      infoWindow: InfoWindow(
        title: 'Source',
      ),
      icon: BitmapDescriptor.defaultMarker,
    ));

    //destination marker
    _markers.add(Marker(
      markerId: MarkerId("DestinationMarker"),
      position: destinationLocation,
      infoWindow: InfoWindow(title: 'Destination'),
      icon: BitmapDescriptor.defaultMarker,
    ));

    print("getMarkers called");

    getAddressFromCoordinate(_center.latitude, _center.longitude);

    return _markers;
  }

  //here we refresh ui on map created and location updated
  void refreshMap() {
    _streamController.sink.add(true);
    print("refreshMap called");
  }

  Future<LatLng> getCurrentLocation() async {
    LatLng _center = LatLng(19.0760, 72.8777);

    Position _position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    _center = LatLng(
      _position.latitude,
      _position.longitude,
    );

    return _center;
  }

  //generate firebase token
  void generateFirebaseToken() async {
    String token = await _firebaseMessaging.getToken();
    debugPrint("token:" + token);
    _fcmStreamController.add(token);
  }

  void logout() async{
    if(PrefsSingleton.prefs.getInt(AppConstant.LOGINTYPE) == 1){
      await PrefsSingleton.prefs.clear();
      await FacebookLogin().logOut();
      _logoutStreamController.add(true);
    }else if(PrefsSingleton.prefs.getInt(AppConstant.LOGINTYPE) == 2){
      await PrefsSingleton.prefs.clear();
      _logoutStreamController.add(true);
    }
  }

  //find address from coordinate
  void getAddressFromCoordinate(var latitude, var logitude) async {
    var address = await Geocoder.local
        .findAddressesFromCoordinates(new Coordinates(latitude, logitude));

    // var addressLine = address.first..addressLine.toString();
    debugPrint("address:" + address.first.addressLine.toString());
    _adderssStreamController.add(address.first.addressLine.toString());
  }

  @override
  void dispose() {
    _streamController.close();
    _fcmStreamController.close();
    _adderssStreamController.close();
    _logoutStreamController.close();
  }
}
