import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/util.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'generate_analysis_options_screen.dart';

/// The main screen for the application.
class MainScreen extends StatefulWidget {
  /// Create an instance.
  const MainScreen({
    super.key,
  });

  /// Create state for this widget.
  @override
  MainScreenState createState() => MainScreenState();
}

/// State for [MainScreen].
class MainScreenState extends State<MainScreen> {
  /// Build a widget.
  @override
  Widget build(final BuildContext context) => CommonShortcuts(
        openCallback: openFile,
        child: SimpleScaffold(
          title: 'Select File',
          body: ElevatedButton(
            onPressed: openFile,
            autofocus: true,
            child: const Icon(
              Icons.file_open_outlined,
              semanticLabel: 'Open File',
            ),
          ),
        ),
      );

  /// Open a file.
  Future<void> openFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['yaml'],
      dialogTitle: 'Open File',
      type: FileType.custom,
    );
    if (result == null || result.count == 0) {
      return;
    }
    final filePath = result.paths.single;
    if (filePath == null) {
      if (mounted) {
        await showMessage(context: context, message: 'Unable to open file.');
      }
      return;
    }
    if (mounted) {
      await context.pushWidgetBuilder(
        (final context) => GenerateAnalysisOptionsScreen(filePath: filePath),
      );
    }
  }
}
