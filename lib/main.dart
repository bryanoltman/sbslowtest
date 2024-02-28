import 'package:flutter/material.dart';
import 'package:sbslowtest/palette_generator.dart';

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
      home: const SBExample(),
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

  _getInternalColor() async {
    print('getting network image');
    final networkImage = NetworkImage(src);
    print('got network image $networkImage');

    print('getting palette');
    // This line seems to be the culprit. It takes ~4s to run on a shorebird
    // release build.
    // 2024-02-27 17:48:41.427233-0500 Runner[582:22693] flutter: getting palette
    // 2024-02-27 17:48:41.488404-0500 Runner[582:22690] [updater::updater] Update thread finished with status: No update
    // 2024-02-27 17:48:45.131444-0500 Runner[582:22693] flutter: got palette
    final pg = await PaletteGenerator.fromImageProvider(networkImage);
    print('got palette');

    print('getting dominant color');
    final domColor = pg.dominantColor?.color;
    print('got dominant color');

    finalColor = domColor ?? Colors.white;

    setState(() {});
  }

  Size finalSize = const Size(0, 0);
  Size croppedSize = const Size(0, 0);

  @override
  void initState() {
    _getInternalColor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: finalColor,
        title: const Text(
          'Shorebird Slowdown Example',
          style: TextStyle(
            color: Colors.deepPurple,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Final Palette Color"),
            Text(
              "#${finalColor.value.toRadixString(16)}",
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 20),
            const Center(
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
            const SizedBox(height: 10),
            const Text('If there is a slowdown, the loaders will get stuck'),
            const SizedBox(height: 50),
            SizedBox(
              width: 300,
              child: Image.network(src),
            ),
            const SizedBox(height: 5),
            const Text("Image Size (default)"),
            Text(
              "(${finalSize.width} x ${finalSize.height})px",
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 300),
          ],
        ),
      ),
    );
  }
}
