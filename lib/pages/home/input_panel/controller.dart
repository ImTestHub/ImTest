import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:im_test/components/sliding_up_panel/sliding_up_panel.dart';
import 'package:im_test/helper/platform.dart';
import 'package:im_test/models/base.dart';
import 'package:im_test/pages/home/input_panel/panel_item.dart';
import 'package:signals/signals_flutter.dart';

part 'input_panel.dart';

class InputPanelController {
  final focusNode = FocusNode();

  final panelOpen = signal(false);

  final panelController = PanelController();

  void handleTogglePanel() {
    if (panelController.isPanelOpen) {
      focusNode.requestFocus();

      panelController.close();
    } else {
      focusNode.unfocus();

      panelController.open();
    }

    panelOpen.value = !panelOpen.value;
  }

  void handlePanelOpened() {
    panelOpen.value = true;
  }

  void handlePanelClosed() {
    panelOpen.value = false;
  }

  void _listenFocusNode() {
    if (focusNode.hasFocus) {
      panelController.close();
      panelOpen.value = false;
    }
  }

  void onInit() {
    focusNode.addListener(_listenFocusNode);
  }

  void onDispose() {
    focusNode.removeListener(_listenFocusNode);
  }
}
