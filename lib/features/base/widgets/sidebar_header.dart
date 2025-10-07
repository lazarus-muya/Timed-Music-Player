import 'package:fluent_ui/fluent_ui.dart';
import '../../../core/constants/colors_constants.dart';

class SidebarHeader extends StatelessWidget {
  const SidebarHeader({
    super.key,
  });

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
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'T',
                  style: TextStyle(
                    color: Colors.warningPrimaryColor,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'M',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'P',
                  style: TextStyle(
                    color: Colors.warningPrimaryColor,
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
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
