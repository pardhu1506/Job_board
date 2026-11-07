import '../services/date_formatter.dart';

/// One job opening. Built from the Remotive API response.
class Job {
  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.category,
    required this.type,
    required this.location,
    required this.salary,
    required this.description,
    required this.url,
    required this.tags,
    this.publishedAt,
  });

  final int id;
  final String title;
  final String company;
  final String category;
  final String type;
  final String location;
  final String salary;
  final String description;
  final String url;
  final List<String> tags;
  final DateTime? publishedAt;

  factory Job.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    return Job(
      id: _asInt(json['id']),
      title: _clean(json['title'], 'Untitled role'),
      company: _clean(json['company_name'], 'Unknown company'),
      category: _clean(json['category'], 'General'),
      type: _clean(json['job_type'], 'other'),
      location: _clean(json['candidate_required_location'], 'Anywhere'),
      salary: _clean(json['salary'], ''),
      description: _stripHtml(json['description']?.toString() ?? ''),
      url: _clean(json['url'], ''),
      tags: rawTags is List
          ? rawTags
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList()
          : const <String>[],
      publishedAt: DateTime.tryParse(
        json['publication_date']?.toString() ?? '',
      ),
    );
  }

  /// Uses the same keys as the API so the cache can be read by fromJson.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'company_name': company,
    'category': category,
    'job_type': type,
    'candidate_required_location': location,
    'salary': salary,
    'description': description,
    'url': url,
    'tags': tags,
    'publication_date': publishedAt?.toIso8601String(),
  };

  String get typeLabel => labelForType(type);

  String get postedDate =>
      publishedAt == null ? 'Date not available' : formatDate(publishedAt!);

  String get postedLabel {
    final date = publishedAt;
    if (date == null) return 'Date not available';
    final days = DateTime.now().difference(date).inDays;
    if (days <= 0) return 'Posted today';
    if (days == 1) return 'Posted yesterday';
    if (days < 30) return 'Posted $days days ago';
    return 'Posted ${formatDate(date)}';
  }

  static String labelForType(String type) {
    switch (type) {
      case 'full_time':
        return 'Full-time';
      case 'part_time':
        return 'Part-time';
      case 'contract':
        return 'Contract';
      case 'freelance':
        return 'Freelance';
      case 'internship':
        return 'Internship';
      case 'other':
        return 'Other';
      default:
        final words = type.replaceAll('_', ' ').trim();
        if (words.isEmpty) return 'Other';
        return words[0].toUpperCase() + words.substring(1);
    }
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _clean(Object? value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String _stripHtml(String html) {
    var text = html
        .replaceAll(RegExp(r'<\s*br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(
          RegExp(r'</\s*(p|div|h[1-6]|ul|ol)\s*>', caseSensitive: false),
          '\n\n',
        )
        .replaceAll(RegExp(r'<\s*li[^>]*>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'</\s*li\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&');
    text = text
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n[ \t]+'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return text.trim();
  }
}
