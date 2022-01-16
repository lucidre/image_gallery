import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery/model/image.dart' as image_model;
import 'package:image_gallery/util/constants.dart';
import 'package:photo_view/photo_view.dart';

class ImageScreen extends StatelessWidget {
  final image_model.Image image;

  const ImageScreen({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return Container(
      width: width,
      height: height,
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PhotoView.customChild(
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2.5,
            child: Hero(
              tag: image.date,
              child: CachedNetworkImage(
                imageUrl: image.image_url,
                fit: BoxFit.contain,
                height: double.infinity,
                width: double.infinity,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(),
              ),
            ),
          ),
          Positioned(
            top: height * 0.067,
            right: 8,
            child: IconButton(
              color: Colors.white,
              iconSize: 25,
              splashColor: Constants.kPrimaryColor,
              icon: const Icon(Icons.cloud_download),
              onPressed: () => downloadImage(context),
            ),
          ),
        ],
      ),
    );
  }

  void showSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void downloadImage(BuildContext context) async {
    try {
      showSnackBar('Image Download Started', context);
      const platform = MethodChannel('native_communication');
      await platform
          .invokeMethod('downloadFile', {'file_url': image.image_url});
    } catch (exception) {
      showSnackBar('Error Occurred in download', context);
    }
  }
}
