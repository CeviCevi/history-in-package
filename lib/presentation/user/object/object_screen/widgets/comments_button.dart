import 'package:flutter/material.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/presentation/object_screen/style/shadow_style.dart';
import 'package:pytl_backup/presentation/object_screen/style/text_style.dart';

class CommentsButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const CommentsButton({
    super.key,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon(Icons.arrow_forward_ios),
          Icon(Icons.arrow_forward),
          SizedBox(width: 25),
          GestureDetector(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: backgroundColor ?? appWhite,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [blackShadow],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text("Посмотреть отзывы", style: factTextStyle)],
              ),
            ),
          ),
          SizedBox(width: 26),

          // Icon(Icons.arrow_back_ios),
          Icon(Icons.arrow_back),
        ],
      ),
    );
  }
}
