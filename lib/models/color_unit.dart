import 'package:flutter/material.dart';

class ColorUnit {
  final Color color;
  ColorUnit(this.color);

  Map<String, dynamic> toJson() => {'color': color.value};
  factory ColorUnit.fromJson(Map<String, dynamic> json) =>
      ColorUnit(Color(json['color'] as int));
}
