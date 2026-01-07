# sdkcomponents16

A Flutter package providing a dynamic multi-select dropdown component with advanced features including search, async data loading, caching, and form validation support.

## Features

✨ **Multi-select support** - Select multiple items with checkboxes  
🔍 **Search functionality** - Filter items with built-in search  
⚡ **Async data loading** - Load data from APIs with caching  
🎨 **Customizable styling** - Custom borders, colors, and themes  
✅ **Form validation** - Built-in FormField support with validation  
🔄 **State management** - Reactive controller-based architecture  
🎯 **Item ID tracking** - Preserve selections across data refetches  

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  sdkcomponents16: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Static List

```dart
import 'package:sdkcomponents16/sdkcomponents16.dart';

// Create a controller
final controller = ExSelectController<String>(
  initialItems: ['Option 1', 'Option 2', 'Option 3'],
  enableMultiSelect: true,
);

// Use in your widget
DynamicMultiDropdownSelect<String>(
  controller: controller,
  label: 'Select Options',
  isRequired: true,
  placeholder: 'Choose options...',
  itemBuilder: (context, item) => Text(item),
  onChanged: (values) {
    print('Selected: $values');
  },
)
```

### With Search

```dart
final controller = ExSelectController<String>(
  initialItems: List.generate(50, (index) => 'Item ${index + 1}'),
  enableMultiSelect: true,
  enableSearch: true, // Enable search
);

DynamicMultiDropdownSelect<String>(
  controller: controller,
  label: 'Search and Select',
  placeholder: 'Search items...',
  itemBuilder: (context, item) => Text(item),
  searchPlaceholder: 'Type to search...',
)
```

### Async Data Loading

```dart
// Define your model
class User {
  final int id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
}

// Create controller with async fetch
final controller = ExSelectController<User>(
  enableMultiSelect: true,
  enableAsync: true,
  fetchDataFn: (searchQuery) async {
    // Your API call here
    final response = await api.fetchUsers(searchQuery);
    return response.users;
  },
  itemToStringFn: (user) => user.name,
  getItemIdFn: (user) => user.id,
);

// Use the widget
DynamicMultiDropdownSelect<User>(
  controller: controller,
  label: 'Select Users',
  placeholder: 'Select users...',
  itemBuilder: (context, user) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
      Text(user.email, style: TextStyle(fontSize: 12)),
    ],
  ),
  getItemId: (user) => user.id,
)
```

## Additional Information

For more examples and detailed documentation, see the [example](example/) folder.

### Issues and Contributions

If you encounter any issues or have suggestions, please file them in the [issue tracker](https://github.com/vitu168/components-16kh/issues).

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
