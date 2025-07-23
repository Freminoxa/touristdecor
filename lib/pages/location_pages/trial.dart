import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _initialPosition = LatLng(0.0515, 37.6456);
  late GoogleMapController _googleMapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _googleMapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
    setState(() {
      _markers.add(
        const Marker(
          markerId: MarkerId('initial'),
          position: _initialPosition,
          infoWindow: InfoWindow(title: 'Initial Location'),
        ),
      );
    });
  }

  Future<void> _searchPlace() async {
    String searchAddress = _searchController.text;
    try {
      List<Location> locations = await locationFromAddress(searchAddress);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng searchLatLng = LatLng(location.latitude, location.longitude);

        setState(() {
          _markers.add(
            Marker(
              markerId: const MarkerId('search'),
              position: searchLatLng,
              infoWindow: InfoWindow(title: searchAddress),
            ),
          );

          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              color: Colors.red,
              width: 3,
              points: [_initialPosition, searchLatLng],
            ),
          );
        });

        _googleMapController.animateCamera(
          CameraUpdate.newLatLngZoom(searchLatLng, 12),
        );
      }
    } catch (e) {
      print('Error searching for place: $e');
      // You might want to show an error message to the user here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search for a place'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a place',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchPlace,
                ),
              ),
              onSubmitted: (_) => _searchPlace(),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: _initialPosition,
                zoom: 11.5,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController.animateCamera(
          CameraUpdate.newLatLngZoom(_initialPosition, 11.5),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}