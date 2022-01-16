class Image {
  final String image_url;
  final String date;

  Image({required this.image_url, required this.date});

  static Image copyFrom(Image image) {
    return Image(
      image_url: image.image_url,
      date: image.date,
    );
  }
}
