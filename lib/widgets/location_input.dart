import 'package:flutter/material.dart';
import 'package:favorite_place_app/models/place.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:favorite_place_app/screens/map.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectPlace});

  final void Function(PlaceLocation location) onSelectPlace;

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  late final MapController mapController;
  var _isGettingLocation = false;

  @override
  void initState() {
    mapController = MapController();
    super.initState();
  }

  // Function to fetch the address for a given location (latitude & longitude)
  Future<void> _getLocationAddress(double latitude, double longitude) async {
    try {
      List<geo.Placemark> placemark = await geo.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemark.isNotEmpty) {
        final street = placemark[0].street ?? '';
        final postalcode = placemark[0].postalCode ?? '';
        final locality = placemark[0].locality ?? '';
        final country = placemark[0].country ?? '';
        final address = '$street, $postalcode, $locality, $country';

        setState(() {
          _pickedLocation = PlaceLocation(
            latitude: latitude,
            longitude: longitude,
            address: address,
          );
          _isGettingLocation = false;
        });

        widget.onSelectPlace(_pickedLocation!);
      }
    } catch (e) {
      // Handle error (e.g., no address found or API issue)
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  // Save location by fetching the address using geocoding
  Future<void> _savePlace(double latitude, double longitude) async {
    setState(() {
      _isGettingLocation = true;
    });

    await _getLocationAddress(latitude, longitude);
  }

  // Get current location from the device
  void _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      return;
    }

    _savePlace(lat, lng);
  }

  // Select a location on the map
  void _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => const MapScreen(isSelecting: true),
      ),
    );

    if (pickedLocation == null) {
      return;
    }

    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );

    if (_pickedLocation != null) {
      previewContent = FlutterMap(
        mapController: mapController,
        options: MapOptions(
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.none,
          ),
          initialCenter: LatLng(
            _pickedLocation!.latitude,
            _pickedLocation!.longitude,
          ),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', // Using OpenStreetMap tiles
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                  _pickedLocation!.latitude,
                  _pickedLocation!.longitude,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
              onPressed: _getCurrentLocation,
            ),
            TextButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
              onPressed: _selectOnMap,
            ),
          ],
        ),
      ],
    );
  }
}
