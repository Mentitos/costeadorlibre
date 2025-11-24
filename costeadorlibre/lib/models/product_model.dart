// lib/models/product_model.dart

import 'product_ingredient.dart';
import 'unit_system.dart';

class ProductModel {
  final String id;
  String name;
  String description;
  List<ProductIngredient> ingredients;
  double yieldQuantity;
  MeasurementUnit yieldUnit;

  ProductModel({
    required this.id,
    required this.name,
    this.description = '',
    List<ProductIngredient>? ingredients,
    required this.yieldQuantity,
    required this.yieldUnit,
  }) : ingredients = ingredients ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'yieldQuantity': yieldQuantity,
        'yieldUnit': yieldUnit.symbol,
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'],
        name: json['name'],
        description: json['description'] ?? '',
        ingredients: (json['ingredients'] as List?)
            ?.map((i) => ProductIngredient.fromJson(i))
            .toList(),
        yieldQuantity: (json['yieldQuantity'] as num?)?.toDouble() ?? 1,
        yieldUnit: MeasurementUnit.fromString(json['yieldUnit'] ?? 'u'),
      );

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    List<ProductIngredient>? ingredients,
    double? yieldQuantity,
    MeasurementUnit? yieldUnit,
  }) =>
      ProductModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        ingredients: ingredients ?? this.ingredients,
        yieldQuantity: yieldQuantity ?? this.yieldQuantity,
        yieldUnit: yieldUnit ?? this.yieldUnit,
      );
}