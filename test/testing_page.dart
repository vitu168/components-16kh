import 'package:flutter_test/flutter_test.dart';
import 'package:sdkcomponents16/sdkcomponents16.dart';

void main() {
  group('ExSelectController', () {
    test('initializes with empty selection', () {
      final controller = ExSelectController<String>(
        initialItems: ['Item 1', 'Item 2', 'Item 3'],
        enableMultiSelect: true,
      );

      expect(controller.selectedValues, isEmpty);
      expect(controller.items.length, 3);

      controller.dispose();
    });

    test('sets and gets selected values', () {
      final controller = ExSelectController<String>(
        initialItems: ['Item 1', 'Item 2', 'Item 3'],
        enableMultiSelect: true,
      );

      controller.setSelectedValues(['Item 1', 'Item 2']);

      expect(controller.selectedValues.length, 2);
      expect(controller.selectedValues, contains('Item 1'));
      expect(controller.selectedValues, contains('Item 2'));

      controller.dispose();
    });

    test('adds to selection', () {
      final controller = ExSelectController<String>(
        initialItems: ['Item 1', 'Item 2', 'Item 3'],
        enableMultiSelect: true,
      );

      controller.addToSelection('Item 1');
      expect(controller.selectedValues, contains('Item 1'));

      controller.addToSelection('Item 2');
      expect(controller.selectedValues.length, 2);

      controller.dispose();
    });

    test('removes from selection', () {
      final controller = ExSelectController<String>(
        initialItems: ['Item 1', 'Item 2', 'Item 3'],
        enableMultiSelect: true,
      );

      controller.setSelectedValues(['Item 1', 'Item 2']);
      controller.removeFromSelection('Item 1');

      expect(controller.selectedValues.length, 1);
      expect(controller.selectedValues, contains('Item 2'));

      controller.dispose();
    });

    test('clears selection', () {
      final controller = ExSelectController<String>(
        initialItems: ['Item 1', 'Item 2', 'Item 3'],
        enableMultiSelect: true,
      );

      controller.setSelectedValues(['Item 1', 'Item 2']);
      controller.clearSelection();

      expect(controller.selectedValues, isEmpty);

      controller.dispose();
    });

    test('filters items based on search query', () {
      final controller = ExSelectController<String>(
        initialItems: ['Apple', 'Banana', 'Cherry', 'Apricot'],
        enableMultiSelect: true,
        enableSearch: true,
      );

      final filtered = controller.getFilteredItems('ap');

      expect(filtered.length, 2);
      expect(filtered, contains('Apple'));
      expect(filtered, contains('Apricot'));

      controller.dispose();
    });

    test('validates required field', () {
      final controller = ExSelectController<String>(
        initialItems: ['Item 1', 'Item 2'],
        enableMultiSelect: true,
      );

      final error = controller.validate(isRequired: true);
      expect(error, isNotNull);

      controller.setSelectedValues(['Item 1']);
      final noError = controller.validate(isRequired: true);
      expect(noError, isNull);

      controller.dispose();
    });

    test('uses custom itemToString function', () {
      final controller = ExSelectController<int>(
        initialItems: [1, 2, 3],
        enableMultiSelect: true,
        itemToStringFn: (item) => 'Number $item',
      );

      expect(controller.itemToString(1), 'Number 1');
      expect(controller.itemToString(2), 'Number 2');

      controller.dispose();
    });

    test('uses getItemId for equality checks', () {
      final controller = ExSelectController<TestItem>(
        initialItems: [
          TestItem(1, 'Item 1'),
          TestItem(2, 'Item 2'),
        ],
        enableMultiSelect: true,
        getItemIdFn: (item) => item.id,
      );

      final item1a = TestItem(1, 'Item 1');
      final item1b = TestItem(1, 'Item 1 Updated');

      controller.addToSelection(item1a);
      expect(controller.itemsEqual(item1a, item1b), isTrue);

      controller.dispose();
    });
  });
}

class TestItem {
  final int id;
  final String name;

  TestItem(this.id, this.name);
}

