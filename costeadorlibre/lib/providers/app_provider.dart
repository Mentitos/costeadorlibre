// lib/providers/app_provider.dart

import 'package:flutter/foundation.dart';
import '../models/material_model.dart';
import '../models/product_model.dart';
import '../models/database_model.dart';
import '../services/data_service.dart';

class AppProvider with ChangeNotifier {
  final DataService _dataService = DataService();
  
  List<MaterialModel> _materials = [];
  List<ProductModel> _products = [];
  bool _isLoading = false;
  
  List<MaterialModel> get materials => _materials;
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  
  // Inicializar y cargar datos
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final database = await _dataService.loadData();
      _materials = database.materials;
      _products = database.products;
    } catch (e) {
      print('Error initializing: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Guardar todos los datos
  Future<void> _saveData() async {
    final database = DatabaseModel(
      materials: _materials,
      products: _products,
    );
    await _dataService.saveData(database);
  }
  
  // ========== MATERIALES ==========
  
  Future<void> addMaterial(MaterialModel material) async {
    _materials.add(material);
    notifyListeners();
    await _saveData();
  }
  
  Future<void> updateMaterial(MaterialModel material) async {
    final index = _materials.indexWhere((m) => m.id == material.id);
    if (index != -1) {
      _materials[index] = material;
      notifyListeners();
      await _saveData();
    }
  }
  
  Future<void> deleteMaterial(String id) async {
    _materials.removeWhere((m) => m.id == id);
    
    // Eliminar referencias en productos
    for (var product in _products) {
      product.ingredients.removeWhere((i) => i.materialId == id);
    }
    
    notifyListeners();
    await _saveData();
  }
  
  MaterialModel? getMaterialById(String id) {
    try {
      return _materials.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // ========== PRODUCTOS ==========
  
  Future<void> addProduct(ProductModel product) async {
    _products.add(product);
    notifyListeners();
    await _saveData();
  }
  
  Future<void> updateProduct(ProductModel product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
      await _saveData();
    }
  }
  
  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
    await _saveData();
  }
  
  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // ========== CÁLCULOS ==========
  
  double calculateIngredientCost(String materialId, double quantityUsed) {
    final material = getMaterialById(materialId);
    if (material == null) return 0.0;
    return _dataService.calculateIngredientCost(material, quantityUsed);
  }
  
  double calculateProductCost(ProductModel product) {
    return _dataService.calculateProductCost(product, _materials);
  }
  
  // ========== IMPORT/EXPORT ==========
  
  Future<String?> exportDatabase() async {
    final database = DatabaseModel(
      materials: _materials,
      products: _products,
    );
    return await _dataService.exportDatabase(database);
  }
  
  Future<bool> importDatabase() async {
    try {
      final database = await _dataService.importDatabase();
      if (database != null) {
        _materials = database.materials;
        _products = database.products;
        notifyListeners();
        await _saveData();
        return true;
      }
      return false;
    } catch (e) {
      print('Error importing: $e');
      return false;
    }
  }
}