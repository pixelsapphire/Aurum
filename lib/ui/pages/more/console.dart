import 'package:aurum/data/database.dart';
import 'package:aurum/ui/pages/page_base.dart';
import 'package:aurum/ui/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum EntryType { command, response, error }

final List<(EntryType, String)> _log = [];

class Console extends StatefulWidget {
  const Console({super.key});

  @override
  State<Console> createState() => _ConsoleState();
}

class _ConsoleState extends State<Console> {
  final TextEditingController _inputController = TextEditingController();

  bool _execute(String command) {
    if (command == 'help') {
      _log.add((
        EntryType.response,
        'Any SQLite select, DML & DDL commands can be executed. Standard SQLite syntax applies. '
            'On application startup, a basic integrity check is performed so any missing tables will be re-generated '
            'and any additional tables will be removed. SQLite dot-commands are not supported.'
            '''
\nList of additional Aurum commands:
- clear: clears the console
- help: displays this help message
- reload: refreshes all collections (this is needed after manual changes in the database)''',
      ));
      return true;
    } else if (command == 'clear') {
      setState(() => _log.clear());
      return true;
    } else if (command == 'reload') {
      AurumDatabase.refreshAll();
      _log.add((EntryType.response, 'All collections have been refreshed'));
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => PageBase(
        builtInScrollView: false,
        navigationBar: const CupertinoNavigationBar(middle: Text('Database console')),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _log.length,
                itemBuilder: (context, index) {
                  final (type, text) = _log[index];
                  final Color color =
                      type == EntryType.error ? CupertinoColors.systemRed : AurumColors.foregroundPrimary(context);
                  if (type == EntryType.command) {
                    return Row(
                      children: [
                        Icon(CupertinoIcons.right_chevron, size: 24, color: color),
                        Expanded(
                          child: Container(
                            color: AurumColors.backgroundTertiary(context),
                            child: Padding(padding: const EdgeInsets.all(2), child: SelectableText(text)),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: DecoratedBox(
                        decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 4))),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: SelectableText(text, style: TextStyle(color: color)),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(CupertinoIcons.right_chevron, size: 20, color: AurumColors.foregroundPrimary(context)),
                ),
                Expanded(
                  child: CupertinoTextField(
                    controller: _inputController,
                    placeholder: 'Enter command',
                    style: const TextStyle(fontSize: 24),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                CupertinoButton(
                  child: const Text('Execute'),
                  onPressed: () {
                    setState(() {
                      if (_inputController.text.isEmpty) return;
                      _log.add((EntryType.command, _inputController.text));
                      final bool handled = _execute(_inputController.text);
                      if (!handled) {
                        AurumDatabase.executeRaw(_inputController.text).then(
                          (response) => setState(() => _log.add((EntryType.response, response))),
                          onError: (error) => setState(() => _log.add((EntryType.error, error.toString()))),
                        );
                      }
                      _inputController.clear();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      );
}
