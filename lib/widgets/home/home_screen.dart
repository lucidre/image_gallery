import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_gallery/model/image.dart' as image_model;
import 'package:image_gallery/util/constants.dart';
import 'package:image_gallery/util/firebase_util.dart';
import 'package:image_gallery/util/image_gallery_list.dart';
import 'package:image_gallery/util/image_notifier.dart';
import 'package:image_gallery/util/page_route.dart';
import 'package:image_gallery/widgets/home/fab.dart';
import 'package:image_gallery/widgets/home/image_list_item.dart';
import 'package:image_gallery/widgets/image/image_gallery_screen.dart';
import 'package:provider/provider.dart';

import 'image_grid_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingData = false;
  bool _isList = true;
  bool _allLoaded = false;
  ImageNotifier? _imageNofitier;
  ImageGalleryList? _imageGalleryListener;
  List<image_model.Image> _imageList = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _imageNofitier = Provider.of<ImageNotifier>(context, listen: false);
      _imageGalleryListener =
          Provider.of<ImageGalleryList>(context, listen: false);

      getData();
      _scrollController.addListener(_scrollListener);
    });
  }

  //METHOD TO LOAD OLDER DATA FROM FIREBASE
  void _scrollListener() {
    var minLength = _isList ? 3 : 10;
    if (_scrollController.position.pixels <=
        _scrollController.position.maxScrollExtent - minLength) {
      return;
    }
    if (!_isLoadingData &&
        _imageNofitier != null &&
        !_imageNofitier!.getLoadingStatus() &&
        !_allLoaded &&
        _imageList.isNotEmpty) {
      getOldData(_imageList.last.date);
    }
  }

  //METHOD TO GET OLDER DATA FROM FIREBASE
  void getOldData(String date) async {
    _imageNofitier?.updateDataLoading(true);
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await collectionRefImage
              .orderBy(Constants.date, descending: true)
              .where(Constants.date, isLessThan: date)
              .limit(30)
              .get();

      _imageNofitier?.updateDataLoading(false);

      if (querySnapshot.docs.isNotEmpty) {
        var imageItems = getMappedList(querySnapshot);
        setState(() {
          List<image_model.Image> list = (imageItems == null) ? [] : imageItems;
          _imageList.addAll(list);
          _imageGalleryListener?.addOlderImages(list);
          _allLoaded = list.isEmpty;
        });
      } else {
        setState(() {
          _allLoaded = true;
        });
      }
    } catch (exception) {
      showErrorSnackBar(exception);
    }
  }

  //METHOD TO MAP FIREBASE DATA TO THE IMAGE MODEL
  List<image_model.Image>? getMappedList(QuerySnapshot? querySnapshot) {
    return querySnapshot?.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      return image_model.Image(
          image_url: data['image_url'], date: data['date']);
    }).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _imageNofitier?.updateDataLoading(false);
    _imageGalleryListener?.clearList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Image Gallery',
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () => updateListType(true),
              icon: Icon(
                Icons.list,
                color: _isList ? Colors.blue : Colors.black,
              )),
          IconButton(
              onPressed: () => updateListType(false),
              icon: Icon(
                Icons.grid_view,
                color: !_isList ? Colors.blue : Colors.black,
              )),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: HomeFloatingActionBar(
        onUploadDone: addImageToList,
      ),
      body: Column(
        children: [
          Expanded(
            child: (_isLoadingData)
                ? const Center(child: CircularProgressIndicator.adaptive())
                : buildBody(),
          ),
          const _ImageListScreenOldDataProgressBar()
        ],
      ),
    );
  }

  void updateListType(bool type) {
    if (_isList != type) {
      setState(() {
        _isList = type;
      });
    }
  }

  void addImageToList(image_model.Image image) {
    setState(() {
      _imageList.insert(0, image);
      _imageGalleryListener?.addImages(_imageList);
    });
  }

  Widget buildBody() {
    return _isList ? buildListBody() : buildGridBody();
  }

  Widget buildGridBody() {
    var crossAxisCount = 4;
    return StaggeredGridView.countBuilder(
      staggeredTileBuilder: (index) {
        var crossAxisCellCount = (index % 3 == 0) ? 2 : 1;
        var mainAxisCellCount = (index % 3 == 0 || index % 2 == 0) ? 2 : 1;

        return StaggeredTile.count(
            crossAxisCellCount, mainAxisCellCount.toDouble());
      },
      crossAxisCount: crossAxisCount,
      controller: _scrollController,
      itemCount: _imageList.length,
      itemBuilder: (ctx, index) {
        return ImageGridItem(
            image: _imageList[index], function: onImageClicked);
      },
    );
  }

  Widget buildListBody() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _imageList.length,
      itemBuilder: (ctx, index) {
        return ImageListItem(
            image: _imageList[index], function: onImageClicked);
      },
    );
  }

  //METHOD TO GET THE INITIAL DATA FROM FIREBASE
  void getData() async {
    setState(() {
      _isLoadingData =
          true; // activate loading progress bar while fetching data
    });

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await collectionRefImage
              .orderBy(Constants.date, descending: true)
              .limit(30)
              .get();

      setState(() {
        _isLoadingData = false;
        if (querySnapshot.docs.isNotEmpty) {
          var imageItem = getMappedList(querySnapshot);
          _imageList = (imageItem == null) ? [] : imageItem;
          _imageGalleryListener?.addImages(_imageList);
        }
      });
    } catch (exception) {
      showErrorSnackBar(exception);
      setState(() {
        _isLoadingData = false;
        _imageList = [];
      });
    }
  }

  void onImageClicked(image_model.Image image) {
    var index = _imageList.indexOf(image);
    index = (index == -1) ? 0 : index;
    Navigator.of(context).push(
      CustomPageRoute(screen: const ImageGalleryScreen(), argument: index),
    );
  }

  void showErrorSnackBar(Object exception) {
    final snackBar = SnackBar(content: Text(exception.toString()));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

//show bottom loading when fetching older data only works when user is close to the bottom
class _ImageListScreenOldDataProgressBar extends StatefulWidget {
  const _ImageListScreenOldDataProgressBar({Key? key}) : super(key: key);

  @override
  _ImageListScreenOldDataProgressBarState createState() =>
      _ImageListScreenOldDataProgressBarState();
}

class _ImageListScreenOldDataProgressBarState
    extends State<_ImageListScreenOldDataProgressBar> {
  @override
  Widget build(BuildContext context) {
    ImageNotifier listener = Provider.of<ImageNotifier>(context);
    return (listener.getLoadingStatus())
        ? const Padding(
            padding: EdgeInsets.all(7.0),
            child: SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator.adaptive()),
          )
        : Container();
  }
}
