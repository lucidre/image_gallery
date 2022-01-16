import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery/model/image.dart' as image_model;
import 'package:image_gallery/util/constants.dart';
import 'package:intl/intl.dart';

class ImageListItem extends StatelessWidget {
  final image_model.Image image;
  final Function(image_model.Image) function;

  const ImageListItem({
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
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Hero(
                tag: image.date,
                child: CircleAvatar(
                  minRadius: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: CachedNetworkImage(
                      imageUrl: image.image_url,
                      fit: BoxFit.cover,
                      height: 80,
                      width: 80,
                      placeholder: (context, url) => Container(),
                      errorWidget: (context, url, error) => Container(),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                  child: Row(
                children: [
                  const Icon(Icons.date_range, color: Colors.black),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    getFormattedDate(image.date),
                    style: Theme.of(context).textTheme.headline5,
                  )
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  static String getFormattedDate(String timestamp) {
    try {
      var dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (exception) {
      return "";
    }
  }
}
