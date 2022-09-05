part of 'gallery_view.dart';

class _GalleryViewImpl extends StatefulWidget {
  const _GalleryViewImpl(
      {required this.backgroundSize, required this.scrollDirection, required this.galleryPageController, required this.itemCount, required this.itemControllerBuilder, this.onPageChanged});

  final Size backgroundSize;

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
        ScaleGestureRecognizer: GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
          () => ScaleGestureRecognizer(),
          (ScaleGestureRecognizer instance) {
            instance
              ..onStart = _handleDragStart
              ..onUpdate = _handleDragUpdate
              ..onEnd = _handleDragEnd;
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
      child: Container(
        width: widget.backgroundSize.width,
        height: widget.backgroundSize.height,
        color: Colors.black54,
        child: IgnorePointer(
          ignoring: true,
          child: PageView.builder(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
        ),
      ),
    );
  }

  void _handleDragStart(ScaleStartDetails details) {
    if (_itemControllerList[_currentIndex].handleDragStart(details, widget.backgroundSize)) {
      return;
    }
  }

  void _handleDragUpdate(ScaleUpdateDetails details) {
    if (_itemControllerList[_currentIndex].handleDragUpdate(details, widget.backgroundSize)) {
      return;
    }

    _galleryPageController.position.moveTo(_galleryPageController.position.pixels + (widget.scrollDirection == Axis.horizontal ? details.focalPointDelta.dx : details.focalPointDelta.dy) * -1);
  }

  void _handleDragEnd(ScaleEndDetails details) {
    if (_itemControllerList[_currentIndex].handleDragEnd(details, widget.backgroundSize)) {
      return;
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
