part of 'gallery_view.dart';

class _GalleryViewImpl extends StatefulWidget {
  const _GalleryViewImpl(
      {required this.scrollDirection, required this.galleryPageController, required this.itemCount, required this.itemControllerBuilder, this.onPageChanged});

  final Axis scrollDirection;
  final GalleryPageController? galleryPageController;
  final void Function(int)? onPageChanged;

  final int itemCount;
  final GalleryViewItemController Function(int index) itemControllerBuilder;

  @override
  State<StatefulWidget> createState() => _GalleryViewImplState();
}

class _GalleryViewImplState extends State<_GalleryViewImpl> {
  late final GalleryPageController _galleryPageController;

  final List<GalleryViewItemController> _itemControllerList = [];

  late int _currentIndex;

  Drag? _drag;

  @override
  void initState() {
    _galleryPageController = widget.galleryPageController ?? GalleryPageController();
    _currentIndex = _galleryPageController.initialPage;

    for (int i = 0; i < widget.itemCount; i++) {
      _itemControllerList.add(widget.itemControllerBuilder(i));
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.galleryPageController == null) {
      _galleryPageController.dispose();
    }

    for (final GalleryViewItemController itemController in _itemControllerList) {
      itemController.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _GalleryViewImpl oldWidget) {
    if (oldWidget.galleryPageController == null) {
      _galleryPageController.dispose();
    }

    _galleryPageController = widget.galleryPageController ?? GalleryPageController();
    _currentIndex = _galleryPageController.initialPage;

    for (final GalleryViewItemController itemController in _itemControllerList) {
      itemController.dispose();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(),
          (VerticalDragGestureRecognizer instance) {
            instance
              ..onStart = _handleDragStart
              ..onUpdate = _handleDragUpdate
              ..onEnd = _handleDragEnd
              ..onCancel = _handleDragCancel;
          },
        ),
        HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
          () => HorizontalDragGestureRecognizer(),
          (HorizontalDragGestureRecognizer instance) {
            instance
              ..onStart = _handleDragStart
              ..onUpdate = _handleDragUpdate
              ..onEnd = _handleDragEnd
              ..onCancel = _handleDragCancel;
          },
        ),
        TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          () => TapGestureRecognizer(),
          (TapGestureRecognizer instance) {
            instance.onTap = _handleTap;
          },
        ),
        DoubleTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
          () => DoubleTapGestureRecognizer(),
          (DoubleTapGestureRecognizer instance) {
            instance.onDoubleTap = _handleDoubleTap;
          },
        ),
        LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
          () => LongPressGestureRecognizer(),
          (LongPressGestureRecognizer instance) {
            instance.onLongPress = _handleLongPress;
          },
        ),
      },
      child: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: widget.scrollDirection,
        controller: _galleryPageController,
        itemCount: widget.itemCount,
        itemBuilder: (context, index) {
          return GalleryViewItem(galleryViewItemController: _itemControllerList[index]);
        },
        onPageChanged: (index) {
          _currentIndex = index;

          if (widget.onPageChanged != null) {
            widget.onPageChanged!(index);
          }
        },
      ),
    );
  }

  void _handleDragStart(DragStartDetails details) {
    if (_itemControllerList[_currentIndex].handleDragStart(details)) {
      return;
    }

    assert(_drag == null);
    _drag = _galleryPageController.position.drag(details, () {
      assert(_drag != null);
      _drag!.cancel();
      _drag = null;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_itemControllerList[_currentIndex].handleDragUpdate(details)) {
      return;
    }

    _drag ??= _galleryPageController.position.drag(DragStartDetails(globalPosition: details.globalPosition, localPosition: details.localPosition), () {
      assert(_drag != null);
      _drag!.cancel();
      _drag = null;
    });

    _drag!.update(details);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_itemControllerList[_currentIndex].handleDragEnd(details)) {
      return;
    }

    if (_drag != null) {
      _drag!.cancel();
      _drag = null;
    }
  }

  void _handleDragCancel() {
    if (_itemControllerList[_currentIndex].handleDragCancel()) {
      return;
    }

    if (_drag != null) {
      _drag!.cancel();
      _drag = null;
    }
  }

  void _handleTap() {
    _itemControllerList[_currentIndex].onTap();
  }

  void _handleDoubleTap() {
    _itemControllerList[_currentIndex].onDoubleTap();
  }

  void _handleLongPress() {
    _itemControllerList[_currentIndex].onLongPress();
  }
}
