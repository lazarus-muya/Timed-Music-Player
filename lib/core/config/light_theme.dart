import 'package:fluent_ui/fluent_ui.dart';
import 'package:hexcolor/hexcolor.dart';

final textColor = HexColor("#373737");

FluentThemeData lightTheme = FluentThemeData(
  buttonTheme: ButtonThemeData(
    defaultButtonStyle: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(HexColor("#cfcfcf")),
      textStyle: WidgetStatePropertyAll(TextStyle(color: textColor)),
    ),
  ),
  brightness: Brightness.light,
  accentColor: Colors.orange,
  scaffoldBackgroundColor: Colors.white,
  iconTheme: IconThemeData(color: textColor),

  cardColor: HexColor("#cfcfcf"),

  navigationPaneTheme: NavigationPaneThemeData(
    backgroundColor: HexColor("#cfcfcf"),
    selectedTextStyle: WidgetStatePropertyAll(
      const TextStyle(
        color: Colors.warningPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
    ),
    unselectedTextStyle: WidgetStatePropertyAll(TextStyle(color: textColor)),
  ),
);
