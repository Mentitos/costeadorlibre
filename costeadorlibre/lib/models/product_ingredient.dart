class ProductIngredient {
  final String materialId;
  double quantityUsed;  // Cantidad usada en el producto
  
  ProductIngredient({
    required this.materialId,
    required this.quantityUsed,
  });
  
  Map<String, dynamic> toJson() => {
    'materialId': materialId,
    'quantityUsed': quantityUsed,
  };
  
  factory ProductIngredient.fromJson(Map<String, dynamic> json) => ProductIngredient(
    materialId: json['materialId'],
    quantityUsed: (json['quantityUsed'] as num).toDouble(),
  );
}