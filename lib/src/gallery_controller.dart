import 'dart:async';

import 'package:flutter/widgets.dart';

import 'gallery_view_item.dart';

class GalleryPageController extends PageController {
  GalleryPageController({
    int initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
  }) : super(initialPage: initialPage, keepPage: keepPage, viewportFraction: viewportFraction);
}

class GalleryViewItemContentConfig {
  GalleryViewItemContentConfig({required this.getItemSize, required this.buildPlaceHold, required this.buildContent, required this.buildNoSizeWidget});

  final Future<Size?> Function() getItemSize;

  final Widget Function(BuildContext context) buildPlaceHold;

  final Widget Function(BuildContext context) buildContent;

  final Widget Function(BuildContext context) buildNoSizeWidget;
}

class GalleryViewItemGestureConfig {
  GalleryViewItemGestureConfig({this.onTap, this.onDoubleTap, this.onLongPress});

  final void Function()? onTap;

  final void Function()? onDoubleTap;

  final void Function()? onLongPress;
}

enum _GalleryViewItemStatus {
  idle,
  scaling,
  moving,
}

abstract class GalleryViewItemController {
  GalleryViewItemController(
      {required this.contentConfig,
      required this.gestureConfig,
      required Size backgroundSize,
      Offset initialOffset = Offset.zero,
      double initialScale = 1.0,
      double minScale = 1.0,
      double maxScale = 5.0}) {
    _itemOffset = initialOffset;
    _itemScale = initialScale;
    _minScale = minScale;
    _maxScale = maxScale;

    _streamController = StreamController<GalleryViewItemValue>(
      onListen: () {
        _streamController.add(GalleryViewItemValue(scale: initialScale, offset: initialOffset));
      },
    );
  }

  final GalleryViewItemContentConfig contentConfig;
  final GalleryViewItemGestureConfig gestureConfig;

  late final StreamController<GalleryViewItemValue> _streamController;
  Stream<GalleryViewItemValue> get stream => _streamController.stream;

  late Offset _itemOffset;
  Offset get itemOffset => _itemOffset;

  late double _minScale;
  late double _maxScale;
  late double _itemScale;
  double get itemScale => _itemScale;

  Size? itemSize;

  _GalleryViewItemStatus _status = _GalleryViewItemStatus.idle;

  void dispose() {
    _streamController.close();
  }

  bool handleDragStart(ScaleStartDetails details, Size backgroundSize);

  bool handleDragUpdate(ScaleUpdateDetails details, Size backgroundSize);

  bool handleDragEnd(ScaleEndDetails details, Size backgroundSize);

  void onTap() {
    if (gestureConfig.onTap != null) {
      gestureConfig.onTap!();
    }
  }

  void onDoubleTap() {
    if (gestureConfig.onDoubleTap != null) {
      gestureConfig.onDoubleTap!();
    }
  }

  void onLongPress() {
    if (gestureConfig.onLongPress != null) {
      gestureConfig.onLongPress!();
    }
  }
}

class DefaultGalleryViewItemController extends GalleryViewItemController {
  DefaultGalleryViewItemController({
    required GalleryViewItemContentConfig contentConfig,
    required GalleryViewItemGestureConfig gestureConfig,
    required Size backgroundSize,
    Offset initialOffset = Offset.zero,
    double initialScale = 1.0,
  }) : super(contentConfig: contentConfig, gestureConfig: gestureConfig, backgroundSize: backgroundSize, initialScale: initialScale, initialOffset: initialOffset);

  @override
  bool handleDragStart(ScaleStartDetails details, Size backgroundSize) {
    if (!_streamController.hasListener) {
      return false;
    }

    _updateStatus(details.pointerCount, _itemOffset, _itemScale, backgroundSize);

    return _status != _GalleryViewItemStatus.idle;
  }

  @override
  bool handleDragUpdate(ScaleUpdateDetails details, Size backgroundSize) {
    if (!_streamController.hasListener || _status == _GalleryViewItemStatus.idle) {
      return false;
    }

    _updateStatus(details.pointerCount, _itemOffset + details.focalPointDelta, details.scale, backgroundSize);

    return _status != _GalleryViewItemStatus.idle;
  }

  @override
  bool handleDragEnd(ScaleEndDetails details, Size backgroundSize) {
    if (!_streamController.hasListener || _status == _GalleryViewItemStatus.idle) {
      return false;
    }

    _GalleryViewItemStatus preStatus = _status;
    _updateStatus(details.pointerCount, _itemOffset, _itemScale, backgroundSize);

    return true;
  }

  Offset _getFinalOffset(Offset intendOffset, Size backgroundSize) {
    assert(itemSize != null);

    Size itemSizeWithScale = itemSize! * _itemScale;

    double limitX = (backgroundSize.width - itemSizeWithScale.width).abs() / 2;
    double limitY = (backgroundSize.height - itemSizeWithScale.height).abs() / 2;

    return Offset(intendOffset.dx.clamp(limitX * -1, limitX), intendOffset.dy.clamp(limitY * -1, limitY));
  }

  void _updateStatus(int pointerCount, Offset intendOffset, double intendDouble, Size backgroundSize) {
    if (pointerCount == 0) {
      _status = _GalleryViewItemStatus.idle;
      return;
    }

    if (pointerCount == 1) {
      Size itemSizeWithScale = itemSize! * _itemScale;

      double limitX = (backgroundSize.width - itemSizeWithScale.width).abs() / 2;
      double limitY = (backgroundSize.height - itemSizeWithScale.height).abs() / 2;

      bool canMove = intendOffset.dx.abs() <= limitX && intendOffset.dy.abs() <= limitY;

      _status = canMove ? _GalleryViewItemStatus.moving : _GalleryViewItemStatus.idle;
      return;
    }

    if (pointerCount >= 2) {
      _status = _GalleryViewItemStatus.scaling;
      return;
    }
  }
}
