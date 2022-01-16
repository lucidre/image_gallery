import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery/model/image.dart' as image_model;
import 'package:image_gallery/util/constants.dart';

class ImageGridItem extends StatelessWidget {
  final image_model.Image image;
  final Function(image_model.Image) function;

  const ImageGridItem({
    Key? key,
    required this.image,
    required this.function,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(5));
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      margin: const EdgeInsets.all(4),
      elevation: 3,
      child: InkWell(
        borderRadius: radius,
        splashColor: Constants.kItemTint,
        onTap: () => function(image),
        child: ClipRRect(
          borderRadius: radius,
          child: Hero(
            tag: image.date,
            child: CachedNetworkImage(
              imageUrl: image.image_url,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              placeholder: (context, url) => Container(),
              errorWidget: (context, url, error) => Container(),
            ),
          ),
        ),
      ),
    );
  }
}
