import 'package:flutter/material.dart';

class ProductsListView extends StatelessWidget {
  const ProductsListView({
    super.key,
    required this.products,
    required this.onFavoritePressed,
    required this.onProductTap,
  });

  final List<Map<String, dynamic>> products;
  final VoidCallback onFavoritePressed;
  final ValueChanged<int> onProductTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) => ProductTile(
        name: products[index]['name'] as String,
        price: products[index]['price'] as int,
        onFavoritePressed: onFavoritePressed,
        onTap: () => onProductTap(index),
      ),
    );
  }
}

class ProductsGridView extends StatelessWidget {
  const ProductsGridView({
    super.key,
    required this.products,
    required this.onFavoritePressed,
    required this.onProductTap,
  });

  final List<Map<String, dynamic>> products;
  final VoidCallback onFavoritePressed;
  final ValueChanged<int> onProductTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.6,
      ),
      itemBuilder: (context, index) => ProductTile(
        name: products[index]['name'] as String,
        price: products[index]['price'] as int,
        onFavoritePressed: onFavoritePressed,
        onTap: () => onProductTap(index),
      ),
    );
  }
}

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.name,
    required this.price,
    required this.onFavoritePressed,
    required this.onTap,
  });

  final String name;
  final int price;
  final VoidCallback onFavoritePressed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(6),
      child: ListTile(
        title: Text(name),
        subtitle: Text('\$$price'),
        trailing: IconButton(
          tooltip: 'Add to favorites',
          icon: const Icon(Icons.favorite),
          color: Colors.red,
          onPressed: onFavoritePressed,
        ),
        onTap: onTap,
      ),
    );
  }
}