/*
MINI PRODUCT CATALOG — SECTION 4

PART 1 — LIFECYCLE ANSWERS
a) First time a page opens: initState -> didChangeDependencies -> build.
b) Tapping a heart calls setState, so build runs again. initState does not run again.
c) When a page is removed: deactivate runs, then dispose when its State is destroyed.
   Returning to a page that was destroyed creates a new State: initState,
   didChangeDependencies, build.
d) Resizing Chrome changes MediaQuery.sizeOf(context). Since ProductsPage depends
   on MediaQuery, didChangeDependencies runs again and Flutter rebuilds the page.

PART 4 — SHORT ANSWERS
1) context.go changes the current location (Login -> Products below).
   context.push puts a page on top of the current page (Products -> Details below).
2) Login -> Products uses goNamed because we move to the signed-in destination.
   Details uses push because the user returns to Products and receives a result.
3) Query parameter: /products?user=Guest, read from state.uri.queryParameters.
   Path parameters: /details/Laptop/1200, read from state.pathParameters.

The active version is go_router. The complete Navigator version for Part 2 is
kept in the block comment at the bottom of this file. To run that version,
follow its instructions and switch the MaterialApp and login button code.
*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'product_widgets.dart';

final List<Map<String, dynamic>> products = [
  {'name': 'Laptop', 'price': 1200},
  {'name': 'Phone', 'price': 800},
  {'name': 'Headphones', 'price': 150},
  {'name': 'Keyboard', 'price': 90},
  {'name': 'Smart Watch', 'price': 250},
];

// PART 3 — go_router route table.
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/products',
      name: 'products',
      builder: (context, state) => ProductsPage(
        username: state.uri.queryParameters['user'] ?? 'Guest',
      ),
    ),
    GoRoute(
      path: '/details/:name/:price',
      name: 'details',
      builder: (context, state) => DetailsPage(
        name: state.pathParameters['name'] ?? 'Product',
        price: int.tryParse(state.pathParameters['price'] ?? '') ?? 0,
      ),
    ),
  ],
);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Mini Product Catalog',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// LOGIN PAGE — go_router: Login -> Products with a query parameter.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    print('LoginPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('LoginPage: didChangeDependencies');
  }

  @override
  Widget build(BuildContext context) {
    print('LoginPage: build');
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Product Catalog')),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 56),
                const SizedBox(height: 12),
                Text('Welcome', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                FilledButton(
                  // Part 3: goNamed sends Guest as ?user=Guest.
                  onPressed: () => context.goNamed(
                    'products',
                    queryParameters: const {'user': 'Guest'},
                  ),
                  child: const Text('Login'),
                ),
                // Part 2 Navigator alternative is in NavigatorLoginPage below.
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void deactivate() {
    print('LoginPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('LoginPage: dispose');
    super.dispose();
  }
}

// PRODUCTS PAGE — responsive list/grid, favorites, and result from Details.
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key, required this.username});

  final String username;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  int favorites = 0;
  double screenWidth = 0;
  String? cartMessage;

  @override
  void initState() {
    super.initState();
    print('ProductsPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.sizeOf(context);
    screenWidth = size.width;
    print(
      'ProductsPage: didChangeDependencies -> '
      'width: ${size.width}, height: ${size.height}',
    );
  }

  Future<void> _openProduct(int index) async {
    final product = products[index];
    final encodedName = Uri.encodeComponent(product['name'] as String);
    final result = await context.push<String>(
      '/details/$encodedName/${product['price']}',
    );

    if (!mounted || result == null) return;
    setState(() => cartMessage = result);
  }

  @override
  Widget build(BuildContext context) {
    print('ProductsPage: build');
    final useGrid = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Welcome, ${widget.username}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('Favorites: $favorites'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('Screen width: ${screenWidth.toStringAsFixed(0)}'),
          ),
          if (cartMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                cartMessage!,
                style: const TextStyle(color: Colors.green),
              ),
            ),
          Expanded(
            child: useGrid
                ? ProductsGridView(
                    products: products,
                    onFavoritePressed: _addFavorite,
                    onProductTap: _openProduct,
                  )
                : ProductsListView(
                    products: products,
                    onFavoritePressed: _addFavorite,
                    onProductTap: _openProduct,
                  ),
          ),
        ],
      ),
    );
  }

  void _addFavorite() {
    setState(() => favorites++);
  }

  @override
  void deactivate() {
    print('ProductsPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('ProductsPage: dispose');
    super.dispose();
  }
}

// DETAILS PAGE — go_router: pop sends the result to ProductsPage.
class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key, required this.name, required this.price});

  final String name;
  final int price;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  void initState() {
    super.initState();
    print('DetailsPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('DetailsPage: didChangeDependencies');
  }

  @override
  Widget build(BuildContext context) {
    print('DetailsPage: build');
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 72, color: Colors.indigo),
            const SizedBox(height: 12),
            Text(widget.name, style: Theme.of(context).textTheme.headlineMedium),
            Text('\$${widget.price}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.pop('${widget.name} added to cart'),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    print('DetailsPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('DetailsPage: dispose');
    super.dispose();
  }
}

/*
==========================================================================
PART 2 — COMPLETE NAVIGATOR VERSION (COMMENTED OUT)

To try Part 2:
1. Comment out the active GoRouter declaration, main(), and MyApp above.
2. Uncomment the NavigatorRouter, navigatorMain(), NavigatorApp, and the
   three Navigator page classes below.
3. The active MaterialApp must be MaterialApp(routes: NavigatorRouter.routes).

This version uses pushNamed with arguments for Login -> Products, push for
Products -> Details, and pop(result) to return the cart message.
==========================================================================

final class NavigatorRouter {
  static Map<String, WidgetBuilder> get routes => {
    '/': (context) => const NavigatorLoginPage(),
    '/products': (context) {
      final username = ModalRoute.of(context)!.settings.arguments as String;
      return NavigatorProductsPage(username: username);
    },
  };
}

void main() => runApp(const NavigatorApp());

class NavigatorApp extends StatelessWidget {
  const NavigatorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Mini Product Catalog — Navigator',
    routes: NavigatorRouter.routes,
  );
}

class NavigatorLoginPage extends StatefulWidget {
  const NavigatorLoginPage({super.key});

  @override
  State<NavigatorLoginPage> createState() => _NavigatorLoginPageState();
}

class _NavigatorLoginPageState extends State<NavigatorLoginPage> {
  @override
  void initState() { super.initState(); print('NavigatorLoginPage: initState'); }
  @override
  void didChangeDependencies() { super.didChangeDependencies(); print('NavigatorLoginPage: didChangeDependencies'); }
  @override
  Widget build(BuildContext context) {
    print('NavigatorLoginPage: build');
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: FilledButton(
          // Research task: send data with pushNamed using arguments.
          onPressed: () => Navigator.pushNamed(
            context,
            '/products',
            arguments: 'Guest',
          ),
          child: const Text('Login'),
        ),
      ),
    );
  }
  @override
  void deactivate() { print('NavigatorLoginPage: deactivate'); super.deactivate(); }
  @override
  void dispose() { print('NavigatorLoginPage: dispose'); super.dispose(); }
}

class NavigatorProductsPage extends StatefulWidget {
  const NavigatorProductsPage({super.key, required this.username});
  final String username;

  @override
  State<NavigatorProductsPage> createState() => _NavigatorProductsPageState();
}

class _NavigatorProductsPageState extends State<NavigatorProductsPage> {
  int favorites = 0;
  String? cartMessage;

  @override
  void initState() { super.initState(); print('NavigatorProductsPage: initState'); }
  @override
  void didChangeDependencies() { super.didChangeDependencies(); print('NavigatorProductsPage: didChangeDependencies'); }

  Future<void> _openProduct(int index) async {
    final product = products[index];
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => NavigatorDetailsPage(
          name: product['name'] as String,
          price: product['price'] as int,
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => cartMessage = result);
  }

  @override
  Widget build(BuildContext context) {
    print('NavigatorProductsPage: build');
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Column(
        children: [
          Text('Welcome, ${widget.username}'),
          Text('Favorites: $favorites'),
          if (cartMessage != null) Text(cartMessage!),
          Expanded(
            child: ProductsListView(
              products: products,
              onFavoritePressed: () => setState(() => favorites++),
              onProductTap: _openProduct,
            ),
          ),
        ],
      ),
    );
  }
  @override
  void deactivate() { print('NavigatorProductsPage: deactivate'); super.deactivate(); }
  @override
  void dispose() { print('NavigatorProductsPage: dispose'); super.dispose(); }
}

class NavigatorDetailsPage extends StatefulWidget {
  const NavigatorDetailsPage({super.key, required this.name, required this.price});
  final String name;
  final int price;

  @override
  State<NavigatorDetailsPage> createState() => _NavigatorDetailsPageState();
}

class _NavigatorDetailsPageState extends State<NavigatorDetailsPage> {
  @override
  void initState() { super.initState(); print('NavigatorDetailsPage: initState'); }
  @override
  void didChangeDependencies() { super.didChangeDependencies(); print('NavigatorDetailsPage: didChangeDependencies'); }
  @override
  Widget build(BuildContext context) {
    print('NavigatorDetailsPage: build');
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.name),
            Text('\$${widget.price}'),
            FilledButton(
              // Return the result to NavigatorProductsPage's await.
              onPressed: () => Navigator.pop(context, '${widget.name} added to cart'),
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void deactivate() { print('NavigatorDetailsPage: deactivate'); super.deactivate(); }
  @override
  void dispose() { print('NavigatorDetailsPage: dispose'); super.dispose(); }
}
*/
