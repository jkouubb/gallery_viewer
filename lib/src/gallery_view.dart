import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'gallery_controller.dart';
import 'gallery_view_item.dart';

part 'gallery_view_impl.dart';

class GalleryView extends StatelessWidget {
  const GalleryView(
      {super.key,
      required this.itemCount,
      required this.itemControllerBuilder,
      this.scrollDirection = Axis.horizontal,
      this.galleryPageController,
      this.onPageChanged});

  final Axis scrollDirection;

  final int itemCount;
  final GalleryViewItemController Function(int index) itemControllerBuilder;

  final GalleryPageController? galleryPageController;
  final void Function(int)? onPageChanged;

  @override
  Widget build(BuildContext context) {
    return _GalleryViewImpl(
      scrollDirection: scrollDirection,
      itemCount: itemCount,
      itemControllerBuilder: itemControllerBuilder,
      galleryPageController: galleryPageController,
      onPageChanged: onPageChanged,
    );
  }
}
