import 'package:flutter/material.dart';
import 'package:pytl_backup/data/styles/colors.dart';

class ActionsMenu extends StatelessWidget {
  final VoidCallback? onRoutePressed;
  final VoidCallback? onSavePressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onQuizPressed;
  final bool isSaved;
  final Color mainColor;

  const ActionsMenu({
    super.key,
    this.onRoutePressed,
    this.onSavePressed,
    this.onSharePressed,
    this.onQuizPressed,
    this.isSaved = false,
    this.mainColor = primaryRed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.1).toInt()),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionButton(
              icon: Icons.route,
              text: "проложить\nмаршрут",
              onPressed: onRoutePressed,
            ),
            _buildActionButton(
              icon: isSaved
                  ? Icons.bookmark_added
                  : Icons.bookmark_add_outlined,
              text: isSaved ? "сохранено" : "сохранить",
              onPressed: onSavePressed,
            ),
            _buildActionButton(
              icon: Icons.share,
              text: "поделиться",
              onPressed: onSharePressed,
            ),
            _buildActionButton(
              icon: Icons.vrpano_outlined,
              text: "AR",
              onPressed: onQuizPressed,
              isActive: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
    bool isActive = true,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isActive ? mainColor : Colors.grey[700],
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? primaryRed : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
