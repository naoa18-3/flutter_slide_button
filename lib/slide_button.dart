library slide_button;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:slide_button/widgets/platform_progress_indicator.dart';

class SlideButton extends StatefulWidget {

  final double buttonHeight;
  final Color buttonColor;
  final Color buttonTextColor;
  final String buttonText;
  final double slideButtonMargin;
  final Color slideButtonColor;
  final Color slideButtonIconColor;
  final IconData slideButtonIcon;
  final double slideButtonIconSize;
  final double radius;
  final double successfulThreshold;
  final Widget widgetWhenDragIsSuccess;
  final VoidCallback onDragSuccessCallback;

  const SlideButton({Key key,
    this.buttonHeight = 55,
    this.buttonColor = Colors.green,
    this.buttonTextColor = Colors.white,
    this.buttonText = 'Slide to confirm...',
    this.slideButtonMargin = 7.5,
    this.slideButtonColor = Colors.white,
    this.slideButtonIconColor = Colors.green,
    this.slideButtonIcon = Icons.chevron_right,
    this.slideButtonIconSize = 30.0,
    this.radius = 4.0,
    this.successfulThreshold = 0.9,
    this.widgetWhenDragIsSuccess,
    this.onDragSuccessCallback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SlideButtonState(
      defaultButtonSize: this.buttonHeight, defaultButtonColor: this.buttonColor,
      defaultButtonText: this.buttonText, defaultSlideButtonMargin: this.slideButtonMargin,
      defaultSlideButtonColor: this.slideButtonColor, defaultButtonTextColor: this.buttonTextColor,
      defaultSlideButtonIconColor: this.slideButtonIconColor, defaultSlideButtonIcon: this.slideButtonIcon,
      defaultSlideButtonIconSize: this.slideButtonIconSize, defaultRadius: this.radius,
      successfulThreshold: this.successfulThreshold, widgetWhenDragIsSuccess: this.widgetWhenDragIsSuccess,
      onDragSuccessCallback: this.onDragSuccessCallback
  );

}

class _SlideButtonState extends State<SlideButton> {

  final _buttonKey = GlobalKey();
  final _slideButtonKey = GlobalKey();

  double defaultButtonSize;
  double defaultSlideButtonMargin;
  Color defaultButtonColor;
  String defaultButtonText;
  Color defaultSlideButtonColor;
  Color defaultButtonTextColor;
  Color defaultSlideButtonIconColor;
  IconData defaultSlideButtonIcon;
  double defaultSlideButtonIconSize;
  double defaultRadius;
  double successfulThreshold;
  Widget widgetWhenDragIsSuccess;
  VoidCallback onDragSuccessCallback;

  bool _isSlideEnabled = false;
  bool _isSlideStarted = false;
  bool _hasCompletedSlideWithSuccess = false;
  double _slideButtonMarginDragOffset = 0;
  double _slideButtonSize;
  double _slideButtonMargin;

  _SlideButtonState({
    this.defaultButtonSize,
    this.defaultButtonText,
    this.defaultSlideButtonMargin,
    this.defaultButtonColor,
    this.defaultSlideButtonColor,
    this.defaultButtonTextColor,
    this.defaultSlideButtonIconColor,
    this.defaultSlideButtonIcon,
    this.defaultSlideButtonIconSize,
    this.defaultRadius,
    this.successfulThreshold,
    this.widgetWhenDragIsSuccess,
    this.onDragSuccessCallback,
  });

  @override
  void initState() {
    super.initState();
    // Initialize properties used on the slide button
    _slideButtonSize = defaultButtonSize - (defaultSlideButtonMargin * 2);
    _slideButtonMargin = defaultSlideButtonMargin;
    // Always add a default widget for drag successful event
    if (this.widgetWhenDragIsSuccess == null) {
      this.widgetWhenDragIsSuccess = Center(
        child: SizedBox(
          width: defaultButtonSize / 3, height: defaultButtonSize / 3,
          child: PlatformProgressIndicator(materialValueColor: AlwaysStoppedAnimation<Color>(this.defaultSlideButtonIconColor), materialStrokeWidth: 1.3,),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: _hasCompletedSlideWithSuccess,
      child: GestureDetector(
        onTapDown: (tapDetails) {
          // Check if the tap down event has occurred inside the slide button
          final RenderBox renderBox = _slideButtonKey.currentContext.findRenderObject();
          final slideButtonOffset = renderBox.localToGlobal(Offset.zero);
          final startXPosition = slideButtonOffset.dx;
          final endXPosition = slideButtonOffset.dx + _slideButtonSize;
          final startYPosition = slideButtonOffset.dy;
          final endYPosition = slideButtonOffset.dy + _slideButtonSize;
          // print(startXPosition);
          // print(endXPosition);
          // print(startYPosition);
          // print(endYPosition);
          // print(tapDetails.globalPosition.dx);
          // print(tapDetails.globalPosition.dy);
          if ((tapDetails.globalPosition.dx >= startXPosition && tapDetails.globalPosition.dx <= endXPosition) &&
              (tapDetails.globalPosition.dy >= startYPosition && tapDetails.globalPosition.dy <= endYPosition)) {
            _isSlideEnabled = true;
            _slideButtonSize = defaultButtonSize;
            _slideButtonMargin = 0;
            setState(() {});
          } else{
            _isSlideEnabled = false;
            _isSlideStarted = false;
          }
        },
        onTapUp: (details) {
          _isSlideEnabled = false;
          _slideButtonSize = defaultButtonSize - (defaultSlideButtonMargin * 2);
          _slideButtonMargin = defaultSlideButtonMargin;
          setState(() {});
        },
        onTapCancel: () {
          if (!_isSlideEnabled) {
            _isSlideEnabled = false;
            _slideButtonSize = defaultButtonSize - (defaultSlideButtonMargin * 2);
            _slideButtonMargin = defaultSlideButtonMargin;
            setState(() {});
          }
        },
        onHorizontalDragStart: (dragDetails) {
          if (_isSlideEnabled) {
            _isSlideStarted = true;
            _slideButtonSize = defaultButtonSize + _slideButtonMarginDragOffset;
            _slideButtonMargin = 0;
            setState(() {});
          }
        },
        onHorizontalDragUpdate: (dragUpdateDetails) {
          print('horizontal_drag_update');
          if (_isSlideStarted) {
            _slideButtonMarginDragOffset += dragUpdateDetails.delta.dx;
            _slideButtonSize = defaultButtonSize + _slideButtonMarginDragOffset;
            _slideButtonMargin = 0;
            // Check for minimum values that must be respected
            _slideButtonMarginDragOffset = _slideButtonMarginDragOffset < 0 ? 0 : _slideButtonMarginDragOffset;
            _slideButtonSize = _slideButtonSize < defaultButtonSize ? defaultButtonSize : _slideButtonSize;
            setState(() {});
          }
        },
        onHorizontalDragCancel: () {
          print('horizontal_drag_cancel');
          _isSlideStarted = false;
          _isSlideEnabled = false;
          _slideButtonSize = defaultButtonSize - (defaultSlideButtonMargin * 2);
          _slideButtonMargin = defaultSlideButtonMargin;
          setState(() {});
        },
        onHorizontalDragEnd: (dragDetails) {
          print('horizontal_drag_end');
          if (_isSlideEnabled || _isSlideStarted) {
            // Check if the drag event has reached the minimum threshold to be considered a successful drag event
            final RenderBox renderBox = _buttonKey.currentContext.findRenderObject();
            if (_slideButtonSize >= successfulThreshold * renderBox.size.width) {
              _slideButtonSize = renderBox.size.width;
              _hasCompletedSlideWithSuccess = true;
              _isSlideEnabled = false;
              _isSlideStarted = false;
              // Make sure that we've called the success callback
              onDragSuccessCallback?.call();
            } else {
              _slideButtonMarginDragOffset = 0;
              _slideButtonSize = defaultButtonSize - (defaultSlideButtonMargin * 2);
              _slideButtonMargin = defaultSlideButtonMargin;
            }
            setState(() {});
          }
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          color: defaultButtonColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(this.defaultRadius)),
          elevation: 4,
          child: Container(
            key: _buttonKey,
            width: double.infinity,
            height: defaultButtonSize,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(left: (defaultSlideButtonMargin / 2) + defaultButtonSize),
                    child: Text(this.defaultButtonText.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: defaultButtonTextColor),),
                  ),
                ),
                AnimatedContainer(
                  key: _slideButtonKey,
                  margin: EdgeInsets.only(left: _slideButtonMargin, top: _slideButtonMargin),
                  duration: Duration(milliseconds: 50),
                  width: _slideButtonSize, height: _slideButtonSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(this.defaultRadius),
                    color: defaultSlideButtonColor,
                  ),
                  child: Center(
                    child: Icon(
                      this.defaultSlideButtonIcon, color: defaultSlideButtonIconColor, size: this.defaultSlideButtonIconSize,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _hasCompletedSlideWithSuccess ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    width: double.infinity, height: defaultButtonSize,
                    color: defaultSlideButtonColor,
                    child: Center(
                      child: widgetWhenDragIsSuccess,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
