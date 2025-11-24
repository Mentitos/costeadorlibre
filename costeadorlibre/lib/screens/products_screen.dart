// lib/screens/products_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import 'product_form_screen.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool _isGridView = false; // :3 Estado para alternar entre lista y grid

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
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
          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay productos registrados',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Presiona + para crear uno',
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
              builder: (_) => const ProductFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Producto'),
      ),
    );
  }

  // :3 Vista de Lista (original mejorada)
  Widget _buildListView(AppProvider provider, NumberFormat currencyFormat) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        final product = provider.products[index];
        final totalCost = provider.calculateProductCost(product);
        final unitCost = provider.calculateUnitCost(product);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: product),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondaryContainer,
                        child: Icon(
                          Icons.shopping_bag,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (product.description.isNotEmpty)
                              Text(
                                product.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                      _buildPopupMenu(product, provider),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Rinde: ${product.yieldQuantity} ${product.yieldUnit.symbol}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Costo total:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(
                              currencyFormat.format(totalCost),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Costo unitario:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(
                              '${currencyFormat.format(unitCost)}/${product.yieldUnit.symbol}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.ingredients.length} ingredientes',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
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
        maxCrossAxisExtent: 220, // :3 Ancho máximo por tarjeta
        childAspectRatio: 0.75, // Proporción altura/ancho
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        final product = provider.products[index];
        final totalCost = provider.calculateProductCost(product);
        final unitCost = provider.calculateUnitCost(product);
        return _buildProductCard(
            product, totalCost, unitCost, currencyFormat, provider);
      },
    );
  }

  // :3 Tarjeta bonita para vista Grid
  Widget _buildProductCard(
    product,
    double totalCost,
    double unitCost,
    NumberFormat currencyFormat,
    AppProvider provider,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
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
                        Theme.of(context).colorScheme.secondaryContainer,
                    child: Icon(
                      Icons.shopping_bag,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                  ),
                  _buildPopupMenu(product, provider),
                ],
              ),
              const SizedBox(height: 8),
              // Nombre del producto
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (product.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              // Rendimiento
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Rinde: ${product.yieldQuantity} ${product.yieldUnit.symbol}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Costo unitario destacado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COSTO UNITARIO',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currencyFormat.format(unitCost),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'por ${product.yieldUnit.symbol}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Costo total y ingredientes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${currencyFormat.format(totalCost)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${product.ingredients.length} ing.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // :3 Menú popup reutilizable
  Widget _buildPopupMenu(product, AppProvider provider) {
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
              builder: (_) => ProductFormScreen(product: product),
            ),
          );
        } else if (value == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirmar eliminación'),
              content: Text('¿Eliminar "${product.name}"?'),
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
            await provider.deleteProduct(product.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Producto eliminado')),
              );
            }
          }
        }
      },
    );
  }
}