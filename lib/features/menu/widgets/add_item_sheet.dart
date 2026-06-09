import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../models/menu_item.dart';
import '../providers/menu_provider.dart';

class AddItemSheet extends ConsumerStatefulWidget {
  final MenuItem? existingItem;
  final List<Map<String, dynamic>> categories;

  const AddItemSheet({
    super.key,
    this.existingItem,
    required this.categories,
  });

  @override
  ConsumerState<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  
  String? _selectedCategoryId;
  double _prepTime = 15;
  bool _isAvailable = true;
  String? _imageUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _descController = TextEditingController(text: item?.description ?? '');
    _priceController = TextEditingController(text: item != null ? '${item.price}' : '');
    _selectedCategoryId = item?.categoryId ?? (widget.categories.isNotEmpty ? widget.categories.first['id'] as String : null);
    _prepTime = item != null ? item.prepTimeMinutes.toDouble() : 15;
    _isAvailable = item?.isAvailable ?? true;
    _imageUrl = item?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      CustomSnackBar.showError(context, 'Please select a category.');
      return;
    }

    setState(() => _isSaving = true);
    
    final itemData = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'price': double.parse(_priceController.text),
      'category_id': _selectedCategoryId,
      'prep_time_minutes': _prepTime.toInt(),
      'is_available': _isAvailable,
      'image_url': _imageUrl,
    };

    try {
      if (widget.existingItem != null) {
        await ref.read(menuNotifierProvider.notifier).editItem(widget.existingItem!.id, itemData);
        if (mounted) CustomSnackBar.showSuccess(context, 'Menu item updated!');
      } else {
        await ref.read(menuNotifierProvider.notifier).addItem(itemData);
        if (mounted) CustomSnackBar.showSuccess(context, 'New menu item created!');
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) CustomSnackBar.showError(context, 'Save failed: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(kRadiusSheet),
          topRight: Radius.circular(kRadiusSheet),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existingItem != null ? 'Edit Menu Item' : 'Add Menu Item',
                style: kHeadline.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 20),
              
              // Name
              TextFormField(
                controller: _nameController,
                validator: (val) => Validators.validateRequired(val, 'Item name'),
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'e.g. Garlic Naan',
                ),
                style: kBody,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Ingredients or notes about the taste...',
                ),
                style: kBody,
              ),
              const SizedBox(height: 16),

              // Price & Category Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => Validators.validateNumeric(val, 'Price'),
                      decoration: const InputDecoration(
                        labelText: 'Price (₹)',
                        hintText: 'e.g. 180',
                      ),
                      style: kBody,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      dropdownColor: kSurface2,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: widget.categories.map((c) {
                        return DropdownMenuItem(
                          value: c['id'] as String,
                          child: Text(c['name'] as String, style: kCaption),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryId = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Preparation Time slider
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: kTextSecondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Prep Time: ${_prepTime.toInt()} mins',
                    style: kBody.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Slider(
                value: _prepTime,
                min: 1,
                max: 60,
                divisions: 59,
                activeColor: kAccent,
                inactiveColor: kSurface2,
                onChanged: (val) {
                  setState(() {
                    _prepTime = val;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Availability Switch
              SwitchListTile(
                value: _isAvailable,
                onChanged: (val) {
                  setState(() {
                    _isAvailable = val;
                  });
                },
                title: Text('Available for Ordering', style: kBody),
                subtitle: Text('Instantly toggles presence on the POS POS screens', style: kCaption),
                activeColor: kAccent,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.black)),
                      )
                    : Text(widget.existingItem != null ? 'Update Item' : 'Create Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
