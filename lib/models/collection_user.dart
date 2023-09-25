import 'dart:convert';

class CollectionUser {
  final String uid;
  final String email;
  final String? college;
  final String? highestDegree;
  final bool isAdmin;
  final String? name;
  final String? phoneNumber;
  final String? resume;
  final String? workingStatus;
  final String? yearsOfExperience;
  final String? appliedPosition;
  final String? jobReference;
  final String? currentLocation;
  final String? noticePeriod;
  final String? currentAnnualCTC;
  final String? expectedAnnualCTC;
  final String? reasonForJobChange;

  const CollectionUser({
    required this.uid,
    required this.email,
    this.college,
    this.highestDegree,
    required this.isAdmin,
    this.name,
    this.phoneNumber,
    this.resume,
    this.workingStatus,
    this.yearsOfExperience,
    this.appliedPosition,
    this.jobReference,
    this.currentLocation,
    this.noticePeriod,
    this.currentAnnualCTC,
    this.expectedAnnualCTC,
    this.reasonForJobChange,
  });

  dynamic toJson() => {
        'uid': uid,
        'email': email,
        'college': college,
        'highestDegree': highestDegree,
        'isAdmin': isAdmin,
        'name': name,
        'phoneNumber': phoneNumber,
        'resume': resume,
        'workingStatus': workingStatus,
        'yearsOfExperience': yearsOfExperience,
        'appliedPosition': appliedPosition,
        'jobReference': jobReference,
        'currentLocation': currentLocation,
        'noticePeriod': noticePeriod,
        'currentAnnualCTC': currentAnnualCTC,
        'expectedAnnualCTC': expectedAnnualCTC,
        'reasonForJobChange': reasonForJobChange,
      };

  factory CollectionUser.fromJson(Map<String, dynamic> json) {
    return CollectionUser(
      uid: json['uid'],
      email: json['email'],
      college: json['college'],
      highestDegree: json['highestDegree'],
      isAdmin: json['isAdmin'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      resume: json['resume'],
      workingStatus: json['workingStatus'],
      yearsOfExperience: json['yearsOfExperience'],
      appliedPosition: json['appliedPosition'],
      jobReference: json['jobReference'],
      currentLocation: json['currentLocation'],
      noticePeriod: json['noticePeriod'],
      currentAnnualCTC: json['currentAnnualCTC'],
      expectedAnnualCTC: json['expectedAnnualCTC'],
      reasonForJobChange: json['reasonForJobChange'],
    );
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent(' ').convert(this);
  }
}
