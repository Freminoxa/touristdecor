// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// class LocationMapScreen extends StatefulWidget {
//   const LocationMapScreen({super.key});

//   @override
//   _LocationMapScreenState createState() => _LocationMapScreenState();
// }

// class _LocationMapScreenState extends State<LocationMapScreen> {
//   GoogleMapController? _mapController;
//   final TextEditingController _searchController = TextEditingController();
//   LatLng? _currentPosition;
//   LatLng? _destinationPosition;
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//   String googleApiKey = "AIzaSyDLuwvDTWdne_dA_qdMYggBGFYLVaDBJvw";

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   void _getCurrentLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     setState(() {
//       _currentPosition = LatLng(position.latitude, position.longitude);
//       _addMarker(_currentPosition!, 'Current Location');
//       _mapController
//           ?.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 14));
//     });
//   }

//   void _searchPlace() async {
//     if (_searchController.text.isNotEmpty) {
//       List<Location> locations =
//           await locationFromAddress(_searchController.text);
//       if (locations.isNotEmpty) {
//         setState(() {
//           _destinationPosition =
//               LatLng(locations.first.latitude, locations.first.longitude);
//           _addMarker(_destinationPosition!, 'Destination');
//           _getPolyline();
//         });
//       }
//     }
//   }

//   void _addMarker(LatLng position, String markerId) {
//     setState(() {
//       _markers.add(
//         Marker(
//           markerId: MarkerId(markerId),
//           position: position,
//           infoWindow: InfoWindow(title: markerId),
//         ),
//       );
//     });
//   }

//   void _getPolyline() async {
//     PolylineResult result = currentPosition.latitude, currentPosition.longitude),
//       PointLatLng(
//           _destinationPosition!.latitude, _destinationPosition!.longitude),
//       request: null,ait polylinePoints.getRouteBetweenCoordinates(
//       googleApiKey: googleApiKey
//       PointLatLng(currentPosition.latitude, currentPosition.longitude),
//       PointLatLng(
//           _destinationPosition!.latitude, _destinationPosition!.longitude),
//       request: null,
//     );

//     if (result.points.isNotEmpty) {
//       List<LatLng> polylineCoordinates = result.points
//           .map((point) => LatLng(point.latitude, point.longitude))
//           .toList();

//       setState(() {
//         _polylines.add(Polyline(
//           polylineId: const PolylineId('route'),
//           color: Colors.red,
//           points: polylineCoordinates,
//           width: 3,
//         ));
//       });
//     }
//   }

//   double _calculateDistance() {
//     if (_currentPosition != null && _destinationPosition != null) {
//       return Geolocator.distanceBetween(
//             _currentPosition!.latitude,
//             _currentPosition!.longitude,
//             _destinationPosition!.latitude,
//             _destinationPosition!.longitude,
//           ) /
//           1000; // Convert meters to kilometers
//     }
//     return 0;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Location Map')),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search for a place',
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.search),
//                   onPressed: _searchPlace,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: _currentPosition ?? const LatLng(0, 0),
//                 zoom: 14,
//               ),
//               markers: _markers,
//               polylines: _polylines,
//               onMapCreated: (controller) => _mapController = controller,
//             ),
//           ),
//           if (_destinationPosition != null)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 'Distance: ${_calculateDistance().toStringAsFixed(2)} km',
//                 style:
//                     const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
