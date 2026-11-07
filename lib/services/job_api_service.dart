import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/job.dart';
import 'job_api_exception.dart';

/// Fetches job openings from the free Remotive public API (no key needed).
/// Remotive asks apps to credit them and link to each job, and to fetch
/// only a few times a day, which is why results are cached on the device.
class JobApiService {
  JobApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _endpoint = 'https://remotive.com/api/remote-jobs';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  Future<List<Job>> fetchJobs() async {
    try {
      final response = await _client
          .get(Uri.parse('$_endpoint?limit=100'))
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw JobApiException(
          'The job server returned an error (${response.statusCode}). '
          'Please try again in a moment.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const JobApiException('Unexpected response from the job server.');
      }

      final rawJobs = decoded['jobs'];
      if (rawJobs is! List) {
        return const <Job>[];
      }

      return rawJobs
          .whereType<Map<String, dynamic>>()
          .map(Job.fromJson)
          .toList();
    } on SocketException {
      throw const JobApiException(
        'No internet connection. Check your network and try again.',
      );
    } on http.ClientException {
      throw const JobApiException(
        'Could not reach the job server. Check your internet connection.',
      );
    } on TimeoutException {
      throw const JobApiException(
        'The request took too long. Please try again.',
      );
    } on FormatException {
      throw const JobApiException('Received data that could not be read.');
    }
  }
}
