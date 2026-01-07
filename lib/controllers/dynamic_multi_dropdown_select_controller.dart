import 'dart:async';
import 'package:flutter/material.dart';

class AsyncDebouncer<T> {
  Duration delay = const Duration(milliseconds: 300);
  Future<T> Function()? _action;
  Timer? _timer;

  Future<T> call(Future<T> Function() action) async {
    _action = action;
    _timer?.cancel();

    final completer = Completer<T>();

    _timer = Timer(delay, () async {
      if (_action == action) {
        try {
          final result = await action();
          if (!completer.isCompleted) {
            completer.complete(result);
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
      }
    });

    return completer.future;
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Extension for string checks
extension StringExtension on String? {
  bool get isNotNullOrBlank {
    return this != null && this!.trim().isNotEmpty;
  }
}
class ExSelectController<T> extends ValueNotifier<ExSelectState<T>> {
  ExSelectController({
    T? initialValue,
    List<T>? initialItems,
    Future<List<T>> Function(String? searchQuery)? fetchDataFn,
    String Function(T)? itemToStringFn,
    bool Function(T, String)? filterFn,
    Object? Function(T)? getItemIdFn,
    this.enableSearch = false,
    this.enableMultiSelect = false,
    this.enableAsync = false,
    this.cacheResults = true,
    this.enableDeselect = false,
  }) : _fetchDataFn = fetchDataFn,
       _itemToStringFn = itemToStringFn,
       _filterFn = filterFn,
       _getItemIdFn = getItemIdFn,
       super(
         ExSelectState<T>(
           selectedValue: initialValue,
           selectedValues: enableMultiSelect && initialValue != null
               ? [initialValue]
               : [],
           items: initialItems ?? [],
           isLoading: false,
         ),
       );

  final Future<List<T>> Function(String? searchQuery)? _fetchDataFn;
  final String Function(T)? _itemToStringFn;
  final bool Function(T, String)? _filterFn;
  final Object? Function(T)? _getItemIdFn;
  final bool enableSearch;
  final bool enableMultiSelect;
  final bool enableAsync;
  final bool cacheResults;
  final bool enableDeselect;

  final Map<String, List<T>> _cache = {};
  final _debouncer = AsyncDebouncer<List<T>>();
  T? get selectedValue => value.selectedValue;
  List<T> get selectedValues => value.selectedValues;
  List<T> get items => value.items;
  bool get isLoading => value.isLoading;
  String itemToString(T item) {
    return _itemToStringFn?.call(item) ?? item.toString();
  }
  Object? getItemId(T item) {
    return _getItemIdFn?.call(item);
  }
  bool itemsEqual(T? item1, T? item2) {
    if (item1 == null || item2 == null) return item1 == item2;
    if (_getItemIdFn != null) {
      return _getItemIdFn(item1) == _getItemIdFn(item2);
    }
    return item1 == item2;
  }
  void setSelectedValue(T? newValue) {
    if (!enableMultiSelect) {
      final currentValue = value.selectedValue;
      if (enableDeselect && currentValue != null && currentValue == newValue) {
        value = value.copyWith(selectedValue: null);
      } else {
        value = value.copyWith(selectedValue: newValue);
      }
    }
  }
  void setSelectedValues(List<T> newValues) {
    if (enableMultiSelect) {
      value = value.copyWith(selectedValues: newValues);
    }
  }
  void addToSelection(T item) {
    if (enableMultiSelect) {
      final currentValues = List<T>.from(selectedValues);
      if (!currentValues.any(
        (existingItem) => itemsEqual(existingItem, item),
      )) {
        currentValues.add(item);
        setSelectedValues(currentValues);
      }
    } else {
      setSelectedValue(item);
    }
  }
  void removeFromSelection(T item) {
    if (enableMultiSelect) {
      final currentValues = List<T>.from(selectedValues);
      currentValues.removeWhere(
        (existingItem) => itemsEqual(existingItem, item),
      );
      setSelectedValues(currentValues);
    }
  }
  void clearSelection() {
    if (enableMultiSelect) {
      setSelectedValues([]);
    } else {
      setSelectedValue(null);
    }
  }
  Future<List<T>> fetchData([
    String? searchQuery,
    bool silentUpdate = false,
  ]) async {
    if (_fetchDataFn == null) return [];
    final cacheKey = searchQuery ?? '';
    if (cacheResults && _cache.containsKey(cacheKey)) {
      final cachedItems = _cache[cacheKey]!;
      if (!silentUpdate) {
        value = value.copyWith(
          items: cachedItems,
          isLoading: false,
          error: null,
        );
      }
      return cachedItems;
    }
    if (!silentUpdate) {
      value = value.copyWith(isLoading: true, error: null);
    }

    try {
      late List<T> results;
      if (searchQuery.isNotNullOrBlank) {
        results = await _debouncer(() => _fetchDataFn(searchQuery));
      } else {
        results = await _fetchDataFn(searchQuery);
      }
      if (cacheResults) {
        _cache[cacheKey] = results;
      }
      T? newSelectedValue = value.selectedValue;
      List<T> newSelectedValues = value.selectedValues;

      if (_getItemIdFn != null) {
        if (newSelectedValue != null) {
          final selectedId = _getItemIdFn(newSelectedValue);
          newSelectedValue = results.firstWhere(
            (item) => _getItemIdFn(item) == selectedId,
            orElse: () => newSelectedValue!,
          );
        }
        if (newSelectedValues.isNotEmpty) {
          final selectedIds = newSelectedValues
              .map((item) => _getItemIdFn(item))
              .toList();
          newSelectedValues = results
              .where((item) => selectedIds.contains(_getItemIdFn(item)))
              .toList();
        }
      }
      if (!silentUpdate) {
        value = value.copyWith(
          items: results,
          selectedValue: newSelectedValue,
          selectedValues: newSelectedValues,
          isLoading: false,
          error: null,
        );
      }

      return results;
    } catch (error) {
      if (!silentUpdate) {
        value = value.copyWith(isLoading: false, error: error.toString());
      }
      rethrow;
    }
  }

  void updateItems(List<T> items, {String? error}) {
    value = value.copyWith(items: items, isLoading: false, error: error);
  }
  bool get needsInitialLoad => enableAsync && items.isEmpty && !isLoading;
  List<T> getFilteredItems(String searchQuery) {
    if (searchQuery.isEmpty) return items;

    if (_filterFn != null) {
      return items.where((item) => _filterFn(item, searchQuery)).toList();
    }
    return items.where((item) {
      final itemStr = itemToString(item).toLowerCase();
      return itemStr.contains(searchQuery.toLowerCase());
    }).toList();
  }
  void setItems(List<T> newItems) {
    value = value.copyWith(items: newItems);
  }
  String? validate({bool isRequired = false}) {
    if (isRequired) {
      if (enableMultiSelect) {
        if (selectedValues.isEmpty) {
          return 'Please select at least one item';
        }
      } else {
        if (selectedValue == null) {
          return 'This field is required';
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    _cache.clear();
    super.dispose();
  }
}

/// State model for select component
class ExSelectState<T> {
  const ExSelectState({
    this.selectedValue,
    this.selectedValues = const [],
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  static const Object _noValue = Object();

  final T? selectedValue;
  final List<T> selectedValues;
  final List<T> items;
  final bool isLoading;
  final String? error;

  ExSelectState<T> copyWith({
    Object? selectedValue = _noValue,
    List<T>? selectedValues,
    List<T>? items,
    bool? isLoading,
    Object? error = _noValue,
  }) {
    return ExSelectState<T>(
      selectedValue: identical(selectedValue, _noValue)
          ? this.selectedValue
          : selectedValue as T?,
      selectedValues: selectedValues ?? this.selectedValues,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _noValue) ? this.error : error as String?,
    );
  }
}
