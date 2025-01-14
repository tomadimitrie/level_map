import 'dart:async';

import 'package:flutter/material.dart';
import 'package:level_map/src/model/images_to_paint.dart';
import 'package:level_map/src/model/level_map_params.dart';
import 'package:level_map/src/paint/level_map_painter.dart';
import 'package:level_map/src/utils/load_ui_image_to_draw.dart';
import 'package:level_map/src/utils/scroll_behaviour.dart';

class LevelMap extends StatelessWidget {
  final LevelMapParams levelMapParams;
  final Color backgroundColor;
  final FutureOr<void> Function(int)? onTapDown;

  /// If set to false, scroll starts from the bottom end (level 1).
  final bool scrollToCurrentLevel;
  const LevelMap({
    Key? key,
    required this.levelMapParams,
    this.backgroundColor = Colors.transparent,
    this.scrollToCurrentLevel = true,
    this.onTapDown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ScrollConfiguration(
        behavior: const MyBehavior(),
        child: SingleChildScrollView(
          controller: ScrollController(
              initialScrollOffset: (((scrollToCurrentLevel
                          ? (levelMapParams.levelCount -
                              levelMapParams.currentLevel +
                              2)
                          : levelMapParams.levelCount)) *
                      levelMapParams.levelHeight) -
                  constraints.maxHeight),
          // physics: FixedExtentScrollPhysics(),
          child: ColoredBox(
            color: backgroundColor,
            child: FutureBuilder<ImagesToPaint?>(
              future: loadImagesToPaint(
                levelMapParams,
                levelMapParams.levelCount,
                levelMapParams.levelHeight,
                constraints.maxWidth,
              ),
              builder: (context, snapshot) {
                final painter = LevelMapPainter(
                    params: levelMapParams, imagesToPaint: snapshot.data);
                return GestureDetector(
                  onTapDown: (details) {
                    final position = details.localPosition;
                    final level = painter.isLevelTapped(position);
                    if (level != null) {
                      onTapDown?.call(level);
                    }
                  },
                  child: CustomPaint(
                    size: Size(constraints.maxWidth,
                        levelMapParams.levelCount * levelMapParams.levelHeight),
                    painter: painter,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
