import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/constants/catalog.dart';
import '../../core/localization/l10n.dart';
import '../../core/widgets/screen_frame.dart';
import '../home/pickers.dart';

class WorldsScreen extends StatelessWidget {
  const WorldsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return ScreenFrame(
      title: '${context.l10n.worlds} ${app.worlds.length}/${Catalog.worlds.length}',
      child: const ContentWidth(maxWidth: 900, child: WorldGrid()),
    );
  }
}
