import 'package:flutter/material.dart';
import 'package:fluttercon2026/_utils/colors.dart';

class GrayscaleAvatar extends StatelessWidget {
  const GrayscaleAvatar({super.key, required this.url, this.size = 24});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(100)),
        child: Icon(Icons.person, size: size * 0.6, color: AppColors.mutedForeground),
      );
    }

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            width: size,
            height: size,
            color: AppColors.secondary,
            child: Icon(Icons.person, size: size * 0.6, color: AppColors.mutedForeground),
          ),
        ),
      ),
    );
  }
}
