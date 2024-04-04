import 'dart:io';

import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/shortcuts.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../widgets/linter_rules_builder.dart';

/// The main screen of the application.
class GenerateAnalysisOptionsScreen extends StatefulWidget {
  /// Create an instance.
  const GenerateAnalysisOptionsScreen({
    required this.filePath,
    super.key,
  });

  /// The path of the file to modify.
  final String filePath;

  /// Create state for this widget.
  @override
  GenerateAnalysisOptionsScreenState createState() =>
      GenerateAnalysisOptionsScreenState();
}

/// State for [GenerateAnalysisOptionsScreen].
class GenerateAnalysisOptionsScreenState
    extends State<GenerateAnalysisOptionsScreen> {
  /// The file to modify.
  File get file => File(widget.filePath);

  /// The rules to use.
  late final List<String> rules;

  /// The most recently selected rule name.
  String? _recentRule;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    final linter = getLinterOptions();
    final linterRules = linter['rules'] as YamlList;
    rules = linterRules.map((final element) => element as String).toList();
  }

  /// Get the linter options from [file].
  YamlMap getLinterOptions() {
    final yaml = getYaml();
    return yaml['linter'] as YamlMap;
  }

  /// Get YAML from [file].
  YamlMap getYaml() {
    final string = file.readAsStringSync();
    final yaml = loadYaml(string) as YamlMap;
    return yaml;
  }

  /// Build a widget.
  @override
  Widget build(final BuildContext context) => Cancel(
        child: CallbackShortcuts(
          bindings: {
            SingleActivator(
              LogicalKeyboardKey.keyS,
              control: useControlKey,
              meta: useMetaKey,
            ): save,
          },
          child: SimpleScaffold(
            title: 'Analysis Options',
            body: LinterRulesBuilder(
              builder: (final context, final linterRules) {
                if (linterRules.isEmpty) {
                  return const CenterText(
                    text: 'No rules could be loaded.',
                    autofocus: true,
                  );
                }
                linterRules.sort(
                  (final a, final b) => a.name.toLowerCase().compareTo(
                        b.name.toLowerCase(),
                      ),
                );
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: linterRules.length,
                  itemBuilder: (final context, final index) {
                    final rule = linterRules[index];
                    final ruleName = rule.name;
                    return CallbackShortcuts(
                      bindings: {
                        SingleActivator(
                          LogicalKeyboardKey.keyK,
                          control: useControlKey,
                          meta: useMetaKey,
                        ): () => launchUrl(rule.uri),
                      },
                      child: ListTile(
                        selected: rules.contains(ruleName),
                        onTap: () {
                          _recentRule = rule.name;
                          if (rules.contains(ruleName)) {
                            rules.remove(ruleName);
                          } else {
                            rules.add(ruleName);
                          }
                          setState(() {});
                        },
                        autofocus: _recentRule == null
                            ? index == 0
                            : rule.name == _recentRule,
                        title: Text(rule.description),
                        subtitle: Text(rule.name),
                      ),
                    );
                  },
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: save,
              tooltip: 'Save',
              child: const Icon(Icons.save_outlined),
            ),
          ),
        ),
      );

  /// Save [file].
  void save() {
    final yaml = getYaml();
    final map = Map.from(yaml);
    final linter = Map.from(getLinterOptions());
    rules.sort(
      (final a, final b) => a.toLowerCase().compareTo(b.toLowerCase()),
    );
    linter['rules'] = rules;
    map['linter'] = linter;
    final document = YamlWriter().write(map);
    file.writeAsStringSync(document);
  }
}
