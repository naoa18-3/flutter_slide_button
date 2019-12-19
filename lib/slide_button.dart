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
  final Widget widgetWhenSlideIsCompleted;
  final VoidCallback onSlideSuccessCallback;

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
    this.widgetWhenSlideIsCompleted,
    this.onSlideSuccessCallback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => SlideButtonState(
      defaultButtonSize: this.buttonHeight, defaultButtonColor: this.buttonColor,
      defaultButtonText: this.buttonText, defaultSlideButtonMargin: this.slideButtonMargin,
      defaultSlideButtonColor: this.slideButtonColor, defaultButtonTextColor: this.buttonTextColor,
      defaultSlideButtonIconColor: this.slideButtonIconColor, defaultSlideButtonIcon: this.slideButtonIcon,
      defaultSlideButtonIconSize: this.slideButtonIconSize, defaultRadius: this.radius,
      successfulThreshold: this.successfulThreshold, widgetWhenSlideIsCompleted: this.widgetWhenSlideIsCompleted,
      onSlideSuccessCallback: this.onSlideSuccessCallback
  );

}

class SlideButtonState extends State<SlideButton> {

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
  Widget widgetWhenSlideIsCompleted;
  VoidCallback onSlideSuccessCallback;

  bool _isSlideEnabled = false;
  bool _isSlideStarted = false;
  bool _hasCompletedSlideWithSuccess = false;
  double _slideButtonMarginDragOffset = 0;
  double _slideButtonSize;
  double _slideButtonMargin;

  SlideButtonState({
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
    this.widgetWhenSlideIsCompleted,
    this.onSlideSuccessCallback,
  });

  @override
  void initState() {
    super.initState();
    // Initialize properties used on the slide button
    _slideButtonSize = defaultButtonSize - (defaultSlideButtonMargin * 2);
    _slideButtonMargin = defaultSlideButtonMargin;
    // Always add a default widget for slide successful event
    if (this.widgetWhenSlideIsCompleted == null) {
      this.widgetWhenSlideIsCompleted = Center(
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
          // On all positions I've added the _slideButtonMargin. Basically we use the _slideButtonMargin as a invisible touchable area that triggers the slide event
          final startXPosition = slideButtonOffset.dx - _slideButtonMargin;
          final endXPosition = startXPosition + defaultButtonSize + _slideButtonMargin;
          final startYPosition = slideButtonOffset.dy - _slideButtonMargin;
          final endYPosition = startYPosition + defaultButtonSize + _slideButtonMargin;
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
            // Check if the slide event has reached the minimum threshold to be considered a successful slide event
            final RenderBox renderBox = _buttonKey.currentContext.findRenderObject();
            if (_slideButtonSize >= successfulThreshold * renderBox.size.width) {
              _slideButtonSize = renderBox.size.width;
              _hasCompletedSlideWithSuccess = true;
              _isSlideEnabled = false;
              _isSlideStarted = false;
              // Make sure that we've called the success callback
              onSlideSuccessCallback?.call();
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
                  duration: Duration(milliseconds: 100),
                  width: _slideButtonSize, height: _slideButtonSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(this.defaultRadius),
                    color: defaultSlideButtonColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5.0,
                        spreadRadius: 2.0,
                      )
                    ],
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
                      child: widgetWhenSlideIsCompleted,
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

  void reset() {
    _slideButtonMarginDragOffset = 0;
    _slideButtonSize = defaultButtonSize - (defaultSlideButtonMargin * 2);
    _slideButtonMargin = defaultSlideButtonMargin;
    _hasCompletedSlideWithSuccess = false;
    _isSlideEnabled = false;
    _isSlideStarted = false;
    setState(() {});
  }

}
