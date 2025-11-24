// lib/models/material_model.dart

import 'unit_system.dart';

class MaterialModel {
  final String id;
  String name;
  double purchaseCost;
  double purchaseQuantity;
  MeasurementUnit unit;

  MaterialModel({
    required this.id,
    required this.name,
    required this.purchaseCost,
    required this.purchaseQuantity,
    required this.unit,
  });

  double get costPerBaseUnit {
    final quantityInBase = unit.toBaseUnit(purchaseQuantity);
    return purchaseCost / quantityInBase;
  }

  double get costPerPurchaseUnit => purchaseCost / purchaseQuantity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'purchaseCost': purchaseCost,
        'purchaseQuantity': purchaseQuantity,
        'unit': unit.symbol,
      };

  factory MaterialModel.fromJson(Map<String, dynamic> json) => MaterialModel(
        id: json['id'],
        name: json['name'],
        purchaseCost: (json['purchaseCost'] as num).toDouble(),
        purchaseQuantity: (json['purchaseQuantity'] as num).toDouble(),
        unit: MeasurementUnit.fromString(json['unit'] ?? 'u'),
      );

  MaterialModel copyWith({
    String? id,
    String? name,
    double? purchaseCost,
    double? purchaseQuantity,
    MeasurementUnit? unit,
  }) =>
      MaterialModel(
        id: id ?? this.id,
        name: name ?? this.name,
        purchaseCost: purchaseCost ?? this.purchaseCost,
        purchaseQuantity: purchaseQuantity ?? this.purchaseQuantity,
        unit: unit ?? this.unit,
      );
}