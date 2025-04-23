import 'package:flutter/material.dart';

class PlantReminder {
  final String id;
  final String plantName;
  final TimeOfDay time;
  final String notes;
  bool isEnabled;

  PlantReminder({
    required this.id,
    required this.plantName,
    required this.time,
    required this.notes,
    this.isEnabled = true,
  });
}
