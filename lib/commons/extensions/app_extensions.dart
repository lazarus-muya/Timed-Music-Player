import 'package:flutter/material.dart';

extension AppExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textStyle => Theme.of(this).textTheme;
}