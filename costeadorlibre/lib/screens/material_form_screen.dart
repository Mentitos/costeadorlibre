// lib/screens/material_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/material_model.dart';
import '../models/unit_system.dart';

class MaterialFormScreen extends StatefulWidget {
  final MaterialModel? material;

  const MaterialFormScreen({super.key, this.material});

  @override
  State<MaterialFormScreen> createState() => _MaterialFormScreenState();
}

class _MaterialFormScreenState extends State<MaterialFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _costController;
  late TextEditingController _quantityController;
  late MeasurementUnit _selectedUnit; // :3 Ahora es un enum

  bool get isEditing => widget.material != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.material?.name ?? '');
    _costController = TextEditingController(
      text: widget.material?.purchaseCost.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.material?.purchaseQuantity.toString() ?? '',
    );
    _selectedUnit = widget.material?.unit ?? MeasurementUnit.units;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveMaterial() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<AppProvider>();

      final material = MaterialModel(
        id: widget.material?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        purchaseCost: double.parse(_costController.text),
        purchaseQuantity: double.parse(_quantityController.text),
        unit: _selectedUnit,
      );

      if (isEditing) {
        await provider.updateMaterial(material);
      } else {
        await provider.addMaterial(material);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Insumo actualizado' : 'Insumo creado'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Insumo' : 'Nuevo Insumo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del insumo',
                hintText: 'Ej: Harina 000',
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
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Costo de compra',
                hintText: '1000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el costo';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingrese un número válido';
                }
                return null;
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
                      hintText: '1',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,3}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese cantidad';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Número inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // :3 NUEVO: Dropdown para seleccionar unidad
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<MeasurementUnit>(
                    value: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unidad',
                      border: OutlineInputBorder(),
                    ),
                    items: MeasurementUnit.values.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text('${unit.displayName} (${unit.symbol})'),
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
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ejemplos',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('• Compré 1kg de harina por \$1000'),
                    const Text('  Costo: 1000, Cantidad: 1, Unidad: kg'),
                    const SizedBox(height: 8),
                    const Text('• Compré 40 bolsas por \$2000'),
                    const Text('  Costo: 2000, Cantidad: 40, Unidad: Unidades'),
                    const SizedBox(height: 8),
                    const Text('• Compré 500ml de leche por \$500'),
                    const Text('  Costo: 500, Cantidad: 500, Unidad: ml'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _saveMaterial,
              icon: const Icon(Icons.save),
              label: Text(isEditing ? 'Actualizar' : 'Guardar'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}