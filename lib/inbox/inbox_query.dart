/*
 * 
 * inbox_query.dart
 * Dataroid-Plugin-Flutter
 * 
 * Created on 10/12/2020.
 * Copyright (c) 2020 Dataroid. All rights reserved.
 * 
 * Save to the extent permitted by law, you may not use, copy, modify,
 * distribute or create derivative works of this material or any part
 * of it without the prior written consent of Dataroid.
 * Any reproduction of this material must contain this notice.
 * 
 */

import 'package:dataroid_sdk_platform_interface/constants.dart';
import 'package:dataroid_plugin_flutter/inbox/inbox_message.dart';

class InboxQuery {
  final InboxMessageType? messageType;
  final InboxMessageStatus? messageStatus;
  final DateTime? from;
  final DateTime? to;
  final bool? isAnonymous;
  InboxQuery({
    this.messageType,
    this.messageStatus,
    this.from,
    this.to,
    this.isAnonymous,
  });

  Map<String, dynamic> get toJSON => {
        ArgumentName.query: {
          ArgumentName.messageType: messageType?.index,
          ArgumentName.messageStatus: messageStatus?.index,
          ArgumentName.from: from?.millisecondsSinceEpoch,
          ArgumentName.to: to?.millisecondsSinceEpoch,
          ArgumentName.isAnonymous: isAnonymous,
        },
      };
}
