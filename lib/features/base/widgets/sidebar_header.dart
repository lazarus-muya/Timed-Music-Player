import 'package:fluent_ui/fluent_ui.dart';
import 'package:timed_app/core/utils/extensions.dart';
import '../../../core/constants/colors_constants.dart';

class SidebarHeader extends StatelessWidget {
  const SidebarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104.0,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: BORDER_COLOR, width: 1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'T',
                  style: TextStyle(
                    color: context.theme.accentColor,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'M',
                  style: TextStyle(
                    color: context.theme.iconTheme.color,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'P',
                  style: TextStyle(
                    color: context.theme.accentColor,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // spacer(h: 20.0),
          Text(
            'Timed Music Player',
            style: TextStyle(
              color: context.theme.iconTheme.color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
