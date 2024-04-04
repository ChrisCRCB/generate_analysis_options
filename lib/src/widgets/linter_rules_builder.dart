import 'package:backstreets_widgets/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';

import '../linter_rule.dart';

/// A widget which builds a list of linter rules scraped from [https://dart.dev/tools/linter-rules].
class LinterRulesBuilder extends StatelessWidget {
  /// Create an instance.
  const LinterRulesBuilder({
    required this.builder,
    super.key,
  });

  /// The builder function to use.
  final Widget Function(BuildContext context, List<LinterRule> linterRules)
      builder;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) {
    final future = loadRules();
    return SimpleFutureBuilder(
      future: future,
      done: (final futureContext, final value) =>
          builder(futureContext, value ?? []),
      loading: (final context) => const LoadingWidget(),
      error: ErrorListView.withPositional,
    );
  }

  /// Load the rules.
  Future<List<LinterRule>> loadRules() async {
    final http = Dio();
    final response = await http.get<String>(
      'https://dart.dev/tools/linter-rules',
    );
    final source = response.data!;
    final html = parse(source);
    final codes = html.getElementsByTagName('a').where((final element) {
      final href = element.attributes['href'];
      final isRule = href?.startsWith('/tools/linter-rules') ?? false;
      return element.getElementsByTagName('code').length == 1 && isRule;
    });
    return codes.map((final e) {
      final href = e.attributes['href']!;
      final url = 'https://dart.dev$href';
      final parentHtml = e.parent?.innerHtml ?? e.parent.toString();
      final lines = parentHtml.split('<br>');
      final description =
          lines.last.replaceAll('<code>', '`').replaceAll('</code>', '`');
      return LinterRule(
        name: e.text,
        description: description,
        uri: Uri.parse(url),
      );
    }).toList();
  }
}
