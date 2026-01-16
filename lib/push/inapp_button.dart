/*
 * 
 * inapp_button.dart
 * Dataroid-Plugin-Flutter
 * 
 * Created on 15/12/2020.
 * Copyright (c) 2020 Dataroid. All rights reserved.
 * 
 * Save to the extent permitted by law, you may not use, copy, modify,
 * distribute or create derivative works of this material or any part
 * of it without the prior written consent of Dataroid.
 * Any reproduction of this material must contain this notice.
 * 
 */

import 'package:dataroid_sdk_platform_interface/constants.dart';

class InAppButton {
  String? text;
  String? buttonId;

  InAppButton(Map<dynamic, dynamic> json) {
    text = json[ArgumentName.text] as String?;
    buttonId = json[ArgumentName.buttonId] as String?;
  }
}
