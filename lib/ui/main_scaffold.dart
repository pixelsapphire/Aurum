import 'package:aurum/ui/editors/record_editor.dart';
import 'package:aurum/ui/pages/dashboard/dashboard.dart';
import 'package:aurum/ui/pages/history/history.dart';
import 'package:aurum/ui/pages/more/more.dart';
import 'package:aurum/ui/pages/statistics/statistics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AurumScaffold extends StatelessWidget {
  const AurumScaffold({super.key});

  @override
  Widget build(BuildContext context) => CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: [
            const BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Dashboard'),
            const BottomNavigationBarItem(icon: Icon(CupertinoIcons.clock), label: 'History'),
            BottomNavigationBarItem(
              icon: IconButton(
                icon: const Icon(CupertinoIcons.add_circled, size: 40),
                onPressed: () => Navigator.of(context).push(
                  CupertinoModalPopupRoute(
                    builder: (context) => const SafeArea(
                      child: CupertinoPopupSurface(isSurfacePainted: false, child: RecordEditor()),
                    ),
                  ),
                ),
              ),
            ),
            const BottomNavigationBarItem(icon: Icon(CupertinoIcons.chart_bar), label: 'Statistics'),
            const BottomNavigationBarItem(icon: Icon(CupertinoIcons.ellipsis), label: 'More'),
          ],
        ),
        tabBuilder: (context, index) => {
          0: CupertinoTabView(builder: (context) => const Padding(padding: EdgeInsets.all(8.0), child: Dashboard())),
          1: CupertinoTabView(builder: (context) => const Padding(padding: EdgeInsets.all(8.0), child: History())),
          2: CupertinoTabView(builder: (context) => const SizedBox()),
          3: CupertinoTabView(builder: (context) => const Padding(padding: EdgeInsets.all(8.0), child: Statistics())),
          4: CupertinoTabView(builder: (context) => const Padding(padding: EdgeInsets.all(8.0), child: More())),
        }[index]!,
      );
}
