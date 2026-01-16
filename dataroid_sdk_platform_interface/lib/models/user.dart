/*
 * 
 * user.dart
 * Dataroid-Plugin-Flutter
 * 
 * Created on 27/11/2020.
 * Copyright (c) 2020 Dataroid. All rights reserved.
 * 
 * Save to the extent permitted by law, you may not use, copy, modify,
 * distribute or create derivative works of this material or any part
 * of it without the prior written consent of Dataroid.
 * Any reproduction of this material must contain this notice.
 * 
 */

import 'package:dataroid_sdk_platform_interface/constants.dart';

enum Gender { undefined, male, female, nonBinary, unknown }

class User {
  final String customerId;
  String? email;
  String? phone;
  String? nationalId;
  String? firstName;
  String? lastName;
  DateTime? dateOfBirth;
  Gender? gender;
  Map<String, dynamic>? attributes;
  Map<String, int>? _dateAttributes = {};

  User({
    required this.customerId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final user = User(
      customerId: json[ArgumentName.customerId] ?? '',
    );
    
    user.email = json[ArgumentName.email];
    user.phone = json[ArgumentName.phone];
    user.nationalId = json[ArgumentName.nationalId];
    user.firstName = json[ArgumentName.firstName];
    user.lastName = json[ArgumentName.lastName];
    
    // Handle dateOfBirth
    final dateOfBirthMs = json[ArgumentName.dateOfBirth] as int?;
    if (dateOfBirthMs != null) {
      user.dateOfBirth = DateTime.fromMillisecondsSinceEpoch(dateOfBirthMs);
    }
    
    // Handle gender
    final genderIndex = json[ArgumentName.genderIndex] as int?;
    if (genderIndex != null && genderIndex >= 0 && genderIndex < Gender.values.length) {
      user.gender = Gender.values[genderIndex];
    }
    
    // Handle attributes
    user.attributes = Map<String, dynamic>.from(json[ArgumentName.attributes] ?? {});
    
    // Reconstruct DateTime attributes from milliseconds
    final dateAttributes = json[ArgumentName.dateAttributes] as Map<String, dynamic>?;
    if (dateAttributes != null) {
      dateAttributes.forEach((key, value) {
        if (value is int) {
          user.attributes?[key] = DateTime.fromMillisecondsSinceEpoch(value);
        }
      });
    }
    
    return user;
  }

  Map<String, dynamic> get toJSON {
    _parseAttributes();
    return {
      ArgumentName.customerId: customerId,
      ArgumentName.email: email,
      ArgumentName.phone: phone,
      ArgumentName.nationalId: nationalId,
      ArgumentName.firstName: firstName,
      ArgumentName.lastName: lastName,
      ArgumentName.dateOfBirth: dateOfBirth?.millisecondsSinceEpoch,
      ArgumentName.genderIndex: gender?.index,
      ArgumentName.attributes: attributes,
      ArgumentName.dateAttributes: _dateAttributes,
    };
  }

  void _parseAttributes() {
    attributes?.entries.forEach((e) {
      if (e.value is DateTime) {
        final value = e.value as DateTime;
        _dateAttributes?[e.key] = value.millisecondsSinceEpoch;
      }
    });
    attributes?.removeWhere((key, value) => value is DateTime);
  }
}
