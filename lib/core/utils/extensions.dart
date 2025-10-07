// import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:toastification/toastification.dart';

extension ContextExtension on BuildContext {
  FluentThemeData get theme => FluentTheme.of(this);

  showToast({required String message, bool? isError}) => toastification.show(
    context: this,
    title: Text(message),
    autoCloseDuration: const Duration(seconds: 2),
    style: ToastificationStyle.fillColored,
    type: isError ?? false ? ToastificationType.error : ToastificationType.info,
  );
}

extension WidgetExtension on Widget {
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget withPadding(double padding) =>
      Padding(padding: EdgeInsets.all(padding), child: this);
}

extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
