import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/product_model.dart';
import '../models/product_ingredient.dart';
import '../models/unit_system.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _yieldQuantityController; // :3 NUEVO
  late List<ProductIngredient> _ingredients;
  late MeasurementUnit _yieldUnit; // :3 NUEVO

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _yieldQuantityController = TextEditingController(
      text: widget.product?.yieldQuantity.toString() ?? '',
    );
    _yieldUnit = widget.product?.yieldUnit ?? MeasurementUnit.units;
    _ingredients = widget.product?.ingredients
            .map((i) => ProductIngredient(
                  materialId: i.materialId,
                  quantityUsed: i.quantityUsed,
                  usedUnit: i.usedUnit,
                ))
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _yieldQuantityController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final provider = context.read<AppProvider>();
    if (provider.materials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe crear al menos un insumo primero'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _IngredientDialog(
        materials: provider.materials,
        onAdd: (ingredient) {
          setState(() {
            _ingredients.add(ingredient);
          });
        },
      ),
    );
  }

  void _editIngredient(int index) {
    final provider = context.read<AppProvider>();
    showDialog(
      context: context,
      builder: (context) => _IngredientDialog(
        materials: provider.materials,
        ingredient: _ingredients[index],
        onAdd: (ingredient) {
          setState(() {
            _ingredients[index] = ingredient;
          });
        },
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      if (_ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agregue al menos un ingrediente'),
          ),
        );
        return;
      }

      final provider = context.read<AppProvider>();

      final product = ProductModel(
        id: widget.product?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        ingredients: _ingredients,
        yieldQuantity: double.parse(_yieldQuantityController.text),
        yieldUnit: _yieldUnit,
      );

      if (isEditing) {
        await provider.updateProduct(product);
      } else {
        await provider.addProduct(product);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(isEditing ? 'Producto actualizado' : 'Producto creado'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del producto',
                      hintText: 'Ej: Pan de campo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingrese el nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      hintText: 'Descripción del producto',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // :3 NUEVO: Campo de Rendimiento
                  Card(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.production_quantity_limits,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '¿Cuánto rinde esta receta?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _yieldQuantityController,
                                  decoration: const InputDecoration(
                                    labelText: 'Cantidad',
                                    hintText: '12',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Requerido';
                                    }
                                    final num = double.tryParse(value);
                                    if (num == null || num <= 0) {
                                      return 'Debe ser mayor a 0';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<MeasurementUnit>(
                                  value: _yieldUnit,
                                  decoration: const InputDecoration(
                                    labelText: 'Unidad',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(),
                                  ),
                                  items: MeasurementUnit.values.map((unit) {
                                    return DropdownMenuItem(
                                      value: unit,
                                      child: Text(unit.symbol),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _yieldUnit = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ej: 12 galletas, 500 gr de masa, 2 L de helado',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ingredientes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      FilledButton.icon(
                        onPressed: _addIngredient,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_ingredients.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No hay ingredientes agregados',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_ingredients.length, (index) {
                      final ingredient = _ingredients[index];
                      final material = context
                          .read<AppProvider>()
                          .getMaterialById(ingredient.materialId);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.inventory_2),
                          ),
                          title: Text(material?.name ?? 'Desconocido'),
                          subtitle: Text(
                            '${ingredient.quantityUsed} ${ingredient.usedUnit.symbol}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editIngredient(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _ingredients.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: FilledButton.icon(
                  onPressed: _saveProduct,
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? 'Actualizar' : 'Guardar'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// :3 Diálogo para agregar/editar ingredientes con selector de unidad
class _IngredientDialog extends StatefulWidget {
  final List materials;
  final ProductIngredient? ingredient;
  final Function(ProductIngredient) onAdd;

  const _IngredientDialog({
    required this.materials,
    required this.onAdd,
    this.ingredient,
  });

  @override
  State<_IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<_IngredientDialog> {
  late String _selectedMaterialId;
  final _quantityController = TextEditingController();
  late MeasurementUnit _selectedUnit;

  @override
  void initState() {
    super.initState();
    _selectedMaterialId =
        widget.ingredient?.materialId ?? widget.materials.first.id;
    _quantityController.text =
        widget.ingredient?.quantityUsed.toString() ?? '';
    _selectedUnit =
        widget.ingredient?.usedUnit ?? widget.materials.first.unit;
  }

  @override
  Widget build(BuildContext context) {
    final selectedMaterial = widget.materials.firstWhere(
      (m) => m.id == _selectedMaterialId,
    );

    // :3 Filtrar unidades compatibles con el tipo del material
    final compatibleUnits = MeasurementUnit.values
        .where((unit) => unit.type == selectedMaterial.unit.type)
        .toList();

    return AlertDialog(
      title: Text(widget.ingredient == null
          ? 'Agregar Ingrediente'
          : 'Editar Ingrediente'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedMaterialId,
              decoration: const InputDecoration(
                labelText: 'Insumo',
                border: OutlineInputBorder(),
              ),
              items: widget.materials.map<DropdownMenuItem<String>>((material) {
                return DropdownMenuItem<String>(
                  value: material.id,
                  child: Text(material.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMaterialId = value!;
                  // Actualizar unidad compatible
                  final newMaterial = widget.materials.firstWhere((m) => m.id == value);
                  _selectedUnit = newMaterial.unit;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,3}')),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<MeasurementUnit>(
                    value: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unidad',
                      border: OutlineInputBorder(),
                    ),
                    items: compatibleUnits.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit.symbol),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUnit = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Material comprado en: ${selectedMaterial.unit.displayName} (${selectedMaterial.unit.symbol})',
                style: TextStyle(fontSize: 12, color: Colors.blue[900]),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_quantityController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ingrese la cantidad')),
              );
              return;
            }

            final ingredient = ProductIngredient(
              materialId: _selectedMaterialId,
              quantityUsed: double.parse(_quantityController.text),
              usedUnit: _selectedUnit,
            );

            widget.onAdd(ingredient);
            Navigator.pop(context);
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}