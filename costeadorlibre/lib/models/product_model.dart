class ProductModel {
  final String id;
  String name;
  String description;
  List<ProductIngredient> ingredients;
  
  ProductModel({
    required this.id,
    required this.name,
    this.description = '',
    List<ProductIngredient>? ingredients,
  }) : ingredients = ingredients ?? [];
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'ingredients': ingredients.map((i) => i.toJson()).toList(),
  };
  
  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'],
    name: json['name'],
    description: json['description'] ?? '',
    ingredients: (json['ingredients'] as List?)
        ?.map((i) => ProductIngredient.fromJson(i))
        .toList(),
  );
  
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    List<ProductIngredient>? ingredients,
  }) => ProductModel(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    ingredients: ingredients ?? this.ingredients,
  );
}