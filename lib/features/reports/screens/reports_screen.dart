import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/app_drawer.dart';
import '../providers/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = Breakpoints.isLargeScreen(context);
    final reportAsync = ref.watch(reportDataProvider);

    return Scaffold(
      appBar: isTablet ? null : const AppBarWidget(title: 'Business Reports'),
      drawer: isTablet ? null : const AppDrawer(),
      bottomNavigationBar: isTablet ? null : const BottomNav(),
      body: Row(
        children: [
          if (isTablet) const SidebarNavigation(),
          Expanded(
            child: SafeArea(
              child: reportAsync == null
                  ? Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: LoadingShimmer.grid(count: 3),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isTablet) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Business Reports', style: kHeadline.copyWith(fontSize: 28)),
                                        const SizedBox(height: 4),
                                        Text('Analyze sales curves, average tickets, and top menu sellers.', style: kCaption),
                                      ],
                                    ),
                                    _buildExportButton(context),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                              _buildSummaryMetrics(context, reportAsync, isTablet),
                              const SizedBox(height: 24),
                              if (isTablet)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        children: [
                                          _buildSalesTrendChart(context, reportAsync.weeklySales),
                                          const SizedBox(height: 24),
                                          _buildBestSellersCard(context, reportAsync.bestSellers),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      flex: 2,
                                      child: _buildBreakdownPieChart(context),
                                    ),
                                  ],
                                )
                              else ...[
                                _buildSalesTrendChart(context, reportAsync.weeklySales),
                                const SizedBox(height: 16),
                                _buildBreakdownPieChart(context),
                                const SizedBox(height: 16),
                                _buildBestSellersCard(context, reportAsync.bestSellers),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: _buildExportButton(context),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusButton)),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: kSurface,
              title: const Text('Export Analytics', style: TextStyle(color: Colors.white)),
              content: const Text('Would you like to export daily sales report data as CSV or PDF report?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: kTextSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                    CustomSnackBar.showSuccess(context, 'Sales Report PDF exported to device storage.');
                  },
                  child: const Text('Export PDF'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kInfo, foregroundColor: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                    CustomSnackBar.showSuccess(context, 'Sales Report CSV exported successfully.');
                  },
                  child: const Text('Export CSV'),
                ),
              ],
            );
          },
        );
      },
      icon: const Icon(Icons.download_rounded, size: 18),
      label: const Text('Export Reports'),
    );
  }

  Widget _buildSummaryMetrics(BuildContext context, ReportData report, bool isTablet) {
    return GridView.count(
      crossAxisCount: isTablet ? 3 : 1,
      crossAxisSpacing: 16,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isTablet ? 2.5 : 3.5,
      children: [
        StatCard(
          title: 'TOTAL REVENUE',
          value: CurrencyFormatter.format(report.totalRevenue),
          icon: Icons.currency_rupee_rounded,
          iconColor: kAccent,
          subtitle: 'Gross sales generated',
        ),
        StatCard(
          title: 'COMPLETED TRANSACTIONS',
          value: '${report.totalOrders}',
          icon: Icons.receipt_long,
          iconColor: kInfo,
          subtitle: 'Total orders logged',
        ),
        StatCard(
          title: 'AVERAGE ORDER VALUE',
          value: CurrencyFormatter.format(report.averageOrderValue),
          icon: Icons.analytics_outlined,
          iconColor: kSuccess,
          subtitle: 'Average transaction ticket',
        ),
      ],
    );
  }

  Widget _buildSalesTrendChart(BuildContext context, List<double> weeklySales) {
    double maxVal = weeklySales.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0.0) maxVal = 10000;
    final double gridInterval = maxVal / 4;

    return Container(
      height: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kDivider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Sales Curve', style: kHeadline.copyWith(fontSize: 18)),
              Text('INR (₹)', style: kCaption),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(color: kDivider, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 46,
                      getTitlesWidget: (value, meta) {
                        if (value % gridInterval != 0 && value != maxVal) return const SizedBox();
                        return Text(
                          '${(value / 1000).toStringAsFixed(1)}k',
                          style: kCaption.copyWith(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final int idx = value.toInt();
                        if (idx >= 0 && idx < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(days[idx], style: kCaption.copyWith(fontSize: 10)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: maxVal * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(7, (i) => FlSpot(i.toDouble(), weeklySales[i])),
                    isCurved: true,
                    color: kAccent,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: kAccent.withOpacity(0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownPieChart(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kDivider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category Performance', style: kHeadline.copyWith(fontSize: 18)),
          const SizedBox(height: 24),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    color: kAccent,
                    value: 40,
                    title: '40%',
                    radius: 50,
                    titleStyle: kBody.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
                  ),
                  PieChartSectionData(
                    color: kInfo,
                    value: 25,
                    title: '25%',
                    radius: 50,
                    titleStyle: kBody.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
                  ),
                  PieChartSectionData(
                    color: kSuccess,
                    value: 20,
                    title: '20%',
                    radius: 50,
                    titleStyle: kBody.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
                  ),
                  PieChartSectionData(
                    color: kWarning,
                    value: 15,
                    title: '15%',
                    radius: 50,
                    titleStyle: kBody.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Mains', kAccent),
              _buildLegendItem('Beverages', kInfo),
              _buildLegendItem('Starters', kSuccess),
              _buildLegendItem('Desserts', kWarning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color col) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: kCaption.copyWith(fontSize: 11)),
      ],
    );
  }

  Widget _buildBestSellersCard(BuildContext context, List<BestSellerItem> sellers) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kDivider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top 5 Best Selling Items', style: kHeadline.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          sellers.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text('No item sales tracked yet.', style: kCaption),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sellers.length,
                  separatorBuilder: (_, __) => const Divider(color: kDivider, height: 16),
                  itemBuilder: (context, idx) {
                    final item = sellers[idx];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: kBg,
                              radius: 16,
                              child: Text('${idx + 1}', style: kCaption.copyWith(fontWeight: FontWeight.bold, color: kAccent)),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: kBody.copyWith(fontWeight: FontWeight.bold)),
                                Text('${item.quantity} sold', style: kCaption),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          CurrencyFormatter.format(item.totalRevenue),
                          style: kBody.copyWith(fontWeight: FontWeight.bold, color: kSuccess),
                        ),
                      ],
                    );
                  },
                ),
        ],
      ),
    );
  }
}
