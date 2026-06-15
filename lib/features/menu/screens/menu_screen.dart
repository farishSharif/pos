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
import '../../orders/providers/orders_provider.dart';
import '../widgets/menu_items_tab.dart';
import '../widgets/categories_tab.dart';
import '../widgets/add_item_sheet.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = Breakpoints.isLargeScreen(context);
    final categoriesAsync = ref.watch(categoriesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: isTablet ? null : const AppBarWidget(title: 'Menu Management'),
        drawer: isTablet ? null : const AppDrawer(),
        bottomNavigationBar: isTablet ? null : const BottomNav(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: kAccent,
          foregroundColor: Colors.black,
          onPressed: () {
            categoriesAsync.whenData((cats) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddItemSheet(categories: cats),
              );
            });
          },
          child: const Icon(Icons.add),
        ),
        body: Row(
          children: [
            if (isTablet) const SidebarNavigation(),
            Expanded(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTablet)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text('Menu Management', style: kHeadline.copyWith(fontSize: 28)),
                      ),
                    TabBar(
                      labelColor: kAccent,
                      unselectedLabelColor: kTextSecondary,
                      indicatorColor: kAccent,
                      tabs: const [
                        Tab(text: 'Menu Items'),
                        Tab(text: 'Categories'),
                      ],
                    ),
                    Expanded(
                      child: categoriesAsync.when(
                        data: (cats) => TabBarView(
                          children: [
                            MenuItemsTab(categories: cats),
                            const CategoriesTab(),
                          ],
                        ),
                        loading: () => Center(child: LoadingShimmer.list(count: 6)),
                        error: (err, __) => Center(child: Text('Error: $err')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
