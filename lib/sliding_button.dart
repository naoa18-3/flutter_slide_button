library slide_button;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sliding_button/widgets/platform_progress_indicator.dart';

class SlidingButton extends StatefulWidget {
  // Change the HEIGHT of the button. The width is always double.infinity
  final double buttonHeight;
  // Change the BACKGROUND COLOR of the button
  final Color buttonColor;
  // Change the TEXT COLOR of the button
  final Color buttonTextColor;
  // Change the TEXT of the button
  final String buttonText;
  // Change the MARGIN between the SLIDE BUTTON and the BUTTON
  final double slideButtonMargin;
  // Change the BACKGROUND COLOR of the SLIDE BUTTON
  final Color slideButtonColor;
  // Change the ICON COLOR of the ICON that goes inside the SLIDE BUTTON
  final Color slideButtonIconColor;
  // Change the ICON of the widget that goes inside the SLIDE BUTTON
  final IconData slideButtonIcon;
  // Change the SIZE of the ICON that goes inside the SLIDE BUTTON
  final double slideButtonIconSize;
  // Change the RADIUS of the BUTTON and SLIDE BUTTON
  final double radius;
  // The AMOUNT OF THE TOTAL WIDTH OF THE BUTTON IN % that the user need to slide so we can consider the action as completed
  final double successfulThreshold;
  // The WIDGET that will be shown when the slide action is completed
  final Widget widgetWhenSlideIsCompleted;
  // A simple VoidCallback that WILL BE CALLED WHEN THE SLIDE ACTION IS COMPLETED
  final VoidCallback onSlideSuccessCallback;

