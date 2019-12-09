import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mpaisa_app/bloc/BlocBase.dart';
import 'package:mpaisa_app/bloc/HomeBloc.dart';
import 'package:mpaisa_app/bloc/LoginBloc.dart';
import 'package:mpaisa_app/ui/LoginPage.dart';
import 'package:permission/permission.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  LatLng _center = const LatLng(19.0760, 72.8777);
  HomeBloc homeBloc;
  StreamSubscription<bool> _logoutSubscription;

  void initialSetup() async {


    homeBloc = BlocProvider.of<HomeBloc>(context);

    _logoutSubscription = homeBloc.logoutAll.listen((status){

      if(status){
        navigatetoLogin();
      }
    });

    var permissions =
        await Permission.getPermissionsStatus([PermissionName.Location]);
    if (permissions[0].permissionStatus == PermissionStatus.notAgain) {
      await Permission.requestPermissions([PermissionName.Location]);
    }else{
      await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .then((Position _position) {
        if (_position != null) {
          _center = LatLng(_position.latitude, _position.longitude,);
          homeBloc.refreshMap();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initialSetup();
  }



  @override
  Widget build(BuildContext context) {

    var _fabMiniMenuItemList = [
      FabMiniMenuItem.withText(
          new Icon(Icons.mobile_screen_share),
          Colors.blue,
          4.0,
          "Generate Token",
          homeBloc.generateFirebaseToken,
          "Generate Token",
          Colors.blue,
          Colors.white,
          false
      ),



      FabMiniMenuItem.withText(
          new Icon(Icons.exit_to_app),
          Colors.blue,
          4.0,
          "Logout",
          homeBloc.logout,
          "Logout",
          Colors.blue,
          Colors.white,
          false
      ),
    ];

    return Scaffold(
        body: StreamBuilder<bool>(
            stream: homeBloc.isCalled,
            initialData: false,
            builder: (context, snapshot) {
              return Stack(
                children: <Widget>[

                  GoogleMap(
                    polylines: homeBloc.getPolyLine(_center),
                    markers: homeBloc.getMarkers(_center),
                    onMapCreated: onMapCreated,
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 10.0,
                    ),
                    mapType: MapType.normal,
                  ),
                  Positioned(child: Align(
                    alignment: Alignment.bottomRight,
                    child: new FabDialer(_fabMiniMenuItemList, Colors.blue, new Icon(Icons.add)),
                  )),
                  Positioned(
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 250,
                          color: Colors.black38,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Address : ",style: TextStyle(color: Colors.white),),
                                    StreamBuilder<String>(
                                      stream: homeBloc.address,
                                      builder: (context, snapshot) {
                                        if(snapshot.hasData){
                                          return Expanded(child: Text(snapshot.data,style: TextStyle(fontSize: 15,color: Colors.white),));
                                        }else{
                                          return Expanded(child: Text(" "),flex: 1,);
                                        }
                                      }
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Token :    ",style: TextStyle(color: Colors.white),),
                                    StreamBuilder<String>(
                                      stream: homeBloc.token,
                                      builder: (context, snapshot) {
                                        if(snapshot.hasData){
                                          return Expanded(child: Text(snapshot.data,style: TextStyle(fontSize: 15,color: Colors.white)),);
                                        }else{
                                          return Expanded(child: Text(" "),flex: 1,);
                                        }
                                      }
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                    ),
                  ),
                ],
              );
            }),
    );
  }



  void onMapCreated(GoogleMapController controller) {
    print("onMapCreated");
    homeBloc.refreshMap();
  }

  void navigatetoLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) =>
            BlocProvider(child: LoginPage(), bloc: LoginBloc())));
  }
}