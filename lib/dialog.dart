import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';

class ProgressDialogWidget extends StatefulWidget {
  const ProgressDialogWidget({Key? key}) : super(key: key);

  @override
  State<ProgressDialogWidget> createState() => _ProgressDialogWidgetState();
}

class _ProgressDialogWidgetState extends State<ProgressDialogWidget> {
  late Subscription subscription;
  Double? progress;

  @override
  void initState() {
    super.initState();
    subscription = VideoCompress.compressProgress$.subscribe(
        (progress) => setState(() => this.progress = progress as Double?));
  }

  @override
  void dispose() {
    super.dispose();
    VideoCompress.cancelCompression();
    subscription.unsubscribe;
  }

  @override
  Widget build(BuildContext context) {
    //final value = progress == null ? progress : progress! / 100 as Double?;
    return Padding(
        padding: EdgeInsets.all(50),
        child: Column(
          children: [
            const Text(
              'Compressing Video....',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () => VideoCompress.cancelCompression(),
              child: const Text('Cancel'),
            )
          ],
        ));
  }
}
