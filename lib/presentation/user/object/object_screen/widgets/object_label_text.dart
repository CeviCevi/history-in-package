import 'package:flutter/material.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/presentation/object_screen/style/text_style.dart';

class ObjectLabelText extends StatelessWidget {
  final String label;
  final String address;

  const ObjectLabelText({
    super.key,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      height: 80,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0, 2],
          colors: [
            Colors.black.withAlpha((255 * 1).toInt()),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelTextStyle, overflow: TextOverflow.ellipsis),
          Text(
            address,
            style: labelTextStyle.copyWith(
              fontSize: 15,
              color: appWhite.withAlpha(200),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
