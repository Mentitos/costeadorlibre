// lib/models/product_ingredient.dart

import 'unit_system.dart';

class ProductIngredient {
  final String materialId;
  double quantityUsed;
  MeasurementUnit usedUnit;

  ProductIngredient({
    required this.materialId,
    required this.quantityUsed,
    required this.usedUnit,
  });

  Map<String, dynamic> toJson() => {
        'materialId': materialId,
        'quantityUsed': quantityUsed,
        'usedUnit': usedUnit.symbol,
      };

  factory ProductIngredient.fromJson(Map<String, dynamic> json) =>
      ProductIngredient(
        materialId: json['materialId'],
        quantityUsed: (json['quantityUsed'] as num).toDouble(),
        usedUnit: MeasurementUnit.fromString(json['usedUnit'] ?? 'u'),
      );
}