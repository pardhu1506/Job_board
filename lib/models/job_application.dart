enum ApplicationStatus {
  applied('Applied'),
  interview('Interview'),
  offer('Offer'),
  rejected('Rejected');

  const ApplicationStatus(this.label);

  final String label;

  static ApplicationStatus fromJson(Object? value) {
    return ApplicationStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ApplicationStatus.applied,
    );
  }
}

/// An application the user filled in for a job. Saved on the device.
class JobApplication {
  const JobApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.company,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.experience,
    required this.coverLetter,
    required this.appliedAt,
    this.status = ApplicationStatus.applied,
  });

  final String id;
  final int jobId;
  final String jobTitle;
  final String company;
  final String fullName;
  final String email;
  final String phone;
  final String experience;
  final String coverLetter;
  final DateTime appliedAt;
  final ApplicationStatus status;

  JobApplication copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? experience,
    String? coverLetter,
    ApplicationStatus? status,
  }) {
    return JobApplication(
      id: id,
      jobId: jobId,
      jobTitle: jobTitle,
      company: company,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      experience: experience ?? this.experience,
      coverLetter: coverLetter ?? this.coverLetter,
      appliedAt: appliedAt,
      status: status ?? this.status,
    );
  }

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] as String,
      jobId: json['jobId'] as int,
      jobTitle: json['jobTitle'] as String,
      company: json['company'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      experience: json['experience'] as String,
      coverLetter: json['coverLetter'] as String,
      appliedAt: DateTime.parse(json['appliedAt'] as String),
      status: ApplicationStatus.fromJson(json['status']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'jobId': jobId,
    'jobTitle': jobTitle,
    'company': company,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'experience': experience,
    'coverLetter': coverLetter,
    'appliedAt': appliedAt.toIso8601String(),
    'status': status.name,
  };
}
