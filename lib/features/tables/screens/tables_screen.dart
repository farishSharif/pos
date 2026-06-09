import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../models/restaurant_table.dart';
import '../providers/tables_provider.dart';
import '../widgets/table_card.dart';
import '../widgets/table_detail_sheet.dart';

class TablesScreen extends ConsumerStatefulWidget {
  const TablesScreen({super.key});

  @override
  ConsumerState<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends ConsumerState<TablesScreen> {
  String _selectedFilter = 'all'; // 'all', 'available', 'occupied', 'ready'
  RestaurantTable? _selectedTable;

  @override
  Widget build(BuildContext context) {
    final tablesAsync = ref.watch(tablesStreamProvider);
    final isTablet = Breakpoints.isLargeScreen(context);

    // Sync selected table if status changed in stream
    if (_selectedTable != null && tablesAsync.hasValue) {
      try {
        _selectedTable = tablesAsync.value!.firstWhere((t) => t.id == _selectedTable!.id);
      } catch (_) {
        _selectedTable = null;
      }
    }

    Widget buildMainGrid(List<RestaurantTable> tables) {
      // Filter list
      final filtered = tables.where((table) {
        if (_selectedFilter == 'available') return table.status == 'available';
        if (_selectedFilter == 'occupied') {
          return table.status == 'occupied' || table.status == 'ordered' || table.status == 'preparing';
        }
        if (_selectedFilter == 'ready') return table.status == 'ready';
        return true;
      }).toList();

      if (filtered.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'No tables found matching this filter.',
              style: kCaption,
            ),
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.15,
        ),
        itemBuilder: (context, index) {
          final table = filtered[index];
          return TableCard(
            table: table,
            isSelected: _selectedTable?.id == table.id,
            onTap: () {
              setState(() {
                _selectedTable = table;
              });
              if (!isTablet) {
                // Show bottom sheet on phone
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => TableDetailPanel(
                    table: table,
                    isTablet: false,
                  ),
                );
              }
            },
          );
        },
      );
    }

    Widget buildFilters() {
      final filters = [
        {'id': 'all', 'label': 'All Tables'},
        {'id': 'available', 'label': 'Available'},
        {'id': 'occupied', 'label': 'Occupied / Busy'},
        {'id': 'ready', 'label': 'Ready for Serving'},
      ];

      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: filters.map((f) {
            final active = _selectedFilter == f['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(f['label']!),
                selected: active,
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      _selectedFilter = f['id']!;
                    });
                  }
                },
                selectedColor: kAccent,
                labelStyle: kCaption.copyWith(
                  color: active ? Colors.black : kTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
                backgroundColor: kSurface,
              ),
            );
          }).toList(),
        ),
      );
    }

    Widget buildContent(List<RestaurantTable> tables) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          buildFilters(),
          Expanded(child: buildMainGrid(tables)),
        ],
      );
    }

    return Scaffold(
      appBar: isTablet ? null : const AppBarWidget(title: 'Tables'),
      bottomNavigationBar: isTablet ? null : const BottomNav(),
      body: Row(
        children: [
          if (isTablet) const SidebarNavigation(),
          Expanded(
            child: SafeArea(
              child: tablesAsync.when(
                data: (tables) {
                  if (isTablet) {
                    return Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text('Table Management', style: kHeadline.copyWith(fontSize: 28)),
                              ),
                              Expanded(child: buildContent(tables)),
                            ],
                          ),
                        ),
                        if (_selectedTable != null)
                          Expanded(
                            flex: 4,
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(left: BorderSide(color: kDivider, width: 1)),
                              ),
                              child: TableDetailPanel(
                                table: _selectedTable!,
                                isTablet: true,
                                onClose: () {
                                  setState(() {
                                    _selectedTable = null;
                                  });
                                },
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                  return buildContent(tables);
                },
                loading: () => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: LoadingShimmer.grid(count: 8, crossAxisCount: isTablet ? 3 : 2),
                  ),
                ),
                error: (err, stack) => ErrorStateWidget(
                  errorMessage: err.toString(),
                  onRetry: () => ref.invalidate(tablesStreamProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
