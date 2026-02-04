import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:im_test/api/api.dart';
import 'package:signals/signals_flutter.dart';

class SourceImage extends StatefulWidget {
  final String? tag;
  final String sourceID;
  final Function(Uint8List) onTap;

  const SourceImage({
    super.key,
    this.tag,
    required this.sourceID,
    required this.onTap,
  });

  @override
  State<SourceImage> createState() => _SourceImageState();
}

class _SourceImageState extends State<SourceImage> {
  final test = signal(Uint8List(0));

  Future<void> onInit() async {
    final res = await API.source(widget.sourceID);

    if (res != null) {
      test.value = res;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    onInit();
  }

  @override
  Widget build(BuildContext context) {
    final value = test.watch(context);

    if (value.isEmpty) {
      return SizedBox();
    }

    final image = Image.memory(
      value,
      gaplessPlayback: true,
      width: 100,
      fit: BoxFit.cover,
    );

    return GestureDetector(
      onTap: () => widget.onTap(value),
      child: widget.tag != null ? Hero(tag: widget.tag!, child: image) : image,
    );
  }
}
