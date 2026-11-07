/// An error from the job API with a message that is safe to show to the user.
class JobApiException implements Exception {
  const JobApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
