import 'package:flutter/painting.dart';

class ColoringCategory {
  const ColoringCategory({
    required this.id,
    required this.title,
    required this.color,
    required this.coverTemplateId,
    required this.templateIds,
  });

  final String id;
  final String title;

  /// Soft background tint for the category card.
  final Color color;
  final String coverTemplateId;
  final List<String> templateIds;
}
