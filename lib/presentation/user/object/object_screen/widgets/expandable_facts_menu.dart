import 'package:flutter/material.dart';
import 'package:pytl_backup/data/styles/colors.dart';
import 'package:pytl_backup/domain/services/facts_formatter_service.dart';
import 'package:pytl_backup/presentation/user/object/object_screen/style/shadow_style.dart';
import 'package:pytl_backup/presentation/user/object/object_screen/style/text_style.dart';

class ExpandableFactsMenu extends StatefulWidget {
  final String factsText;
  final Color mainColor;
  final int previewCount;

  const ExpandableFactsMenu({
    super.key,
    required this.factsText,
    this.mainColor = appWhite,
    this.previewCount = 2,
  });

  @override
  State<ExpandableFactsMenu> createState() => _ExpandableFactsMenuState();
}

class _ExpandableFactsMenuState extends State<ExpandableFactsMenu> {
  bool _isExpanded = false;

  List<String> get _facts {
    return FactsFormatterService.parseFacts(widget.factsText);
  }

  List<String> get _previewFacts {
    return FactsFormatterService.getPreviewFacts(
      _facts,
      count: widget.previewCount,
    );
  }

  bool get _shouldShowExpandButton {
    return FactsFormatterService.shouldShowExpandButton(
      _facts,
      threshold: widget.previewCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final facts = _facts;
    final previewFacts = _previewFacts;
    final shouldShowButton = _shouldShowExpandButton;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      child: GestureDetector(
        onTap: () {
          if (shouldShowButton) {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.mainColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [blackShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Интересные факты", style: factTextStyle),
              const SizedBox(height: 12),

              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: _buildCollapsedContent(previewFacts),
                secondChild: _buildExpandedContent(facts),
              ),

              const SizedBox(height: 8),
              if (shouldShowButton)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isExpanded ? "Свернуть" : "Развернуть",
                        style: TextStyle(
                          color: primaryRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: primaryRed,
                        size: 16,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedContent(List<String> facts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: facts.map((fact) => _buildFactItem(fact)).toList(),
    );
  }

  Widget _buildExpandedContent(List<String> facts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: facts.map((fact) => _buildFactItem(fact)).toList(),
    );
  }

  Widget _buildFactItem(String fact) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: factsTextStyle),
          Expanded(child: Text(fact, style: factsTextStyle)),
        ],
      ),
    );
  }
}
