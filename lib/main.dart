import 'package:flutter/material.dart';
import 'package:sdkcomponents16/sdkcomponents16.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SDK Components Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  late ExSelectController<String> _fruitsController;
  late ExSelectController<Product> _productsController;
  late ExSelectController<String> _countriesController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Controller 1: Simple fruit selection
    _fruitsController = ExSelectController<String>(
      initialItems: [
        'Apple',
        'Banana',
        'Orange',
        'Strawberry',
        'Mango',
        'Pineapple',
        'Watermelon',
        'Grapes',
      ],
      enableMultiSelect: true,
      enableSearch: true,
    );

    // Controller 2: Products with async loading
    _productsController = ExSelectController<Product>(
      enableMultiSelect: true,
      enableAsync: true,
      enableSearch: true,
      fetchDataFn: _fetchProducts,
      itemToStringFn: (product) => product.name,
      getItemIdFn: (product) => product.id,
    );

    // Controller 3: Countries with large dataset
    _countriesController = ExSelectController<String>(
      initialItems: _generateCountries(),
      enableMultiSelect: true,
      enableSearch: true,
    );
  }

  @override
  void dispose() {
    _fruitsController.dispose();
    _productsController.dispose();
    _countriesController.dispose();
    super.dispose();
  }

  Future<List<Product>> _fetchProducts(String? query) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    final allProducts = [
      Product(1, 'Laptop', 999.99, 'Electronics'),
      Product(2, 'Mouse', 29.99, 'Electronics'),
      Product(3, 'Keyboard', 79.99, 'Electronics'),
      Product(4, 'Monitor', 299.99, 'Electronics'),
      Product(5, 'Desk Chair', 199.99, 'Furniture'),
      Product(6, 'Desk', 349.99, 'Furniture'),
      Product(7, 'Headphones', 149.99, 'Electronics'),
      Product(8, 'Webcam', 89.99, 'Electronics'),
      Product(9, 'USB Cable', 9.99, 'Accessories'),
      Product(10, 'Mouse Pad', 19.99, 'Accessories'),
    ];

    if (query != null && query.isNotEmpty) {
      return allProducts
          .where((p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    return allProducts;
  }

  List<String> _generateCountries() {
    return [
      'United States',
      'Canada',
      'United Kingdom',
      'Germany',
      'France',
      'Italy',
      'Spain',
      'Australia',
      'Japan',
      'China',
      'India',
      'Brazil',
      'Mexico',
      'Russia',
      'South Korea',
      'Netherlands',
      'Sweden',
      'Norway',
      'Denmark',
      'Finland',
    ];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Form Submitted'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Fruits:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(_fruitsController.selectedValues.join(', ')),
                const SizedBox(height: 12),
                const Text(
                  'Selected Products:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _productsController.selectedValues
                      .map((p) => p.name)
                      .join(', '),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Selected Countries:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(_countriesController.selectedValues.join(', ')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('SDK Components Demo'),
        elevation: 2,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Header
            Text(
              'Dynamic Multi Dropdown Select',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select multiple items with search and async support',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 32),

            // Example 1: Fruits
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.apple, color: Colors.red.shade400),
                        const SizedBox(width: 8),
                        Text(
                          'Select Your Favorite Fruits',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DynamicMultiDropdownSelect<String>(
                      controller: _fruitsController,
                      label: 'Fruits',
                      isRequired: true,
                      placeholder: 'Choose fruits...',
                      itemBuilder: (context, item) => Text(item),
                      searchPlaceholder: 'Search fruits...',
                      borderRadius: BorderRadius.circular(12),
                      focusedBorderColor: Colors.green,
                      onChanged: (values) {
                        debugPrint('Selected fruits: $values');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Example 2: Products (Async)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_cart, color: Colors.blue.shade400),
                        const SizedBox(width: 8),
                        Text(
                          'Select Products (Async Loading)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DynamicMultiDropdownSelect<Product>(
                      controller: _productsController,
                      label: 'Products',
                      placeholder: 'Search and select products...',
                      itemBuilder: (context, product) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Row(
                              children: [
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  product.category,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      getItemId: (product) => product.id,
                      searchPlaceholder: 'Search products or categories...',
                      loadingText: 'Loading products...',
                      emptyText: 'No products found',
                      borderRadius: BorderRadius.circular(12),
                      focusedBorderColor: Colors.blue,
                      maxHeight: 350,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Example 3: Countries
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.public, color: Colors.purple.shade400),
                        const SizedBox(width: 8),
                        Text(
                          'Select Countries',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DynamicMultiDropdownSelect<String>(
                      controller: _countriesController,
                      label: 'Countries',
                      placeholder: 'Select countries...',
                      itemBuilder: (context, item) => Text(item),
                      searchPlaceholder: 'Search countries...',
                      borderRadius: BorderRadius.circular(12),
                      focusedBorderColor: Colors.purple,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit Form',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // Reset Button
            OutlinedButton(
              onPressed: () {
                _fruitsController.clearSelection();
                _productsController.clearSelection();
                _countriesController.clearSelection();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Clear All Selections',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Product model for async example
class Product {
  final int id;
  final String name;
  final double price;
  final String category;

  Product(this.id, this.name, this.price, this.category);

  @override
  String toString() => name;
}