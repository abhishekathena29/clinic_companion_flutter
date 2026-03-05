enum UserType {
  doctor('doctor'),
  patient('patient');

  const UserType(this.value);
  final String value;
}

extension UserTypeX on UserType {
  static UserType? tryParse(String? value) {
    switch (value) {
      case 'doctor':
        return UserType.doctor;
      case 'patient':
        return UserType.patient;
      default:
        return null;
    }
  }
}
