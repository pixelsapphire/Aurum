import 'dart:async';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/future_or_builder.dart';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

class CupertinoDropdownItem {
  final bool enabled;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? iconWidget;
  final bool isDestructive;

  const CupertinoDropdownItem({
    this.enabled = true,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.iconWidget,
    this.isDestructive = false,
  });
}

class CupertinoListItem<T> extends StatelessWidget {
  final String label;

  // CupertinoListItem.valueOnly & CupertinoListItem.dropdown only
  final FutureOr<String>? value;

  // CupertinoListItem.new & CupertinoListItem.custom only
  final FutureOr<void> Function()? onTap;

  // CupertinoListItem.dropdown only
  final Iterable<T>? dropdownItems;
  final CupertinoDropdownItem Function(T)? itemBuilder;
  final void Function(T)? onSelected;

  // CupertinoListItem.icon only
  final IconData? icon;
  final bool isDestructiveAction;

  // CupertinoListItem.custom only
  final Widget? trailing;
  final bool customShowChevron;

  const CupertinoListItem.basic({
    super.key,
    required this.label,
    this.value,
    this.onTap,
  })  : dropdownItems = null,
        itemBuilder = null,
        onSelected = null,
        icon = null,
        isDestructiveAction = false,
        trailing = null,
        customShowChevron = false;

  const CupertinoListItem.dropdown({
    super.key,
    required this.label,
    this.value,
    required this.dropdownItems,
    required this.itemBuilder,
    required this.onSelected,
  })  : onTap = null,
        icon = null,
        isDestructiveAction = false,
        trailing = null,
        customShowChevron = false;

  const CupertinoListItem.icon({
    super.key,
    required this.label,
    required this.icon,
    this.isDestructiveAction = false,
    this.onTap,
  })  : value = null,
        dropdownItems = null,
        itemBuilder = null,
        onSelected = null,
        trailing = null,
        customShowChevron = false;

  const CupertinoListItem.custom({
    super.key,
    required this.label,
    required Widget this.trailing,
    bool chevron = false,
    this.onTap,
  })  : value = null,
        dropdownItems = null,
        itemBuilder = null,
        onSelected = null,
        icon = null,
        isDestructiveAction = false,
        customShowChevron = chevron;

  Widget _createTile({
    required BuildContext context,
    required String label,
    FutureOr<String>? value,
    Widget? trailing,
    FutureOr<void> Function()? onTap,
  }) =>
      CupertinoListTile(
        title: Row(
          children: [
            Text(label, style: TextStyle(color: isDestructiveAction ? CupertinoColors.systemRed : null)),
            if (value != null)
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FutureOrBuilder(
                      future: value,
                      builder: (context, text) => Text(
                        text.data ?? '',
                        style: TextStyle(color: AurumColors.foregroundSecondary(context)),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        trailing: trailing,
        onTap: onTap,
      );

  Widget _buildDefault(BuildContext context) => _createTile(
        context: context,
        label: label,
        value: value,
        trailing: icon != null
            ? Icon(icon, color: isDestructiveAction ? CupertinoColors.systemRed : AurumColors.foregroundPrimary(context))
            : trailing ?? const CupertinoListTileChevron(),
        onTap: onTap,
      );

  Widget _buildDropdown(BuildContext context) {
    final GlobalKey chevronKey = GlobalKey();
    return _createTile(
      context: context,
      label: label,
      value: value,
      trailing: CupertinoListTileChevron(key: chevronKey),
      onTap: () => showPullDownMenu(
        context: context,
        items: dropdownItems!.map((type) {
          final CupertinoDropdownItem itemParams = itemBuilder!(type);
          return PullDownMenuItem(
            enabled: itemParams.enabled,
            title: itemParams.title,
            subtitle: itemParams.subtitle,
            icon: itemParams.icon,
            iconColor: itemParams.iconColor,
            iconWidget: itemParams.iconWidget,
            isDestructive: itemParams.isDestructive,
            onTap: () => onSelected!(type),
          );
        }).toList(),
        position: (chevronKey.currentContext!.findRenderObject() as RenderBox).bottomRight.translate(-2, 8),
        scrollController: ScrollController(),
      ),
    );
  }

  Widget _buildCustomWithChevron(BuildContext context) => _createTile(
        context: context,
        label: label,
        value: value,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [trailing!, const Padding(padding: EdgeInsets.only(left: 4), child: CupertinoListTileChevron())],
        ),
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context) {
    if (dropdownItems != null) return _buildDropdown(context);
    if (customShowChevron) return _buildCustomWithChevron(context);
    return _buildDefault(context);
  }
}
