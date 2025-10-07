import 'package:fluent_ui/fluent_ui.dart';
import 'package:hexcolor/hexcolor.dart';

final textColor = HexColor("#a1a1a1");

FluentThemeData darkTheme = FluentThemeData(
  buttonTheme: ButtonThemeData(
    defaultButtonStyle: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(HexColor("#0E0E0E")),
      textStyle: WidgetStatePropertyAll(TextStyle(color: textColor)),
    ),
  ),
  brightness: Brightness.dark,
  accentColor: Colors.orange,
  scaffoldBackgroundColor: Colors.black,
  iconTheme: IconThemeData(color: textColor),

  cardColor: HexColor("#0E0E0E"),

  navigationPaneTheme: NavigationPaneThemeData(
    backgroundColor: HexColor("#0E0E0E"),
    selectedTextStyle: WidgetStatePropertyAll(
      const TextStyle(
        color: Colors.warningPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
    ),
    unselectedTextStyle: WidgetStatePropertyAll(TextStyle(color: textColor)),
  ),
);
