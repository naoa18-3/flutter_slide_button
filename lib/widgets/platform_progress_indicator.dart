import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';

class PlatformProgressIndicator extends StatelessWidget {
  const PlatformProgressIndicator({
    this.large = false,
    this.materialStrokeWidth = 4.0,
    this.materialValueColor,
  });

  final bool large;
  final double materialStrokeWidth;
  final Animation<Color> materialValueColor;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoActivityIndicator(
        radius: large ? 15.0 : 10.0,
      );
    } else {
      return CircularProgressIndicator(
        strokeWidth: materialStrokeWidth,
        valueColor: materialValueColor,
      );
    }
  }
}
