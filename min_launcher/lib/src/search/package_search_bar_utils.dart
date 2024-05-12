import 'package:flutter/material.dart';

class PackageSearchBarUtils {
  PackageSearchBarUtils();

  /// Ensure only one focus request can be made at once.
  bool canFocus = true;

  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();

  /// Initialize the PackageSearchBarUtils.
  void init() {
    focusNode.addListener(_onFocus);
  }

  /// Unfocus from text field.
  void unfocus() {
    focusNode.unfocus();
    canFocus = false;
  }

  /// Add as listener to FocusNode and run when it has requested focus.
  void _onFocus() {
    if (!focusNode.hasFocus || textEditingController.text.isEmpty) return;
    _moveCursorAtEnd();
  }

  /// Position the cursor at the end of the text.
  void _moveCursorAtEnd() {
    textEditingController.selection = TextSelection.collapsed(
      offset: textEditingController.text.length,
    );
  }

  /// Clear query text and request/deny focus
  Future<void> clearAndFocus(void Function() notifyListeners, {bool focus = false, bool clear = true}) async {
    // Remove focus from the text field because, after an app launch
    // returning to launcher the keyboard will be hidden but sometimes
    // the text field will be focused making the swipe down not work
    if (!focus) {unfocus();}
    else {canFocus = true;}

    notifyListeners();

    // Delay so that any key pressed during the launch of a package
    // can be cleared.
    // Also, we delay so that if the NotificationListener gives a
    // false positive (swipe up) then, the canFocus will be set
    // to false in it's ScrollUpdateNotification part of the if
    // statement when calling controller.unfocus().
    await Future.delayed(const Duration(milliseconds: 250), () {
      if (clear) textEditingController.clear();
      if (canFocus) {focusNode.requestFocus(); _moveCursorAtEnd();}
      else {focusNode.unfocus();}
    });
  }

}