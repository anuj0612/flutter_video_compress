import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_compresser/CompressVideo.dart';
import 'package:video_compresser/dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VideoPage(),
    );
  }
}

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  File? fileVideo;
  Uint8List? thumbnailBytes;
  int? videoSize;
  MediaInfo? compressedVideoInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video app'),
        centerTitle: true,
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            pickVideo();
          },
          child: buildContext(),
        ),
      ),
    );
  }

  Widget buildContext() {
    if (fileVideo == null) {
      return const Text(
        'Select Video',
        style: TextStyle(color: Colors.red, fontSize: 20),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildThumbnail(),
          const SizedBox(height: 24),
          buildVideoInfo(),
          const SizedBox(height: 24),
          buildVideoCompressinfo(),
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () => compressVideo(),
            child: const Text('Compress video'),
          )
        ],
      );
    }
  }

  Widget buildThumbnail() => thumbnailBytes == null
      ? const CircularProgressIndicator()
      : Image.memory(thumbnailBytes!, height: 100);

  Widget buildVideoInfo() {
    if (videoSize == null) return Container();
    final size = videoSize! / 1000;
    return Column(
      children: [
        const Text(
          'Orignal video info',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Size: $size KB',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
        ),
      ],
    );
  }

  Widget buildVideoCompressinfo() {
    if(compressedVideoInfo ==null) return Container();
    final size = compressedVideoInfo!.filesize! / 1000;
    return Column(
      children: [
        const Text(
          'Compressed video info',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Size: $size KB',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
        ),
        const SizedBox(height: 8),
        Text(
          '${compressedVideoInfo!.path}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
        ),
      ],
    );
  }

  Future pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getVideo(source: ImageSource.gallery);

    if (pickedFile == null) return;
    final file = File(pickedFile.path);
    print(pickedFile.path);
    print('Got the file');
    setState(() => fileVideo = file);
    generateThumbnail(file);
    getVideoSize(file);
  }

  Future generateThumbnail(File file) async {
    final thumbnailBytes = await VideoCompress.getByteThumbnail(file.path);
    setState(() => this.thumbnailBytes = thumbnailBytes);
    print('Thumnail created');
  }

  Future getVideoSize(File file) async {
    final size = await file.length();
    setState(() => videoSize = size);
    print('got the video size');
  }

  Future compressVideo() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Dialog(child: ProgressDialogWidget()));
    final info = await VideoCompressApi.compressVideo(fileVideo!);
    setState(() => compressedVideoInfo = info);
    Navigator.of(context).pop();
  }
}
