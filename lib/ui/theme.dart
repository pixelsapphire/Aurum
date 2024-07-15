import 'package:flutter/cupertino.dart';

class AurumColors {
  static Color foregroundPrimary(BuildContext context) => CupertinoDynamicColor.resolve(CupertinoColors.label, context);

  static Color foregroundSecondary(BuildContext context) =>
      CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, context);

  static Color foregroundTertiary(BuildContext context) =>
      CupertinoDynamicColor.resolve(CupertinoColors.tertiaryLabel, context);

  static Color backgroundPrimary(BuildContext context) =>
      CupertinoDynamicColor.resolve(CupertinoColors.systemBackground, context);

  static Color backgroundSecondary(BuildContext context) =>
      CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemBackground, context);

  static Color backgroundTertiary(BuildContext context) =>
      CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemBackground, context);

  static Color separator(BuildContext context) => CupertinoDynamicColor.resolve(CupertinoColors.separator, context);
}

extension AurumTextStyle on TextStyle {
  TextStyle appendedTo(TextStyle? base) => base?.merge(this) ?? this;
}
