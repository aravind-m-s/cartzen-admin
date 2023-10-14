import 'package:cartzen_admin/Core/constants.dart';
import 'package:flutter/cupertino.dart';

class BottomBorderedCard extends StatelessWidget {
  const BottomBorderedCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(defaultRadius * 2),
        ),
        color: themeColor,
      ),
    );
  }
}
