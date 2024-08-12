import 'package:aurum/data/database.dart';
import 'package:aurum/ui/pages/page_base.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/placeholder.dart';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_down_button/pull_down_button.dart';

enum EntryType { command, response, data, error }

final List<(EntryType, dynamic)> _log = [];

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

  Widget _buildWarning(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) => EmptyListPlaceholder(
            icon: Icons.warning_amber_outlined,
            title: 'Warning',
            message: SizedBox(
              width: constraints.maxWidth,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'The database console is a powerful tool meant primarily for debugging purposes. '
                                  'You should only proceed if you know what you are doing. Otherwise ',
                            ),
                            TextSpan(
                              text: 'you may accidentally damage or delete your data permanently',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: '.')
                          ],
                        ),
                      ),
                    ),
                    Text('Enter \'help\' to get started.'),
                  ],
                ),
              ),
            ),
          ));

  Widget _buildLog(BuildContext context) => ListView.builder(
        itemCount: _log.length,
        itemBuilder: (context, index) {
          final (type, result) = _log[index];
          final Color color = type == EntryType.error ? CupertinoColors.systemRed : AurumColors.foregroundPrimary(context);
          if (type == EntryType.command) {
            return Row(
              children: [
                Icon(CupertinoIcons.right_chevron, size: 24, color: color),
                Expanded(
                  child: Container(
                    color: AurumColors.backgroundTertiary(context),
                    child: Padding(padding: const EdgeInsets.all(2), child: _ConsoleMessage(result)),
                  ),
                ),
              ],
            );
          } else if (type == EntryType.data) {
            return Padding(
              padding: const EdgeInsets.only(left: 10),
              child: DecoratedBox(
                decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 4))),
                child: Padding(padding: const EdgeInsets.only(left: 14), child: _DataTable(result)),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(left: 10),
              child: DecoratedBox(
                decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 4))),
                child: Padding(padding: const EdgeInsets.only(left: 14), child: _ConsoleMessage(result, color: color)),
              ),
            );
          }
        },
      );

  Widget _buildInput(BuildContext context) => Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(CupertinoIcons.right_chevron, size: 20, color: AurumColors.foregroundSecondary(context)),
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
                    (result) => setState(() => _log.add((result is String ? EntryType.response : EntryType.data, result))),
                    onError: (error) => setState(() => _log.add((EntryType.error, error.toString()))),
                  );
                }
                _inputController.clear();
              });
            },
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => PageBase(
        builtInScrollView: false,
        navigationBar: const CupertinoNavigationBar(middle: Text('Database console')),
        child: Column(
          children: [
            Expanded(child: _log.isNotEmpty ? _buildLog(context) : _buildWarning(context)),
            _buildInput(context),
          ],
        ),
      );
}

class _ConsoleMessage extends StatefulWidget {
  final String text;
  final Color? color;

  const _ConsoleMessage(this.text, {this.color});

  @override
  State<_ConsoleMessage> createState() => _ConsoleMessageState();
}

class _ConsoleMessageState extends State<_ConsoleMessage> {
  final FocusNode _selectableNode = FocusNode();
  final GlobalKey _key = GlobalKey();
  bool _selectable = false;

  @override
  Widget build(BuildContext context) => SizedBox(
        key: _key,
        child: _selectable
            ? Focus(
                focusNode: _selectableNode,
                child: DecoratedBox(
                  decoration: BoxDecoration(border: Border.all(color: AurumColors.foregroundSecondary(context), width: 1)),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: SelectableText(widget.text, style: TextStyle(color: widget.color)),
                  ),
                ),
                onFocusChange: (focus) => setState(() => _selectable = focus),
              )
            : GestureDetector(
                onLongPress: () async {
                  showPullDownMenu(
                    context: context,
                    items: [
                      PullDownMenuItem(
                        title: 'Copy',
                        icon: CupertinoIcons.doc_on_clipboard,
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: widget.text));
                          HapticFeedback.lightImpact();
                        },
                      ),
                      PullDownMenuItem(
                        title: 'Select',
                        icon: CupertinoIcons.text_cursor,
                        onTap: () => setState(() {
                          _selectable = true;
                          _selectableNode.requestFocus();
                        }),
                      )
                    ],
                    position: (_key.currentContext!.findRenderObject() as RenderBox).bottomRight.translate(-2, 8),
                  );
                  await HapticFeedback.heavyImpact();
                },
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(widget.text, style: TextStyle(color: widget.color)),
                ),
              ),
      );
}

class _DataTable extends StatelessWidget {
  final List<Map<String, Object?>> data;

  const _DataTable(this.data);

  @override
  Widget build(BuildContext context) {
    final List<DataColumn> columns = data.first.keys.map((c) => DataColumn(label: Text(c))).toList();
    final List<DataRow> rows =
        data.map((r) => DataRow(cells: r.values.map((v) => DataCell(Text(v.toString()))).toList())).toList();
    final TextStyle style = CupertinoTheme.of(context).textTheme.textStyle;
    final double rowHeight = style.fontSize! + 12;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns,
        rows: rows,
        headingTextStyle: style.copyWith(fontWeight: FontWeight.bold),
        dataTextStyle: style,
        dataRowMinHeight: rowHeight,
        dataRowMaxHeight: rowHeight,
        headingRowHeight: rowHeight,
      ),
    );
  }
}
