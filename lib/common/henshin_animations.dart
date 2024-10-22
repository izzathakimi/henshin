import 'dart:math';

import 'package:flutter/material.dart';

enum AnimationTrigger {
  onPageLoad,
  onActionTrigger,
}

class AnimationInfo {
  AnimationInfo({
    required this.curve,
    required this.trigger,
    required this.duration,
    this.delay = 0,
    this.fadeIn = false,
    this.initialOpacity = 1,
    this.finalOpacity = 1,
    this.scale,
    this.slideOffset,
  });

  final Curve curve;
  final AnimationTrigger trigger;
  final int duration;
  final int delay;
  final bool fadeIn;
  final double initialOpacity;
  final double finalOpacity;
  final double? scale;
  final Offset? slideOffset;

  AnimationController? animationController;
  late Animation<double> curvedAnimation;

  void initialize(TickerProvider vsync) {
    animationController = AnimationController(
      vsync: vsync,
      duration: Duration(milliseconds: duration),
    );
    curvedAnimation = CurvedAnimation(
      parent: animationController!,
      curve: curve,
    );
  }
}

void createAnimation(AnimationInfo animation, TickerProvider vsync) {
  animation.animationController = AnimationController(
    duration: Duration(milliseconds: animation.duration),
    vsync: vsync,
  );
  animation.curvedAnimation = CurvedAnimation(
    parent: animation.animationController!,
    curve: animation.curve,
  );
}

void startPageLoadAnimations(
    Iterable<AnimationInfo> animations, TickerProvider vsync) {
  for (var anim in animations) {
    anim.animationController?.forward(from: 0.0);
  }
}

void setupTriggerAnimations(
    Iterable<AnimationInfo> animations, TickerProvider vsync) {
  for (var animation in animations) {
    createAnimation(animation, vsync);
    animation.animationController?.forward(from: 1.0);
  }
}

extension AnimatedWidgetExtension on Widget {
  Widget animated(Iterable<AnimationInfo?> animationInfos) {
    final animationInfo = animationInfos.first!;
    return AnimatedBuilder(
      animation: animationInfo.curvedAnimation,
      builder: (context, child) {
        var returnedWidget = child;
        if (animationInfo.slideOffset != null) {
          final animationValue = 1 - animationInfo.curvedAnimation.value;
          returnedWidget = Transform.translate(
            offset: animationInfo.slideOffset! * -animationValue,
            child: returnedWidget,
          );
        }
        if (animationInfo.scale != null && animationInfo.scale! > 0 && animationInfo.scale! != 1.0) {
          returnedWidget = Transform.scale(
            scale: animationInfo.scale! +
                (1.0 - animationInfo.scale!) *
                    animationInfo.curvedAnimation.value,
            child: returnedWidget,
          );
        }
        if (animationInfo.fadeIn) {
          final opacityScale =
              animationInfo.finalOpacity - animationInfo.initialOpacity;
          final opacityDelta =
              animationInfo.curvedAnimation.value * opacityScale;
          final opacity = animationInfo.initialOpacity + opacityDelta;
          returnedWidget = Opacity(
            opacity: min(0.998, opacity),
            child: returnedWidget,
          );
        }
        return returnedWidget!;
      },
      child:
          animationInfos.length > 1 ? animated(animationInfos.skip(1)) : this,
    );
  }
}
