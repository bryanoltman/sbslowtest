import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SBExample(),
    );
  }
}

class SBExample extends StatefulWidget {
  const SBExample({super.key});

  @override
  State<SBExample> createState() => _SBExampleState();
}

class _SBExampleState extends State<SBExample> {
  Color finalColor = Colors.white;
  final src =
      'https://www.hunterlab.com/media/images/tomoko-uji-qzoSJlPxS9k-unsplash-mi.2e16d0ba.fill-692x346.jpg';

  getInternalColor() async {
    final pg = await PaletteGenerator.fromImageProvider(
      NetworkImage(src),
    );
    final domColor = pg.dominantColor?.color;
    Color ic = domColor ?? Colors.white;
    finalColor = ic;
    setState(() {});
  }

  Size finalSize = Size(0, 0);
  Size croppedSize = Size(0, 0);
  img.Image? croppedIMG;

  getImageSize(Image image) async {
    Completer<ui.Image> completer = Completer<ui.Image>();
    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo image, bool _) {
      completer.complete(image.image);
    }));
    ui.Image info = await completer.future;
    int width = info.width;
    int height = info.height;
    finalSize = Size(width.toDouble(), height.toDouble());
    setState(() {});
  }

  cropImage(Image image) async {
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(src)).load(src))
        .buffer
        .asUint8List();
    img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage == null) return;
    img.Image croppedImage = img.copyCrop(
      originalImage,
      x: -90,
      y: -200,
      width: (finalSize.width * 0.5).toInt(),
      height: (finalSize.height * 0.9).toInt(),
    );
    img.Image resizedImage = img.copyResize(
      croppedImage,
      width: 720,
      height: 480,
      maintainAspect: true,
    );

    croppedSize =
        Size(resizedImage.width.toDouble(), resizedImage.height.toDouble());
    croppedIMG = resizedImage;

    setState(() {});
  }

  @override
  void initState() {
    getInternalColor();
    getImageSize(Image.network(src)).then((_) => cropImage(Image.network(src)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: finalColor,
        title: Text(
          'Shorebird Slowdown Example',
          style: TextStyle(
            color: Colors.deepPurple,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Final Palette Color"),
            Text(
              "#${finalColor.value.toRadixString(16)}",
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 30),
                  CircularProgressIndicator(),
                  SizedBox(width: 30),
                  CircularProgressIndicator(),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text('If there is a slowdown, the loaders will get stuck'),
            SizedBox(height: 50),
            SizedBox(
              width: 300,
              child: Image.network(src),
            ),
            SizedBox(height: 5),
            Text("Image Size (default)"),
            Text(
              "(${finalSize.width} x ${finalSize.height})px",
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 50),
            if (croppedIMG != null) ...[
              SizedBox(
                width: 300,
                child: Image.memory(
                  Uint8List.fromList(img.encodeJpg(croppedIMG!)),
                ),
              ),
              SizedBox(height: 5),
            ],
            Text("Image Size (cropped)"),
            Text(
              "(${croppedSize.width} x ${croppedSize.height})px",
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 300),
          ],
        ),
      ),
    );
  }
}
