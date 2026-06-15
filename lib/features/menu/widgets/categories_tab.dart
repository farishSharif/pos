import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../orders/providers/orders_provider.dart';
import '../models/menu_category.dart';
import '../providers/menu_provider.dart';

class CategoriesTab extends ConsumerWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    Widget buildReorderableList(List<MenuCategory> cats) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          final cat = cats[index];
          // Simple color resolver
          Color catColor = kAccent;
          try {
            if (cat.color != null) {
              catColor = Color(int.parse(cat.color!.replaceFirst('#', 'FF'), radix: 16));
            }
          } catch (_) {}

          return Card(
            key: Key(cat.id),
            color: kSurface,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.drag_handle, color: kTextSecondary),
              title: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: catColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Text(cat.name, style: kBody.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              subtitle: Text('Sort Order: ${cat.sortOrder}', style: kCaption),
              trailing: Switch(
                value: cat.isActive,
                activeThumbColor: kAccent,
                onChanged: (val) {
                  ref.read(menuNotifierProvider.notifier).updateCategoryActiveStatus(cat.id, val);
                },
              ),
            ),
          );
        },
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final items = List<MenuCategory>.from(cats);
          final item = items.removeAt(oldIndex);
          items.insert(newIndex, item);

          final reorderedIds = items.map((c) => c.id).toList();
          ref.read(menuNotifierProvider.notifier).reorderCategories(reorderedIds);
        },
      );
    }

    return categoriesAsync.when(
      data: (rows) {
        final cats = rows.map((r) => MenuCategory.fromJson(r)).toList();
        cats.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return buildReorderableList(cats);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, __) => Center(child: Text('Error: $err')),
    );
  }
}
