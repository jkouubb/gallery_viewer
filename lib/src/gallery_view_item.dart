import 'package:flutter/widgets.dart';

import 'gallery_controller.dart';

class GalleryViewItemValue {
  GalleryViewItemValue({required this.scale, required this.offset});

  final double scale;
  final Offset offset;
}

class GalleryViewItem extends StatefulWidget {
  const GalleryViewItem({Key? key, required this.galleryViewItemController}) : super(key: key);

  final GalleryViewItemController galleryViewItemController;

  @override
  State<StatefulWidget> createState() => _GalleryViewItemState();
}

class _GalleryViewItemState extends State<GalleryViewItem> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<Size?>(
      future: widget.galleryViewItemController.contentConfig.getItemSize(),
      builder: (context, snapShot) {
        assert(snapShot.connectionState != ConnectionState.none);

        if (snapShot.connectionState == ConnectionState.waiting) {
          return widget.galleryViewItemController.contentConfig.buildPlaceHold(context);
        }

        if (snapShot.connectionState == ConnectionState.done && snapShot.data == null) {
          return widget.galleryViewItemController.contentConfig.buildNoSizeWidget(context);
        }

        widget.galleryViewItemController.itemSize = snapShot.data!;

        return StreamBuilder<GalleryViewItemValue>(
          stream: widget.galleryViewItemController.stream,
          builder: (context, snapShot) {
            if (!snapShot.hasData) {
              return widget.galleryViewItemController.contentConfig.buildPlaceHold(context);
            }

            GalleryViewItemValue newValue = snapShot.data!;

            return Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: widget.galleryViewItemController.itemSize!.width,
                height: widget.galleryViewItemController.itemSize!.height,
                child: Transform(
                  transform: Matrix4.translationValues(newValue.offset.dx, newValue.offset.dy, 0)..scaled(newValue.scale, newValue.scale),
                  child: widget.galleryViewItemController.contentConfig.buildContent(context),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
