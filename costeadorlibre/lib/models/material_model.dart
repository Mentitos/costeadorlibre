class MaterialModel {
  final String id;
  String name;
  double purchaseCost;      // Costo de compra
  double purchaseQuantity;  // Cantidad comprada
  String unit;              // Unidad de medida (kg, L, unidades, etc.)
  
  MaterialModel({
    required this.id,
    required this.name,
    required this.purchaseCost,
    required this.purchaseQuantity,
    required this.unit,
  });
  
  // Calcula el costo por unidad base
  double get costPerUnit => purchaseCost / purchaseQuantity;
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'purchaseCost': purchaseCost,
    'purchaseQuantity': purchaseQuantity,
    'unit': unit,
  };
  
  factory MaterialModel.fromJson(Map<String, dynamic> json) => MaterialModel(
    id: json['id'],
    name: json['name'],
    purchaseCost: (json['purchaseCost'] as num).toDouble(),
    purchaseQuantity: (json['purchaseQuantity'] as num).toDouble(),
    unit: json['unit'],
  );
  
  MaterialModel copyWith({
    String? id,
    String? name,
    double? purchaseCost,
    double? purchaseQuantity,
    String? unit,
  }) => MaterialModel(
    id: id ?? this.id,
    name: name ?? this.name,
    purchaseCost: purchaseCost ?? this.purchaseCost,
    purchaseQuantity: purchaseQuantity ?? this.purchaseQuantity,
    unit: unit ?? this.unit,
  );
}