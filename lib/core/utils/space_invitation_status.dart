enum SpaceInvitationStatus {
  pending("pending"),
  accepted("accepted"),
  rejected("rejected");

  final String value;

  const SpaceInvitationStatus(this.value);

  factory SpaceInvitationStatus.fromString(String status) {
    if (status == pending.value) {
      return SpaceInvitationStatus.pending;
    } else if (status == accepted.value) {
      return SpaceInvitationStatus.accepted;
    } else if (status == rejected.value) {
      return SpaceInvitationStatus.rejected;
    } else {
      return SpaceInvitationStatus.pending; // Default value
    }
  }

  String getLabel() {
    switch (this) {
      case SpaceInvitationStatus.pending:
        return "Pending";
      case SpaceInvitationStatus.accepted:
        return "Accepted";
      case SpaceInvitationStatus.rejected:
        return "Rejected";
    }
  }
}
