import 'package:flutter/material.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/configuration.dart';
import 'package:harmonoid/utils/widgets.dart';

class EnableNewLayoutSetting extends StatefulWidget {
  const EnableNewLayoutSetting({super.key});

  @override
  State<EnableNewLayoutSetting> createState() => _EnableNewLayoutSettingState();
}

class _EnableNewLayoutSettingState extends State<EnableNewLayoutSetting> {
  @override
  Widget build(BuildContext context) {
    return CorrectedSwitchListTile(
      title:
          "${Language.instance.USE_MODERN_LAYOUT} (${Language.instance.REQUIRES_APP_RESTART})",
      subtitle: Language.instance.USE_MODERN_LAYOUT_SUBTITLE,
      onChanged: (_) => Configuration.instance
          .save(
            isModernLayout: !Configuration.instance.isModernLayout,
          )
          .then((value) => setState(() {})),
      value: Configuration.instance.isModernLayout,
    );
  }
}
