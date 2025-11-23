// lib/services/data_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/material_model.dart';
import '../models/product_model.dart';
import '../models/database_model.dart';

class DataService {
  static const String _fileName = 'costeador_data.json';
  
  // Obtener el archivo local
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
  
  // Cargar datos desde archivo
  Future<DatabaseModel> loadData() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final json = jsonDecode(contents);
        return DatabaseModel.fromJson(json);
      }
    } catch (e) {
      print('Error loading data: $e');
    }
    return DatabaseModel();
  }
  
  // Guardar datos en archivo
  Future<void> saveData(DatabaseModel database) async {
    try {
      final file = await _getLocalFile();
      final json = jsonEncode(database.toJson());
      await file.writeAsString(json);
    } catch (e) {
      print('Error saving data: $e');
      rethrow;
    }
  }
  
  // Exportar base de datos
  Future<String?> exportDatabase(DatabaseModel database) async {
    try {
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar base de datos',
        fileName: 'costeador_backup_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (outputPath != null) {
        final file = File(outputPath);
        final json = jsonEncode(database.toJson());
        await file.writeAsString(json);
        return outputPath;
      }
    } catch (e) {
      print('Error exporting database: $e');
      rethrow;
    }
    return null;
  }
  
  // Importar base de datos
  Future<DatabaseModel?> importDatabase() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Seleccionar archivo de base de datos',
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final contents = await file.readAsString();
        final json = jsonDecode(contents);
        return DatabaseModel.fromJson(json);
      }
    } catch (e) {
      print('Error importing database: $e');
      rethrow;
    }
    return null;
  }
  
  // Calcular costo de un ingrediente específico
  double calculateIngredientCost(
    MaterialModel material, 
    double quantityUsed
  ) {
    // Regla de tres simple: (Precio / Cantidad Compra) * Cantidad Uso
    return (material.purchaseCost / material.purchaseQuantity) * quantityUsed;
  }
  
  // Calcular costo total de un producto
  double calculateProductCost(
    ProductModel product,
    List<MaterialModel> allMaterials,
  ) {
    double totalCost = 0.0;
    
    for (var ingredient in product.ingredients) {
      final material = allMaterials.firstWhere(
        (m) => m.id == ingredient.materialId,
        orElse: () => MaterialModel(
          id: '',
          name: 'Desconocido',
          purchaseCost: 0,
          purchaseQuantity: 1,
          unit: '',
        ),
      );
      
      if (material.id.isNotEmpty) {
        totalCost += calculateIngredientCost(material, ingredient.quantityUsed);
      }
    }
    
    return totalCost;
  }
}