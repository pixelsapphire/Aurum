import 'package:flutter/cupertino.dart';

class PageBase extends StatelessWidget {
  final Widget child;
  final CupertinoNavigationBar? navigationBar;
  final bool builtInScrollView;

  const PageBase({super.key, this.navigationBar, required this.child, this.builtInScrollView = true});

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
        navigationBar: navigationBar,
        child: SafeArea(
          child: builtInScrollView ? SingleChildScrollView(physics: const BouncingScrollPhysics(), child: child) : child,
        ),
      );
}
