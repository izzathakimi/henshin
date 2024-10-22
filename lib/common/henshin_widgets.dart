import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../common/henshin_util.dart';

class FFButtonOptions {
  const FFButtonOptions({
    this.textStyle,
    this.elevation,
    this.height,
    this.width,
    this.padding,
    this.color,
    this.disabledColor,
    this.disabledTextColor,
    this.splashColor,
    this.iconSize,
    this.iconColor,
    this.iconPadding,
    this.borderRadius,
    this.borderSide,
  });

  final TextStyle? textStyle;
  final double? elevation;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? disabledColor;
  final Color? disabledTextColor;
  final Color? splashColor;
  final double? iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry? iconPadding;
  final double? borderRadius;
  final BorderSide? borderSide;
}

class FFButtonWidget extends StatefulWidget {
  const FFButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconData,
    required this.options,
    this.showLoadingIndicator = true,
  });

  final String text;
  final Widget? icon;
  final IconData? iconData;
  final Function() onPressed;
  final FFButtonOptions options;
  final bool showLoadingIndicator;

  @override
  State<FFButtonWidget> createState() => FFButtonWidgetState();
}

class FFButtonWidgetState extends State<FFButtonWidget> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Widget textWidget = loading
        ? Center(
            child: SizedBox(
              width: 23,
              height: 23,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.options.textStyle!.color ?? Colors.white,
                ),
              ),
            ),
          )
        : AutoSizeText(
            widget.text,
            style: widget.options.textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );

    final VoidCallback onPressed = widget.showLoadingIndicator
        ? () async {
            if (loading) {
              HenshinLogger.debug('Button press ignored - already loading');
              return;
            }
            setState(() => loading = true);
            try {
              await widget.onPressed();
              HenshinLogger.debug(
                  'Button action completed successfully: ${widget.text}');
            } catch (e, stackTrace) {
              HenshinLogger.error(
                'Error in button press: ${widget.text}',
                e,
                stackTrace,
              );
            } finally {
              if (mounted) {
                setState(() => loading = false);
              }
            }
          }
        : () {
            HenshinLogger.debug('Simple button pressed: ${widget.text}');
            widget.onPressed();
          };

    final buttonStyle = ElevatedButton.styleFrom(
      elevation: widget.options.elevation,
      backgroundColor: widget.options.color,
      disabledBackgroundColor: widget.options.disabledColor,
      disabledForegroundColor: widget.options.disabledTextColor,
      padding: widget.options.padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.options.borderRadius ?? 28),
        side: widget.options.borderSide ?? BorderSide.none,
      ),
    );

    // Handle icon button
    if (widget.icon != null || widget.iconData != null) {
      textWidget = Flexible(child: textWidget);
      return SizedBox(
        height: widget.options.height,
        width: widget.options.width,
        child: ElevatedButton.icon(
          icon: Padding(
            padding: widget.options.iconPadding ?? EdgeInsets.zero,
            child: widget.icon ??
                FaIcon(
                  widget.iconData,
                  size: widget.options.iconSize,
                  color: widget.options.iconColor ??
                      widget.options.textStyle!.color,
                ),
          ),
          label: textWidget,
          onPressed: onPressed,
          style: buttonStyle,
        ),
      );
    }

    // Handle regular button
    return SizedBox(
      height: widget.options.height,
      width: widget.options.width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: textWidget,
      ),
    );
  }
}

// class FFButtonWidgetState extends State<FFButtonWidget> {
//   bool loading = false;

//   @override
//   Widget build(BuildContext context) {
//     Widget textWidget = loading
//         ? Center(
//             child: SizedBox(
//               width: 23,
//               height: 23,
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   widget.options.textStyle!.color ?? Colors.white,
//                 ),
//               ),
//             ),
//           )
//         : AutoSizeText(
//             widget.text,
//             style: widget.options.textStyle,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           );

//     final VoidCallback? onPressed = widget.showLoadingIndicator
//         ? () async {
//             if (loading) {
//               HenshinLogger.debug('Button press ignored - already loading');
//               return;
//             }
//             setState(() => loading = true);
//             try {
//               await widget.onPressed();
//               HenshinLogger.debug('Button action completed successfully: ${widget.text}');
//             } catch (e, stackTrace) {
//               HenshinLogger.error(
//                 'Error in button press: ${widget.text}',
//                 e,
//                 stackTrace,
//               );
//             } finally {
//               setState(() => loading = false);
//             }
//           }
//         : () {
//             HenshinLogger.debug('Simple button pressed: ${widget.text}');
//             widget.onPressed();
//           };

//     final buttonStyle = ElevatedButton.styleFrom(
//       elevation: widget.options.elevation,
//       backgroundColor: widget.options.color,
//       disabledBackgroundColor: widget.options.disabledColor,
//       disabledForegroundColor: widget.options.disabledTextColor,
//       padding: widget.options.padding,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(widget.options.borderRadius ?? 28),
//         side: widget.options.borderSide ?? BorderSide.none,
//       ),
//     );

//       return SizedBox(
//       textWidget = Flexible(child: textWidget);
//       return SizedBox(
//         height: widget.options.height,
//         width: widget.options.width,
//         child: ElevatedButton.icon(
//           icon: Padding(
//             padding: widget.options.iconPadding ?? EdgeInsets.zero,
//             child: widget.icon ??
//                 FaIcon(
//                   widget.iconData,
//                   size: widget.options.iconSize,
//                   color: widget.options.iconColor ??
//                       widget.options.textStyle!.color,
//                 ),
//           ),
//           label: textWidget,
//           onPressed: onPressed,
//           style: buttonStyle,
//         ),
//       );
//     }

//     return SizedBox(
//       height: widget.options.height,
//       width: widget.options.width,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: buttonStyle,
//         child: textWidget,
//       ),
//     );
//   }
// }
