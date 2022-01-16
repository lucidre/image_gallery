import 'package:flutter/material.dart';

class ImageNotifier with ChangeNotifier {
  bool _isLoadingOldData = false;

  bool getLoadingStatus() => _isLoadingOldData;

  void updateDataLoading(bool newValue) {
    if (_isLoadingOldData == newValue) return;

    _isLoadingOldData = newValue;
    notifyListeners();
  }
}
