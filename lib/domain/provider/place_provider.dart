// providers/place_provider.dart
import 'package:flutter/foundation.dart';
import 'package:pytl_backup/domain/services/place_service.dart';

class PlaceProvider with ChangeNotifier {
  final PlaceService _placeService;

  PlaceProvider({required PlaceService placeService})
    : _placeService = placeService;
}