  const SlidingButton({
    Key key,
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
  State<StatefulWidget> createState() => SlidingButtonState(
      buttonHeight: this.buttonHeight,
      buttonColor: this.buttonColor,
      buttonText: this.buttonText,
      slideButtonMargin: this.slideButtonMargin,
      slideButtonColor: this.slideButtonColor,
      buttonTextColor: this.buttonTextColor,
      slideButtonIconColor: this.slideButtonIconColor,
      slideButtonIcon: this.slideButtonIcon,
      slideButtonIconSize: this.slideButtonIconSize,
      radius: this.radius,
      successfulThreshold: this.successfulThreshold,
      widgetWhenSlideIsCompleted: this.widgetWhenSlideIsCompleted,
      onSlideSuccessCallback: this.onSlideSuccessCallback);
}

class SlidingButtonState extends State<SlidingButton> {
  final _buttonKey = GlobalKey();
  final _slideButtonKey = GlobalKey();

  // Change the HEIGHT of the button. The width is always double.infinity
  double buttonHeight;
  // Change the BACKGROUND COLOR of the button
  Color buttonColor;
  // Change the TEXT COLOR of the button
  Color buttonTextColor;
  // Change the TEXT of the button
  String buttonText;
  // Change the MARGIN between the SLIDE BUTTON and the BUTTON
  double slideButtonMargin;
  // Change the BACKGROUND COLOR of the SLIDE BUTTON
  Color slideButtonColor;
  // Change the ICON COLOR of the ICON that goes inside the SLIDE BUTTON
  Color slideButtonIconColor;
  // Change the ICON of the widget that goes inside the SLIDE BUTTON
  IconData slideButtonIcon;
  // Change the SIZE of the ICON that goes inside the SLIDE BUTTON
  double slideButtonIconSize;
  // Change the RADIUS of the BUTTON and SLIDE BUTTON
  double radius;
  // The AMOUNT OF THE TOTAL WIDTH OF THE BUTTON IN % that the user need to slide so we can consider the action as completed
  double successfulThreshold;
  // The WIDGET that will be shown when the slide action is completed
  Widget widgetWhenSlideIsCompleted;
  // A simple VoidCallback that WILL BE CALLED WHEN THE SLIDE ACTION IS COMPLETED
  VoidCallback onSlideSuccessCallback;

  // Indicates if the user has tapped on the slide button and is ready to init the slide
  bool _isSlideEnabled = false;
  // Indicates that the user has began a drag gesture inside the slide button
  bool _isSlideStarted = false;
  // Indicates that a slide event was successfully completed
  bool _hasCompletedSlideWithSuccess = false;
  // The margin offset is used to calculate the new width of the slide button when a drag gesture is happening
  double _slideButtonMarginDragOffset = 0;
  // This two properties are calculated on runtime based on the buttonHeight and slideButtonMargin
  double _slideButtonSize;
  double _slideButtonMargin;

  SlidingButtonState({
    this.buttonHeight,
    this.buttonColor,
    this.buttonTextColor,
    this.buttonText,
    this.slideButtonMargin,
    this.slideButtonColor,
    this.slideButtonIconColor,
    this.slideButtonIcon,
    this.slideButtonIconSize,
    this.radius,
    this.successfulThreshold,
    this.widgetWhenSlideIsCompleted,
    this.onSlideSuccessCallback,
  });

  @override
  void initState() {
    super.initState();
    // Initialize properties used on the slide button
    _slideButtonSize = buttonHeight - (slideButtonMargin * 2);
    _slideButtonMargin = slideButtonMargin;
    // Always add a default widget for slide successful event
    if (this.widgetWhenSlideIsCompleted == null) {
      this.widgetWhenSlideIsCompleted = Center(
        child: SizedBox(
          width: buttonHeight / 3,
          height: buttonHeight / 3,
          child: PlatformProgressIndicator(
            materialValueColor:
                AlwaysStoppedAnimation<Color>(this.slideButtonIconColor),
            materialStrokeWidth: 1.3,
          ),
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
          final RenderBox renderBox =
              _slideButtonKey.currentContext.findRenderObject();
          final slideButtonOffset = renderBox.localToGlobal(Offset.zero);
          // On all positions I've added the _slideButtonMargin. Basically we use the _slideButtonMargin as a invisible touchable area that triggers the slide event
          final startXPosition = slideButtonOffset.dx - _slideButtonMargin;
          final endXPosition =
              startXPosition + buttonHeight + _slideButtonMargin;
          final startYPosition = slideButtonOffset.dy - _slideButtonMargin;
          final endYPosition =
              startYPosition + buttonHeight + _slideButtonMargin;
          // We only enable the slide gesture if the tap occurs inside the slide button
          if ((tapDetails.globalPosition.dx >= startXPosition &&
                  tapDetails.globalPosition.dx <= endXPosition) &&
              (tapDetails.globalPosition.dy >= startYPosition &&
                  tapDetails.globalPosition.dy <= endYPosition)) {
            _isSlideEnabled = true;
            _slideButtonSize = buttonHeight;
            _slideButtonMargin = 0;
            setState(() {});
          } else {
            _isSlideEnabled = false;
            _isSlideStarted = false;
          }
        },
        onTapUp: (details) {
          _isSlideEnabled = false;
          _resetSlideButton();
          setState(() {});
        },
        onTapCancel: () {
          if (!_isSlideEnabled) {
            _isSlideEnabled = false;
            _resetSlideButton();
            setState(() {});
          }
        },
        onHorizontalDragStart: (dragDetails) {
          if (_isSlideEnabled) {
            _isSlideStarted = true;
            _slideButtonSize = buttonHeight + _slideButtonMarginDragOffset;
            _slideButtonMargin = 0;
            setState(() {});
          }
        },
        onHorizontalDragUpdate: (dragUpdateDetails) {
          if (_isSlideStarted) {
            _slideButtonMarginDragOffset += dragUpdateDetails.delta.dx;
            _slideButtonSize = buttonHeight + _slideButtonMarginDragOffset;
            _slideButtonMargin = 0;
            // Check for minimum values that must be respected. We don't animate the slide button below the minimum.
            _slideButtonMarginDragOffset = _slideButtonMarginDragOffset < 0
                ? 0
                : _slideButtonMarginDragOffset;
            _slideButtonSize = _slideButtonSize < buttonHeight
                ? buttonHeight
                : _slideButtonSize;
            setState(() {});
          }
        },
        onHorizontalDragCancel: () {
          _isSlideStarted = false;
          _isSlideEnabled = false;
          _resetSlideButton();
          setState(() {});
        },
        onHorizontalDragEnd: (dragDetails) {
          if (_isSlideEnabled || _isSlideStarted) {
            // Check if the slide event has reached the minimum threshold to be considered a successful slide event
            final RenderBox renderBox =
                _buttonKey.currentContext.findRenderObject();
            if (_slideButtonSize >=
                successfulThreshold * renderBox.size.width) {
              _slideButtonSize = renderBox.size.width;
              _hasCompletedSlideWithSuccess = true;
              _isSlideEnabled = false;
              _isSlideStarted = false;
              // Make sure that we've called the success callback
              onSlideSuccessCallback?.call();
            } else {
              _slideButtonMarginDragOffset = 0;
              _resetSlideButton();
            }
            setState(() {});
          }
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          color: buttonColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(this.radius)),
          elevation: 4,
          child: Container(
            key: _buttonKey,
            width: double.infinity,
            height: buttonHeight,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(
                        left: (slideButtonMargin / 2) + buttonHeight),
                    child: Text(
                      this.buttonText.toUpperCase(),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: buttonTextColor),
                    ),
                  ),
                ),
                AnimatedContainer(
                  key: _slideButtonKey,
                  margin: EdgeInsets.only(
                      left: _slideButtonMargin, top: _slideButtonMargin),
                  duration: Duration(milliseconds: 100),
                  width: _slideButtonSize,
                  height: _slideButtonSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(this.radius),
                    color: slideButtonColor,
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
                      this.slideButtonIcon,
                      color: slideButtonIconColor,
                      size: this.slideButtonIconSize,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _hasCompletedSlideWithSuccess ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    width: double.infinity,
                    height: buttonHeight,
                    color: slideButtonColor,
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

  void _resetSlideButton() {
    _slideButtonSize = buttonHeight - (slideButtonMargin * 2);
    _slideButtonMargin = slideButtonMargin;
  }

  void reset() {
    _resetSlideButton();
    // Reset all values to make the button at his initial state
    _slideButtonMarginDragOffset = 0;
    _hasCompletedSlideWithSuccess = false;
    _isSlideEnabled = false;
    _isSlideStarted = false;
    setState(() {});
  }
}
