import 'package:flutter/material.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/presentation/widgets/castle_text_field/style/shadow_style.dart';
import 'package:pytl_backup/presentation/widgets/castle_text_field/style/text_style.dart';

class CastleTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool searhObj;
  final Function? searchNewObj;
  final Function? backToMainMenu;

  const CastleTextField({
    super.key,
    required this.controller,
    this.hintText = "Найти достопримечательность",
    this.onChanged,
    this.backToMainMenu,
    this.searchNewObj,
    this.searhObj = false,
  });

  @override
  State<CastleTextField> createState() => _CastleTextFieldState();
}

class _CastleTextFieldState extends State<CastleTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _clearText() {
    widget.controller.clear();
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: appWhite,
                boxShadow: [textFieldShadow],
              ),
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                onEditingComplete: () => widget.searchNewObj?.call(),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: textHintStyle,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  prefixIcon: Icon(Icons.castle_outlined, color: appGrey),
                  suffixIcon: widget.controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: appGrey),
                          onPressed: _clearText,
                          splashRadius: 20,
                        )
                      : null,
                ),
                style: textFieldStyle,
                cursorColor: primaryRed,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(left: widget.searhObj ? 20 : 0),
            width: widget.searhObj ? 52 : 0,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: appWhite,
              boxShadow: [textFieldShadow],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: widget.searhObj
                  ? InkWell(
                      onTap: () {
                        _clearText.call();
                        widget.backToMainMenu?.call();
                      },
                      child: Icon(Icons.home_outlined, color: primaryRed),
                    )
                  : const Center(),
            ),
          ),
        ],
      ),
    );
  }
}
