import 'package:flutter/material.dart';
import 'package:image_gallery/util/image_gallery_list.dart';
import 'package:provider/provider.dart';

import 'image_screen.dart';

class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({Key? key}) : super(key: key);

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  ImageGalleryList? _imageGalleryList;
  PageController? _pageController;

  @override
  Widget build(BuildContext context) {
    _imageGalleryList = Provider.of<ImageGalleryList>(context, listen: false);

    int currentImagePosition =
        ModalRoute.of(context)?.settings.arguments as int;
    _pageController = PageController(
      initialPage: currentImagePosition,
    );
    return Scaffold(
      body: PageView.builder(
          controller: _pageController,
          itemCount: _imageGalleryList!.imageSize,
          itemBuilder: (context, index) {
            return ImageScreen(
              image: _imageGalleryList!.allImages[index],
            );
          }),
    );
  }
}
