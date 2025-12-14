enum UserType {
  parent("parent"),
  coach("coach"),
  athlete("athlete");

  final String value;

  const UserType(this.value);

  factory UserType.fromString(String type) {
    if (type == parent.value) {
      return UserType.parent;
    } else if (type == coach.value) {
      return UserType.coach;
    } else if (type == athlete.value) {
      return UserType.athlete;
    } else {
      return UserType.parent; // Default value
    }
  }

  String getLabel() {
    switch (this) {
      case UserType.parent:
        return "Parent";
      case UserType.coach:
        return "Coach";
      case UserType.athlete:
        return "Athlete";
    }
  }
}
