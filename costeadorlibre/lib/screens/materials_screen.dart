// lib/screens/materials_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/material_model.dart';
import 'material_form_screen.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  bool _isGridView = false; // :3 Estado para alternar entre lista y grid

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insumos'),
        centerTitle: true,
        actions: [
          // :3 Botón para alternar vista
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: _isGridView ? 'Vista de Lista' : 'Vista de Cuadrícula',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.materials.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay insumos registrados',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Presiona + para agregar uno',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          // :3 Alternar entre GridView y ListView
          return _isGridView
              ? _buildGridView(provider, currencyFormat)
              : _buildListView(provider, currencyFormat);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MaterialFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Insumo'),
      ),
    );
  }

  // :3 Vista de Lista (original)
  Widget _buildListView(AppProvider provider, NumberFormat currencyFormat) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.materials.length,
      itemBuilder: (context, index) {
        final material = provider.materials[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.inventory_2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              material.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                    'Compra: ${currencyFormat.format(material.purchaseCost)} por ${material.purchaseQuantity} ${material.unit.symbol}'),
                const SizedBox(height: 4),
                Text(
                  'Costo: ${currencyFormat.format(material.costPerPurchaseUnit)}/${material.unit.symbol}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: _buildPopupMenu(material),
          ),
        );
      },
    );
  }

  // :3 NUEVO: Vista de Cuadrícula con diseño responsivo
  Widget _buildGridView(AppProvider provider, NumberFormat currencyFormat) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200, // :3 Ancho máximo por tarjeta
        childAspectRatio: 0.8, // Proporción altura/ancho
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: provider.materials.length,
      itemBuilder: (context, index) {
        final material = provider.materials[index];
        return _buildMaterialCard(material, currencyFormat);
      },
    );
  }

  // :3 Tarjeta bonita para vista Grid
  Widget _buildMaterialCard(MaterialModel material, NumberFormat currencyFormat) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MaterialFormScreen(material: material),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono y menú
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.inventory_2,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  _buildPopupMenu(material),
                ],
              ),
              const Spacer(),
              // Nombre del insumo
              Text(
                material.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Precio destacado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  currencyFormat.format(material.costPerPurchaseUnit),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Unidad
              Text(
                'por ${material.unit.symbol}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              // Info de compra
              Text(
                '${material.purchaseQuantity} ${material.unit.symbol} × ${currencyFormat.format(material.purchaseCost)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // :3 Menú popup reutilizable
  Widget _buildPopupMenu(MaterialModel material) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit),
              SizedBox(width: 8),
              Text('Editar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Eliminar', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        if (value == 'edit') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MaterialFormScreen(material: material),
            ),
          );
        } else if (value == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirmar eliminación'),
              content: Text('¿Eliminar "${material.name}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          );
          if (confirm == true && mounted) {
            await context.read<AppProvider>().deleteMaterial(material.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Insumo eliminado')),
              );
            }
          }
        }
      },
    );
  }
}