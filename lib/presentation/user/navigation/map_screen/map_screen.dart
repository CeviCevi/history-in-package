import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:pytl_backup/data/dto/object_dto.dart';
// import 'package:pytl_backup/data/models/place_model/mock/place_model_mock.dart'; // Убран мок
import 'package:pytl_backup/data/models/place_model/place_model.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/domain/services/place_service.dart';

class MapScreen extends StatefulWidget {
  // Убираем мок из конструктора, т.к. будем получать данные с бэкенда
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  final PlaceService _placeService = PlaceService();

  // Объявляем Future, который будет хранить асинхронную задачу
  late Future<List<PlaceModel>> _placesFuture;

  Future<List<PlaceModel>> _getPlaces() async {
    // Используем реальный сервис для получения данных с бэкенда
    return await _placeService.getPlaces();
  }

  @override
  void initState() {
    _mapController = MapController();

    _placesFuture = _getPlaces();

    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onMarkerTap(BuildContext context, PlaceModel placeModel) {
    final dataProvider = Provider.of<ObjectDto>(context, listen: false);

    dataProvider.setPlace(placeModel);
    dataProvider.startSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<PlaceModel>>(
        future: _placesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Состояние загрузки (пока ждем данные)
            return const Center(child: CircularProgressIndicator());
          } else {
            // Успешное получение данных
            final List<PlaceModel> places = snapshot.data ?? [];

            return FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(53.471680, 27.575760),
                initialZoom: 6,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.flutter_map_example',
                ),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    size: const Size(50, 50),
                    maxClusterRadius: 50,
                    // Используем полученные данные
                    markers: _getMarkers(places, context),
                    builder: (_, markers) {
                      return _ClusterMarker(
                        markersLength: markers.length.toString(),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  List<Marker> _getMarkers(List<PlaceModel> mapPoints, BuildContext context) {
    return List.generate(
      mapPoints.length,
      (index) => Marker(
        point: LatLng(mapPoints[index].oY, mapPoints[index].oX),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _onMarkerTap(context, mapPoints[index]),
              child: Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  color: primaryRed,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            Container(
              height: 25,
              width: 2,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 61, 61, 61),
              ),
            ),
          ],
        ),
        width: 50,
        height: 50,
        alignment: Alignment.center,
      ),
    );
  }
}

class _ClusterMarker extends StatelessWidget {
  const _ClusterMarker({required this.markersLength});

  final String markersLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: primaryRed.withBlue(242).withGreen(242),
        shape: BoxShape.circle,
        border: Border.all(color: primaryRed, width: 3),
      ),
      child: Center(
        child: Text(
          markersLength,
          style: TextStyle(
            color: primaryRed,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
