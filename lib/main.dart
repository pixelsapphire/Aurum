import 'package:aurum/ui/main_scaffold.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const Aurum());
}

class Aurum extends StatelessWidget {
  const Aurum({super.key});

  @override
  Widget build(BuildContext context) => const CupertinoApp(
        debugShowCheckedModeBanner: false,
        title: 'Aurum',
        theme: CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: CupertinoColors.systemBlue,
          applyThemeToAll: true,
        ),
        home: AurumScaffold(),
      );
}
