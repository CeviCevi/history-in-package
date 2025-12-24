import 'package:flutter/material.dart';
import 'package:pytl_backup/presentation/start_screen/styles/text_style/text_style.dart';

class RestartButton extends StatelessWidget {
  final GestureTapCallback? function;

  const RestartButton({super.key, this.function});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: function,
          borderRadius: BorderRadius.circular(25),
          focusColor: Colors.green,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Text("Попробовать снова", style: restartButton),
          ),
        ),
      ),
    );
  }
}
