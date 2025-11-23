import 'material_model.dart';
import 'product_model.dart';

class DatabaseModel {
  List<MaterialModel> materials;
  List<ProductModel> products;
  
  DatabaseModel({
    List<MaterialModel>? materials,
    List<ProductModel>? products,
  }) : materials = materials ?? [],
       products = products ?? [];
  
  Map<String, dynamic> toJson() => {
    'materials': materials.map((m) => m.toJson()).toList(),
    'products': products.map((p) => p.toJson()).toList(),
  };
  
  factory DatabaseModel.fromJson(Map<String, dynamic> json) => DatabaseModel(
    materials: (json['materials'] as List?)
        ?.map((m) => MaterialModel.fromJson(m))
        .toList(),
    products: (json['products'] as List?)
        ?.map((p) => ProductModel.fromJson(p))
        .toList(),
  );
}