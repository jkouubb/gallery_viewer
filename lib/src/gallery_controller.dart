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

abstract class GalleryViewItemController {
  GalleryViewItemController(
      {required this.contentConfig, required this.gestureConfig, required Size backgroundSize, Offset initialOffset = Offset.zero, double initialScale = 1.0}) {
    _itemOffset = initialOffset;
    _itemScale = initialScale;
    _backgroundSize = backgroundSize;

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

  late double _itemScale;
  double get itemScale => _itemScale;

  Size? _itemSize;
  set itemSize(Size value) {
    _itemSize = value;
  }

  Size get itemSize => _itemSize!;

  late Size _backgroundSize;

  bool _moving = false;
  bool _scaling = false;

  void dispose() {
    _streamController.close();
  }

  bool handleDragStart(DragStartDetails details);

  bool handleDragUpdate(DragUpdateDetails details);

  bool handleDragEnd(DragEndDetails details);

  bool handleDragCancel();

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
    required super.contentConfig,
    required super.gestureConfig,
    required super.backgroundSize,
    super.initialOffset = Offset.zero,
    super.initialScale = 1.0,
  });

  @override
  bool handleDragStart(DragStartDetails details) {
    if (!_streamController.hasListener) {
      return false;
    }

    _moving = _checkIfCanMove(_itemOffset);

    return _moving;
  }

  @override
  bool handleDragUpdate(DragUpdateDetails details) {
    if (!_streamController.hasListener || !_moving) {
      return false;
    }

    Offset intendOffset = _itemOffset + details.delta;

    if (!_checkIfCanMove(intendOffset)) {
      _moving = false;
      return _moving;
    }

    Offset finalOffset = _getFinalOffset(intendOffset);

    _itemOffset = finalOffset;
    _streamController.add(GalleryViewItemValue(scale: _itemScale, offset: _itemOffset));

    return true;
  }

  @override
  bool handleDragEnd(DragEndDetails details) {
    if (!_streamController.hasListener || !_moving) {
      return false;
    }

    _moving = false;

    return true;
  }

  @override
  bool handleDragCancel() {
    if (!_streamController.hasListener || !_moving) {
      return false;
    }

    _moving = false;

    return true;
  }

  bool _checkIfCanMove(Offset intendOffset) {
    assert(_itemSize != null);

    Size itemSizeWithScale = _itemSize! * _itemScale;

    double limitY = (_backgroundSize.width - itemSizeWithScale.width).abs() / 2;
    double limitX = (_backgroundSize.height - itemSizeWithScale.height).abs() / 2;

    return intendOffset.dx.abs() <= limitX || intendOffset.dy.abs() <= limitY;
  }

  Offset _getFinalOffset(Offset intendOffset) {
    assert(_itemSize != null);

    Size itemSizeWithScale = _itemSize! * _itemScale;

    double limitY = (_backgroundSize.width - itemSizeWithScale.width).abs() / 2;
    double limitX = (_backgroundSize.height - itemSizeWithScale.height).abs() / 2;

    return Offset(intendOffset.dx.clamp(limitX * -1, limitX), intendOffset.dy.clamp(limitY * -1, limitY));
  }
}
