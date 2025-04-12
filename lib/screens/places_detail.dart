import 'package:flutter/material.dart';

import 'package:favorite_place_app/screens/map.dart';
import 'package:favorite_place_app/models/place.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place;

  String get locationImage {
    final lat = place.location.latitude;
    final lng = place.location.longitude;
    return 'https://staticmap.openstreetmap.de/staticmap.php?center=$lat,$lng&zoom=16&size=600x300&markers=$lat,$lng,red-pushpin';
  }

  @override
  Widget build(BuildContext context) {
    print('Location Image URL: $locationImage');

    // Print the latitude and longitude to confirm values
    print(
      'Latitude: ${place.location.latitude}, Longitude: ${place.location.longitude}',
    );
    return Scaffold(
      appBar: AppBar(title: Text(place.title)),
      body: Stack(
        children: [
          Image.file(
            place.image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (ctx) => MapScreen(
                              location: place.location,
                              isSelecting: false,
                            ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey[200],
                    child: ClipOval(
                      child: SizedBox(
                        width: 140,
                        height: 140,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(
                              place.location.latitude,
                              place.location.longitude,
                            ),
                            initialZoom: 13,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'com.example.favorite_place_app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(
                                    place.location.latitude,
                                    place.location.longitude,
                                  ),
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.location_on,
                                    size: 30,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black54],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    place.location.address,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
