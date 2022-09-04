import 'package:flutter/widgets.dart';

import 'gallery_controller.dart';

class GalleryViewItemValue {
  GalleryViewItemValue({required this.scale, required this.offset});

  final double scale;
  final Offset offset;
}

class GalleryViewItem extends StatelessWidget {
  const GalleryViewItem({super.key, required this.galleryViewItemController});

  final GalleryViewItemController galleryViewItemController;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Size?>(
      future: galleryViewItemController.contentConfig.getItemSize(),
      builder: (context, snapShot) {
        assert(snapShot.connectionState != ConnectionState.none);

        if (snapShot.connectionState == ConnectionState.waiting) {
          return galleryViewItemController.contentConfig.buildPlaceHold(context);
        }

        if (snapShot.connectionState == ConnectionState.done && snapShot.data == null) {
          return galleryViewItemController.contentConfig.buildNoSizeWidget(context);
        }

        galleryViewItemController.itemSize = snapShot.data!;

        return StreamBuilder<GalleryViewItemValue>(
          stream: galleryViewItemController.stream,
          builder: (context, snapShot) {
            if (!snapShot.hasData) {
              return galleryViewItemController.contentConfig.buildPlaceHold(context);
            }

            GalleryViewItemValue newValue = snapShot.data!;

            return Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: galleryViewItemController.itemSize.width,
                height: galleryViewItemController.itemSize.height,
                child: Transform(
                  transform: Matrix4.translationValues(newValue.offset.dx, newValue.offset.dy, 0)..scaled(newValue.scale, newValue.scale),
                  child: galleryViewItemController.contentConfig.buildContent(context),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
