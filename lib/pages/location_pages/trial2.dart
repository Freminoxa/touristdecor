// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';


// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? _controller;
//   Position? _currentPosition;
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//   final TextEditingController _searchController = TextEditingController();

//   static const String API_KEY = 'AIzaSyASpGhcj5U_78w2Fe7oU7p8hjCTUNmk5K4';

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   void _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return Future.error('Location permissions are permanently denied');
//     }

//     Position position = await Geolocator.getCurrentPosition();
//     setState(() {
//       _currentPosition = position;
//       _addMarker(LatLng(position.latitude, position.longitude), "Current Location");
//     });

//     _controller?.animateCamera(CameraUpdate.newCameraPosition(
//       CameraPosition(
//         target: LatLng(position.latitude, position.longitude),
//         zoom: 14.0,
//       ),
//     ));
//   }

//   void _addMarker(LatLng position, String id) {
//     setState(() {
//       _markers.add(
//         Marker(
//           markerId: MarkerId(id),
//           position: position,
//           infoWindow: InfoWindow(title: id, snippet: ""),
//         ),
//       );
//     });
//   }

//   void _searchPlace() async {
//     String searchTerm = _searchController.text;
//     String url = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$searchTerm&key=$API_KEY';

//     var response = await http.get(Uri.parse(url));
//     var json = jsonDecode(response.body);

//     if (json['results'].isNotEmpty) {
//       var location = json['results'][0]['geometry']['location'];
//       LatLng destination = LatLng(location['lat'], location['lng']);

//       _addMarker(destination, "Destination");
//       _getDirections(destination);
//     }
//   }

//   void _getDirections(LatLng destination) async {
//     PolylinePoints polylinePoints = PolylinePoints();
//     List<LatLng> polylineCoordinates = [];

//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       API_KEY,
//       PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
//       PointLatLng(destination.latitude, destination.longitude),
//     );

//     if (result.points.isNotEmpty) {
//       for (var point in result.points) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       }
//     }

//     setState(() {
//       _polylines.add(Polyline(
//         polylineId: const PolylineId("route"),
//         color: Colors.blue,
//         points: polylineCoordinates,
//         width: 5,
//       ));
//     });

//     _controller?.animateCamera(CameraUpdate.newLatLngBounds(
//       LatLngBounds(
//         southwest: LatLng(
//           _currentPosition!.latitude < destination.latitude ? _currentPosition!.latitude : destination.latitude,
//           _currentPosition!.longitude < destination.longitude ? _currentPosition!.longitude : destination.longitude,
//         ),
//         northeast: LatLng(
//           _currentPosition!.latitude > destination.latitude ? _currentPosition!.latitude : destination.latitude,
//           _currentPosition!.longitude > destination.longitude ? _currentPosition!.longitude : destination.longitude,
//         ),
//       ),
//       100.0,
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Google Maps Directions')),
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: (controller) => _controller = controller,
//             initialCameraPosition: const CameraPosition(
//               target: LatLng(0, 0),
//               zoom: 2,
//             ),
//             myLocationEnabled: true,
//             markers: _markers,
//             polylines: _polylines,
//           ),
//           Positioned(
//             top: 10,
//             left: 10,
//             right: 10,
//             child: Container(
//               color: Colors.white,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _searchController,
//                       decoration: const InputDecoration(
//                         hintText: 'Search for a place',
//                         contentPadding: EdgeInsets.all(10),
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.search),
//                     onPressed: _searchPlace,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }