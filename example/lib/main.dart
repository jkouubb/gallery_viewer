import 'package:flutter/material.dart';
import 'package:gallery_viewer/gallery_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GalleryViewer Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [
      Container(
        width: 100,
        height: 100,
        color: Colors.blue,
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        height: 300,
        color: Colors.orange,
      ),
      Container(
        width: 300,
        height: MediaQuery.of(context).size.height,
        color: Colors.green,
      ),
      Container(),
    ];

    return Scaffold(
      appBar: AppBar(),
      body: GalleryView(
        itemCount: widgetList.length,
        itemControllerBuilder: (index) => DefaultGalleryViewItemController(
          contentConfig: GalleryViewItemContentConfig(
            getItemSize: () async {
              switch (index) {
                case 0:
                  return const Size(100, 100);

                case 1:
                  return Size(MediaQuery.of(context).size.width, 300);

                case 2:
                  return Size(300, MediaQuery.of(context).size.height);

                default:
                  return null;
              }
            },
            buildContent: (context) {
              return widgetList[index];
            },
            buildPlaceHold: (context) {
              return const Center(
                child: Icon(Icons.downloading, size: 100),
              );
            },
            buildNoSizeWidget: (context) {
              return Container(
                width: 100,
                height: 100,
                color: Colors.red,
                child: const Text('Oops! Can not get size of current item.'),
              );
            },
          ),
          gestureConfig: GalleryViewItemGestureConfig(),
          backgroundSize: MediaQuery.of(context).size,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
