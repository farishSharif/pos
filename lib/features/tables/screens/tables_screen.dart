import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../models/restaurant_table.dart';
import '../providers/tables_provider.dart';
import '../widgets/table_detail_sheet.dart';

class TablesScreen extends ConsumerStatefulWidget {
  const TablesScreen({super.key});

  @override
  ConsumerState<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends ConsumerState<TablesScreen> {
  String _selectedFilter = 'all'; // 'all', 'available', 'occupied', 'ready'
  RestaurantTable? _selectedTable;
  bool _isRearranging = false;
  final Map<int, Offset> _draggedPositions = {};

  // default positioning helper (column-row staggered)
  Offset _getDefaultPosition(int index) {
    const double cardWidth = 140.0;
    const double cardHeight = 100.0;
    const double spacingX = 40.0;
    const double spacingY = 30.0;
    const double paddingX = 40.0;
    const double paddingY = 40.0;

    const int columns = 4;
    final col = index % columns;
    final row = index ~/ columns;

    final x = col * (cardWidth + spacingX) + paddingX;
    final y = row * (cardHeight + spacingY) + paddingY;

    return Offset(x, y);
  }

  void _showManageTablesDialog(List<RestaurantTable> currentTables) {
    final controller = TextEditingController(text: currentTables.length.toString());
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: kSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusCard)),
          title: const Text('Manage Tables', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set the number of tables in your restaurant (1-50).',
                style: TextStyle(color: kTextSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of Tables',
                ),
                style: kBody,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: kTextSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: Colors.black),
              onPressed: () async {
                final count = int.tryParse(controller.text.trim());
                if (count != null && count >= 1 && count <= 50) {
                  final outerContext = context;
                  Navigator.pop(dialogContext);
                  try {
                    await ref.read(tablesNotifierProvider.notifier).setTableCount(count);
                    if (outerContext.mounted) CustomSnackBar.showSuccess(outerContext, 'Restaurant tables updated to $count.');
                  } catch (e) {
                    if (outerContext.mounted) CustomSnackBar.showError(outerContext, 'Failed to update tables: $e');
                  }
                } else {
                  CustomSnackBar.showError(dialogContext, 'Please enter a number between 1 and 50.');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTableDialog(List<RestaurantTable> currentTables) {
    final nextNum = currentTables.isEmpty
        ? 1
        : (currentTables.map((t) => t.tableNumber).reduce((a, b) => a > b ? a : b) + 1);
    final numberController = TextEditingController(text: nextNum.toString());
    final capacityController = TextEditingController(text: '4');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: kSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusCard)),
          title: const Text('Add New Table', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: numberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Table Number'),
                style: kBody,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacity (Guests)'),
                style: kBody,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: kTextSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final numVal = int.tryParse(numberController.text.trim());
                final capVal = int.tryParse(capacityController.text.trim());
                if (numVal != null && capVal != null && numVal > 0 && capVal > 0) {
                  // Check if table number already exists
                  final exists = currentTables.any((t) => t.tableNumber == numVal);
                  if (exists) {
                    CustomSnackBar.showError(dialogContext, 'Table number $numVal already exists.');
                    return;
                  }
                  final outerContext = context;
                  Navigator.pop(dialogContext);
                  try {
                    await ref.read(tablesNotifierProvider.notifier).addTable(
                          tableNumber: numVal,
                          capacity: capVal,
                        );
                    if (outerContext.mounted) {
                      CustomSnackBar.showSuccess(outerContext, 'Table $numVal added successfully.');
                    }
                  } catch (e) {
                    if (outerContext.mounted) {
                      CustomSnackBar.showError(outerContext, 'Failed to add table: $e');
                    }
                  }
                } else {
                  CustomSnackBar.showError(dialogContext, 'Please enter valid positive numbers.');
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters() {
    final filters = [
      {'id': 'all', 'label': 'All Tables'},
      {'id': 'available', 'label': 'Available'},
      {'id': 'occupied', 'label': 'Occupied'},
      {'id': 'ready', 'label': 'Ready to Serve'},
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 16),
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

  Widget _buildDineInMap(List<RestaurantTable> tables, bool isTablet) {
    const double canvasWidth = 800.0;
    const double canvasHeight = 500.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(
          color: _isRearranging ? kWarning : kDivider,
          width: _isRearranging ? 2.0 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: _isRearranging ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: _isRearranging ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                child: Container(
                  width: canvasWidth,
                  height: canvasHeight,
                  color: const Color(0xFF130F1A), // Dark blueprint background
                  child: CustomPaint(
                    painter: DottedGridPainter(),
                    child: Stack(
                      children: tables.map((table) {
                        final Offset currentPos;
                        if (_isRearranging) {
                          currentPos = _draggedPositions[table.id] ??
                              Offset(table.positionX, table.positionY);
                        } else {
                          currentPos = (table.positionX != 0.0 || table.positionY != 0.0)
                              ? Offset(table.positionX, table.positionY)
                              : _getDefaultPosition(tables.indexOf(table));
                        }

                        final bool matchesFilter = _selectedFilter == 'all' ||
                            (_selectedFilter == 'available' && table.status == 'available') ||
                            (_selectedFilter == 'occupied' &&
                                (table.status == 'occupied' ||
                                    table.status == 'ordered' ||
                                    table.status == 'preparing')) ||
                            (_selectedFilter == 'ready' && table.status == 'ready');

                        final double opacity = (_isRearranging || matchesFilter) ? 1.0 : 0.25;

                        return Positioned(
                          left: currentPos.dx,
                          top: currentPos.dy,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: opacity,
                            child: _isRearranging
                                ? GestureDetector(
                                    onPanStart: (_) {
                                      if (!_draggedPositions.containsKey(table.id)) {
                                        _draggedPositions[table.id] = (table.positionX != 0.0 || table.positionY != 0.0)
                                            ? Offset(table.positionX, table.positionY)
                                            : _getDefaultPosition(tables.indexOf(table));
                                      }
                                    },
                                    onPanUpdate: (details) {
                                      setState(() {
                                        final current = _draggedPositions[table.id]!;
                                        double newX = current.dx + details.delta.dx;
                                        double newY = current.dy + details.delta.dy;

                                        // Clamp to canvas bounds
                                        newX = newX.clamp(10.0, canvasWidth - 150.0);
                                        newY = newY.clamp(10.0, canvasHeight - 110.0);

                                        // Snap to 20px grid
                                        newX = (newX / 20.0).round() * 20.0;
                                        newY = (newY / 20.0).round() * 20.0;

                                        _draggedPositions[table.id] = Offset(newX, newY);
                                      });
                                    },
                                    child: MapTableWidget(
                                      table: table,
                                      isSelected: false,
                                      isRearranging: true,
                                      onTap: () {},
                                    ),
                                  )
                                : MapTableWidget(
                                    table: table,
                                    isSelected: _selectedTable?.id == table.id,
                                    isRearranging: false,
                                    onTap: () {
                                      setState(() {
                                        _selectedTable = table;
                                      });
                                      if (!isTablet) {
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
                                  ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isRearranging)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: kWarning.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: kWarning, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Rearrange Mode Active',
                        style: kBody.copyWith(color: kWarning, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    '✏️ Drag tables to rearrange • Click "Done" when finished',
                    style: kCaption.copyWith(color: kWarning, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tablesAsync = ref.watch(tablesStreamProvider);
    final isTablet = Breakpoints.isLargeScreen(context);

    // Sync selected table if status changes in stream
    if (_selectedTable != null && tablesAsync.hasValue) {
      try {
        _selectedTable = tablesAsync.value!.firstWhere((t) => t.id == _selectedTable!.id);
      } catch (_) {
        _selectedTable = null;
      }
    }

    return Scaffold(
      appBar: isTablet ? null : const AppBarWidget(title: 'Dine In'),
      drawer: isTablet ? null : const AppDrawer(),
      bottomNavigationBar: isTablet ? null : const BottomNav(),
      body: Row(
        children: [
          if (isTablet) const SidebarNavigation(),
          Expanded(
            child: SafeArea(
              child: tablesAsync.when(
                data: (tables) {
                  return Padding(
                    padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text('Dine In', style: kHeadline.copyWith(fontSize: 28)),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          if (_isRearranging) {
                                            final List<RestaurantTable> updated = [];
                                            for (final table in tables) {
                                              final pos = _draggedPositions[table.id];
                                              if (pos != null) {
                                                updated.add(table.copyWith(positionX: pos.dx, positionY: pos.dy));
                                              }
                                            }
                                            try {
                                              await ref.read(tablesNotifierProvider.notifier).updateTablePositions(updated);
                                              if (context.mounted) CustomSnackBar.showSuccess(context, 'Table layout saved.');
                                            } catch (e) {
                                              if (context.mounted) CustomSnackBar.showError(context, 'Failed to save layout: $e');
                                            }
                                            setState(() {
                                              _isRearranging = false;
                                              _draggedPositions.clear();
                                            });
                                          } else {
                                            setState(() {
                                              _isRearranging = true;
                                              _draggedPositions.clear();
                                              for (final t in tables) {
                                                _draggedPositions[t.id] = (t.positionX != 0.0 || t.positionY != 0.0)
                                                    ? Offset(t.positionX, t.positionY)
                                                    : _getDefaultPosition(tables.indexOf(t));
                                              }
                                            });
                                          }
                                        },
                                        icon: Icon(_isRearranging ? Icons.done : Icons.lock_open_rounded, size: 16),
                                        label: Text(_isRearranging ? 'Done' : 'Rearrange'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _isRearranging ? kSuccess : kSurface2,
                                          foregroundColor: Colors.white,
                                          side: BorderSide(color: _isRearranging ? kSuccess : kDivider),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => _showAddTableDialog(tables),
                                        icon: const Icon(Icons.add, size: 16),
                                        label: const Text('Add Table'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kSurface2,
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(color: kDivider),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => _showManageTablesDialog(tables),
                                        icon: const Icon(Icons.settings_outlined, size: 16),
                                        label: const Text('Manage Tables'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kSurface2,
                                          foregroundColor: kAccent,
                                          side: const BorderSide(color: kDivider),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildFilters(),
                              Expanded(child: _buildDineInMap(tables, isTablet)),
                            ],
                          ),
                        ),
                        if (isTablet && _selectedTable != null) ...[
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: kSurface,
                                borderRadius: BorderRadius.circular(kRadiusCard),
                                border: Border.all(color: kDivider),
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
                      ],
                    ),
                  );
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

class DottedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    const double spacing = 20.0;
    const double radius = 1.2;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MapTableWidget extends StatelessWidget {
  final RestaurantTable table;
  final bool isSelected;
  final bool isRearranging;
  final VoidCallback onTap;

  const MapTableWidget({
    super.key,
    required this.table,
    required this.isSelected,
    required this.isRearranging,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = switch (table.status.toLowerCase()) {
      'available' => kSuccess,
      'ordered' => kWarning,
      'preparing' => const Color(0xFFFF6B35),
      'ready' => kInfo,
      'occupied' || 'billed' => kError,
      _ => kTextSecondary,
    };

    return Container(
      width: 140,
      height: 100,
      decoration: BoxDecoration(
        color: isSelected ? kSurface2 : kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? kAccent : (isRearranging ? kWarning.withOpacity(0.5) : statusColor.withOpacity(0.6)),
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isRearranging ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isRearranging ? Icons.drag_indicator : Icons.table_restaurant,
                      color: isRearranging ? kWarning : statusColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Table ${table.tableNumber}',
                      style: kBody.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? kAccent : kTextPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Cap: ${table.capacity}',
                      style: kCaption.copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isRearranging ? kWarning : statusColor).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isRearranging ? 'DRAG ME' : table.status.toUpperCase(),
                        style: kCaption.copyWith(
                          color: isRearranging ? kWarning : statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
