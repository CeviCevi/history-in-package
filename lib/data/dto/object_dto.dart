import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pytl_backup/data/models/place_model/place_model.dart';

class ObjectDto with ChangeNotifier {
  int id = 0;
  double oX = 0;
  double oY = 0;
  PlaceModel? placeModel;
  bool _isSearching = false;

  void startSearch() {
    _isSearching = true;
    log("Search started");
    notifyListeners();
  }

  void stopSearch() {
    _isSearching = false;
    log("Search stopped");
    notifyListeners();
  }

  bool get isSearching => _isSearching;

  void setSearchQuery(int id, double oX, double oY) {
    this.id = id;
    this.oX = oX;
    this.oY = oY;
    log("Search query set: id=$id, oX=$oX, oY=$oY");
    notifyListeners();
  }

  void setPlace(PlaceModel placeModel) {
    this.placeModel = placeModel;
    log("setPlece: ${placeModel.label}");
    notifyListeners();
  }
}
