# sliding_button

A Flutter package that enables apps to use a slide button to confirm actions.

## Installation

Just follow the basic installation of any flutter plugin by adding the package to the project's pubspec.yaml.

## Using this amazing package

You can start by adding the **Sliding Button** to your code. All properties inside the constructor are optional so it's fast to test the package. I'll list the properties later.

Simply add the following code and you'll have a fully functional **Sliding Button**:

```dart
import 'package:sliding_button/sliding_button.dart';

...
SlidingButton(),
...
```

After testing the Widget you can look for the properties below that allows you to style the (almost) the hole thing:

```dart
import 'package:slide_button/slide_button.dart';

...
SlidingButton(
  // Change the HEIGHT of the button. The width is always double.infinity
  buttonHeight = 55,
  // Change the BACKGROUND COLOR of the button
  buttonColor = Colors.green,
  // Change the TEXT COLOR of the button
  buttonTextColor = Colors.white,
  // Change the TEXT of the button
  buttonText = 'Slide to confirm...',
  // Change the MARGIN between the SLIDE BUTTON and the BUTTON
  slideButtonMargin = 7.5,
  // Change the BACKGROUND COLOR of the SLIDE BUTTON
  slideButtonColor = Colors.white,
  // Change the ICON COLOR of the ICON that goes inside the SLIDE BUTTON
  slideButtonIconColor = Colors.green,
  // Change the ICON of the widget that goes inside the SLIDE BUTTON
  slideButtonIcon = Icons.chevron_right,
  // Change the SIZE of the ICON that goes inside the SLIDE BUTTON
  slideButtonIconSize = 30.0,
  // Change the RADIUS of the BUTTON and SLIDE BUTTON
  radius = 4.0,
  // The AMOUNT OF THE TOTAL WIDTH OF THE BUTTON IN % that the user need to slide so we can consider the action as completed
  successfulThreshold = 0.9,
  // The WIDGET that will be shown when the slide action is completed
  widgetWhenSlideIsCompleted,
  // A simple VoidCallback that WILL BE CALLED WHEN THE SLIDE ACTION IS COMPLETED
  onSlideSuccessCallback,
)
...
```

## Using the Sliding Button callbacks

To get notified when a slide event is completed you'll need provide a VoidCallback to the onSlideSuccessCallback property:

```
SlidingButton(
  ...
  onSlideSuccessCallback: () {
    // Put your amazing code here
  },
)
...
```

And finally, if you want to reset the state of the **Sliding Button** you need to access it's state through a GlobalKey:

```
final GlobalKey<SlidingButtonState> _slideButtonKey = GlobalKey<SlidingButtonState>();

...

SlidingButton(
  key: _slideButtonKey,
  ...
  onSlideSuccessCallback: () {
    // This will reset the button to the initial state
    _slideButtonKey.currentState.reset();
  },
)
...
```
