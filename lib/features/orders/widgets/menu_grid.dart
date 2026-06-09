import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../menu/models/menu_category.dart';
import '../../menu/models/menu_item.dart';
import '../providers/orders_provider.dart';
import '../providers/cart_provider.dart';
import 'menu_item_card.dart';

class MenuGrid extends ConsumerStatefulWidget {
  const MenuGrid({super.key});

  @override
  ConsumerState<MenuGrid> createState() => _MenuGridState();
}

class _MenuGridState extends ConsumerState<MenuGrid> {
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final itemsAsync = ref.watch(menuItemsProvider);
    final isTablet = Breakpoints.isLargeScreen(context);

    Widget buildCategoryTabs(List<Map<String, dynamic>> cats) {
      final menuCats = cats.map((c) => MenuCategory.fromJson(c)).toList();

      return Container(
        height: 54,
        margin: const EdgeInsets.only(bottom: 12),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: const Text('All Items'),
                selected: _selectedCategoryId == 'all',
                onSelected: (val) {
                  if (val) setState(() => _selectedCategoryId = 'all');
                },
                selectedColor: kAccent,
                labelStyle: kCaption.copyWith(
                  color: _selectedCategoryId == 'all' ? Colors.black : kTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: kSurface,
              ),
            ),
            ...menuCats.map((c) {
              final active = _selectedCategoryId == c.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(c.name),
                  selected: active,
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategoryId = c.id);
                  },
                  selectedColor: kAccent,
                  labelStyle: kCaption.copyWith(
                    color: active ? Colors.black : kTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: kSurface,
                ),
              );
            }),
          ],
        ),
      );
    }

    Widget buildGrid(List<Map<String, dynamic>> items) {
      final allItems = items.map((i) => MenuItem.fromJson(i)).toList();

      // Apply filters
      var filtered = allItems.where((item) {
        if (_selectedCategoryId != 'all' && item.categoryId != _selectedCategoryId) return false;
        if (_searchQuery.isNotEmpty && !item.name.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
        return true;
      }).toList();

      if (filtered.isEmpty) {
        return const EmptyStateWidget(
          title: 'No Dishes Found',
          subtitle: 'Try changing category tabs or modifying search terms.',
          fallbackIcon: Icons.search_off,
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filtered.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isTablet ? 1.05 : 0.9,
        ),
        itemBuilder: (context, index) {
          final item = filtered[index];
          return MenuItemCard(
            item: item,
            onAdd: () {
              ref.read(cartNotifierProvider.notifier).addItem(item);
            },
          );
        },
      );
    }

    return Column(
      children: [
        // Search Input
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFormField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search delicious dishes...',
              prefixIcon: const Icon(Icons.search, color: kTextSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: kTextSecondary),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
          ),
        ),
        // Categories
        categoriesAsync.when(
          data: (cats) => buildCategoryTabs(cats),
          loading: () => Container(
            height: 50,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const LoadingShimmer(width: 250, height: 35),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
        // Items Grid
        Expanded(
          child: itemsAsync.when(
            data: (items) => buildGrid(items),
            loading: () => Padding(
              padding: const EdgeInsets.all(16.0),
              child: LoadingShimmer.grid(count: 6, crossAxisCount: isTablet ? 3 : 2),
            ),
            error: (err, stack) => Center(
              child: Text('Error loading menu: $err', style: kCaption),
            ),
          ),
        ),
      ],
    );
  }
}
