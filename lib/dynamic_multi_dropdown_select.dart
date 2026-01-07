import 'package:flutter/material.dart';
import 'controllers/dynamic_multi_dropdown_select_controller.dart';
class DynamicMultiDropdownSelect<T> extends StatefulWidget {
  const DynamicMultiDropdownSelect({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.placeholder = 'Select',
    this.label,
    this.isRequired = false,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.maxHeight = 300.0,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.getItemId,
    this.searchPlaceholder = 'Search',
    this.emptyText = 'No items found',
    this.loadingText = 'Loading...',
  });
  final ExSelectController<T> controller;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String placeholder;
  final String? label;
  final bool isRequired;
  final void Function(List<T> values)? onChanged;
  final String? Function(List<T>)? validator;
  final bool enabled;
  final double maxHeight;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final Object? Function(T item)? getItemId;
  final String searchPlaceholder;
  final String emptyText;
  final String loadingText;

  @override
  State<DynamicMultiDropdownSelect<T>> createState() =>
      _DynamicMultiDropdownSelectState<T>();
}

class _DynamicMultiDropdownSelectState<T>
    extends State<DynamicMultiDropdownSelect<T>> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isOpen = false;
  String _searchQuery = '';
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _isOpen) {
      _closeDropdown();
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (_searchQuery != query) {
      setState(() {
        _searchQuery = query;
      });
      _updateFilteredItems();
    }
  }

  Future<void> _updateFilteredItems() async {
    if (widget.controller.enableAsync) {
      try {
        final items = await widget.controller.fetchData(_searchQuery);
        if (mounted) {
          setState(() {
            _filteredItems = items;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _filteredItems = [];
          });
        }
      }
    } else {
      setState(() {
        _filteredItems = widget.controller.getFilteredItems(_searchQuery);
      });
    }
  }

  String? _validateFn(List<T>? values) {
    if (widget.isRequired && (values == null || values.isEmpty)) {
      return 'Please select at least one item';
    }

    if (widget.validator != null) {
      return widget.validator!(values ?? []);
    }

    return null;
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (!widget.enabled) return;

    setState(() {
      _isOpen = true;
      _searchQuery = '';
      _searchController.clear();
    });

    _updateFilteredItems();

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _focusNode.requestFocus();
  }

  void _closeDropdown() {
    setState(() {
      _isOpen = false;
    });
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 4.0),
          child: Material(
            elevation: 4.0,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8.0),
            child: Container(
              constraints: BoxConstraints(maxHeight: widget.maxHeight),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(8.0),
                border: Border.all(
                  color: widget.borderColor ??
                      Theme.of(context).dividerColor,
                  width: widget.borderWidth,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.controller.enableSearch) _buildSearchField(),
                  Flexible(
                    child: _buildItemsList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: widget.searchPlaceholder,
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return ValueListenableBuilder<ExSelectState<T>>(
      valueListenable: widget.controller,
      builder: (context, state, child) {
        if (state.isLoading) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(widget.loadingText),
                ],
              ),
            ),
          );
        }

        if (state.error != null) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Error: ${state.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        }

        final items = _searchQuery.isEmpty
            ? state.items
            : _filteredItems;

        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text(widget.emptyText)),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = _isItemSelected(item, state.selectedValues);

            return InkWell(
              onTap: () => _onItemTap(item, isSelected),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) {
                        _onItemTap(item, isSelected);
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: widget.itemBuilder(context, item),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _isItemSelected(T item, List<T> selectedValues) {
    if (widget.getItemId != null) {
      final itemId = widget.getItemId!(item);
      return selectedValues.any(
        (selected) => widget.getItemId!(selected) == itemId,
      );
    }
    return selectedValues.contains(item);
  }

  void _onItemTap(T item, bool currentlySelected) {
    List<T> newSelection = List<T>.from(widget.controller.selectedValues);

    if (currentlySelected) {
      // Remove item
      if (widget.getItemId != null) {
        final itemId = widget.getItemId!(item);
        newSelection.removeWhere(
          (selected) => widget.getItemId!(selected) == itemId,
        );
      } else {
        newSelection.remove(item);
      }
    } else {
      // Add item
      newSelection.add(item);
    }

    widget.controller.setSelectedValues(newSelection);
    widget.onChanged?.call(newSelection);

    // Update overlay to reflect new selection
    _overlayEntry?.markNeedsBuild();
  }

  void _removeSelectedItem(T item) {
    List<T> newSelection = List<T>.from(widget.controller.selectedValues);

    if (widget.getItemId != null) {
      final itemId = widget.getItemId!(item);
      newSelection.removeWhere(
        (selected) => widget.getItemId!(selected) == itemId,
      );
    } else {
      newSelection.remove(item);
    }

    widget.controller.setSelectedValues(newSelection);
    widget.onChanged?.call(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<T>>(
      initialValue: widget.controller.value.selectedValues,
      validator: _validateFn,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (FormFieldState<List<T>> field) {
        // Sync FormField with controller
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              field.value != widget.controller.selectedValues) {
            field.didChange(widget.controller.selectedValues);
          }
        });

        final borderColor = field.hasError
            ? (widget.errorBorderColor ?? Theme.of(context).colorScheme.error)
            : _isOpen
                ? (widget.focusedBorderColor ??
                    Theme.of(context).colorScheme.primary)
                : (widget.borderColor ?? Theme.of(context).dividerColor);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            if (widget.label != null) ...[
              Row(
                children: [
                  Text(
                    widget.label!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (widget.isRequired)
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Dropdown trigger
            CompositedTransformTarget(
              link: _layerLink,
              child: Focus(
                focusNode: _focusNode,
                child: InkWell(
                  onTap: widget.enabled ? _toggleDropdown : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: widget.enabled
                          ? Theme.of(context).cardColor
                          : Theme.of(context).disabledColor.withOpacity(0.1),
                      borderRadius:
                          widget.borderRadius ?? BorderRadius.circular(8.0),
                      border: Border.all(
                        color: borderColor,
                        width: widget.borderWidth,
                      ),
                    ),
                    child: ValueListenableBuilder<ExSelectState<T>>(
                      valueListenable: widget.controller,
                      builder: (context, state, child) {
                        return Row(
                          children: [
                            Expanded(
                              child: state.selectedValues.isEmpty
                                  ? Text(
                                      widget.placeholder,
                                      style: TextStyle(
                                        color: Theme.of(context).hintColor,
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 4.0,
                                      runSpacing: 4.0,
                                      children: state.selectedValues
                                          .map(
                                            (item) => Chip(
                                              label: widget.itemBuilder(
                                                context,
                                                item,
                                              ),
                                              deleteIcon: const Icon(
                                                Icons.close,
                                                size: 16,
                                              ),
                                              onDeleted: widget.enabled
                                                  ? () =>
                                                      _removeSelectedItem(item)
                                                  : null,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                horizontal: 8.0,
                                                vertical: 2.0,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _isOpen
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: widget.enabled
                                  ? null
                                  : Theme.of(context).disabledColor,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Error message
            if (field.hasError) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
