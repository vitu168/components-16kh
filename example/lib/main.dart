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
      title: 'Dynamic Multi Dropdown Select Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  late ExSelectController<String> _staticController;
  late ExSelectController<User> _asyncController;
  late ExSelectController<String> _searchController;

  @override
  void initState() {
    super.initState();

    // Static list controller
    _staticController = ExSelectController<String>(
      initialItems: [
        'Option 1',
        'Option 2',
        'Option 3',
        'Option 4',
        'Option 5',
      ],
      enableMultiSelect: true,
    );

    // Async data controller
    _asyncController = ExSelectController<User>(
      enableMultiSelect: true,
      enableAsync: true,
      fetchDataFn: _fetchUsers,
      itemToStringFn: (user) => user.name,
      getItemIdFn: (user) => user.id,
    );

    // Search-enabled controller
    _searchController = ExSelectController<String>(
      initialItems: List.generate(50, (index) => 'Item ${index + 1}'),
      enableMultiSelect: true,
      enableSearch: true,
    );
  }

  @override
  void dispose() {
    _staticController.dispose();
    _asyncController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Simulate async API call
  Future<List<User>> _fetchUsers(String? query) async {
    await Future.delayed(const Duration(seconds: 1));

    final users = List.generate(
      20,
      (index) => User(
        id: index + 1,
        name: 'User ${index + 1}',
        email: 'user${index + 1}@example.com',
      ),
    );

    if (query != null && query.isNotEmpty) {
      return users
          .where((user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Dynamic Multi Dropdown Select'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Static list
            Text(
              'Example 1: Static List',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            DynamicMultiDropdownSelect<String>(
              controller: _staticController,
              label: 'Select Options',
              isRequired: true,
              placeholder: 'Choose multiple options...',
              itemBuilder: (context, item) => Text(item),
              onChanged: (values) {
                debugPrint('Selected: $values');
              },
            ),
            const SizedBox(height: 32),

            // Example 2: With search
            Text(
              'Example 2: With Search (50 items)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            DynamicMultiDropdownSelect<String>(
              controller: _searchController,
              label: 'Search and Select',
              placeholder: 'Search items...',
              itemBuilder: (context, item) => Text(item),
              searchPlaceholder: 'Type to search...',
              borderColor: Colors.grey.shade300,
              focusedBorderColor: Colors.blue,
              errorBorderColor: Colors.red,
            ),
            const SizedBox(height: 32),

            // Example 3: Async data loading
            Text(
              'Example 3: Async Data Loading',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            DynamicMultiDropdownSelect<User>(
              controller: _asyncController,
              label: 'Select Users',
              isRequired: true,
              placeholder: 'Select users...',
              itemBuilder: (context, user) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              getItemId: (user) => user.id,
              loadingText: 'Loading users...',
              emptyText: 'No users found',
            ),
            const SizedBox(height: 32),

            // Display selected values
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Selected Values'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Static: ${_staticController.selectedValues}'),
                        const SizedBox(height: 8),
                        Text('Search: ${_searchController.selectedValues}'),
                        const SizedBox(height: 8),
                        Text(
                          'Async: ${_asyncController.selectedValues.map((u) => u.name).toList()}',
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Show Selected Values'),
            ),
          ],
        ),
      ),
    );
  }
}

// Model class for async example
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  @override
  String toString() => name;
}
