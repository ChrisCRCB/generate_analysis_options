/// A linter rule.
class LinterRule {
  /// Create an instance.
  LinterRule({
    required this.name,
    required this.description,
    required this.uri,
  });

  /// The name of the rule.
  final String name;

  /// The description of this rule.
  final String description;

  /// The URL for this rule.
  final Uri uri;
}
