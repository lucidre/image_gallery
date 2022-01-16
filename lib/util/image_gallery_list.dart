import 'package:flutter/foundation.dart';
import 'package:image_gallery/model/image.dart';

class ImageGalleryList with ChangeNotifier {
  List<Image> _allImages = [];

  get imageSize {
    return _allImages.length;
  }

  get allImages {
    return _allImages;
  }

  void addImages(List<Image> imageList) {
    _allImages = imageList;
    notifyListeners();
  }

  void addOlderImages(List<Image> imageList) {
    _allImages.addAll(imageList);
    notifyListeners();
  }

  void clearList() {
    _allImages.clear();
    notifyListeners();
  }
}
