import 'package:autograde_mobile/core/api/models/deserializable.dart';
import 'package:autograde_mobile/core/api/models/serializable.dart';
import 'package:autograde_mobile/core/utils/user_type.dart';

class UserModel implements Deserializable, Serializable {
  UserModel({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.athlete,
    this.coach,
    this.type,
    this.parent,
    // Profile
    this.postsCount,
    this.followersCount,
    this.followingCount,
    this.currentUserFollowing,
  });

  UserModel.fromJson(Map<String, dynamic> json)
    : this(
        id: json['id'] as int?,
        name: json['name'] as String?,
        email: json['email'] as String?,
        phoneNumber: json['phone'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        athlete: json['athlete_user'] == null
            ? null
            : AthleteModel.fromJson(
                json['athlete_user'] as Map<String, dynamic>,
              ),
        coach: json['coach_user'] == null
            ? null
            : CoachModel.fromJson(json['coach_user'] as Map<String, dynamic>),
        parent: json['parent_user'] == null
            ? null
            : ParentModel.fromJson(json['parent_user'] as Map<String, dynamic>),
        type: json['user_type'] == null
            ? null
            : UserType.fromString(json['user_type'] as String),
        postsCount: json['posts_count'] as int?,
        followersCount: json['followers_count'] as int?,
        followingCount: json['following_count'] as int?,
        currentUserFollowing: json['current_user_following'] == null
            ? null
            : json['current_user_following'] as bool,
      );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phoneNumber,
    'avatar_url': avatarUrl,
    'athlete': athlete,
    'coach': coach,
    'user_type': type?.value,
    'parent_user': parent?.toJson(),
    'athlete_user': athlete?.toJson(),
    'coach_user': coach?.toJson(),
    'posts_count': postsCount,
    'followers_count': followersCount,
    'following_count': followingCount,
    'current_user_following': currentUserFollowing,
  };

  final int? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? avatarUrl;
  final AthleteModel? athlete;
  final CoachModel? coach;
  final UserType? type;
  final ParentModel? parent;
  // Profile
  final int? postsCount;
  final int? followersCount;
  final int? followingCount;
  final bool? currentUserFollowing;
}

class CoachModel implements Deserializable, Serializable {
  CoachModel({
    this.id,
    this.name,
    this.userId,
    this.headline,
    this.createdAt,
    this.updatedAt,
    // this.coachSlots,
    this.user,
  });

  CoachModel.fromJson(Map<String, dynamic> json)
    : this(
        id: json['id'] as int?,
        name: json['name'] as String?,
        userId: json['user_id'] == null ? null : json['user_id'] as int?,
        headline: json['headline'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        // coachSlots: json['calendar_slots'] == null
        //     ? null
        //     : (json['calendar_slots'] as List)
        //         .map((e) => CoachAvailabilityResponseModel.fromJson(e as Map<String, dynamic>))
        //         .toList(),
        user: json['user'] == null
            ? null
            : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'user_id': userId,
    'headline': headline,
    'user': user?.toJson(),
  };

  final int? id;
  String? name;
  final int? userId;
  String? headline;
  final String? createdAt;
  final String? updatedAt;
  // final List<CoachAvailabilityResponseModel>? coachSlots;
  final UserModel? user;
}

class AthleteModel implements Deserializable, Serializable {
  AthleteModel({
    this.id,
    this.name,
    this.userId,
    this.headline,
    this.createdAt,
    this.updatedAt,
  });

  AthleteModel.fromJson(Map<String, dynamic> json)
    : this(
        id: json['id'] as int?,
        name: json['name'] as String?,
        userId: json['user_id'] == null ? null : json['user_id'] as int?,
        headline: json['headline'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {'id': id, 'headline': headline};

  final int? userId;
  final int? id;
  final String? name;
  String? headline;
  final String? createdAt;
  final String? updatedAt;
}

class ParentModel implements Deserializable, Serializable {
  ParentModel({
    this.id,
    this.userId,
    this.headline,
    this.createdAt,
    this.updatedAt,
  });

  ParentModel.fromJson(Map<String, dynamic> json)
    : this(
        id: json['id'] as int?,
        userId: json['user_id'] == null ? null : json['user_id'] as int?,
        headline: json['headline'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'headline': headline,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  final int? id;
  final int? userId;
  String? headline;
  final String? createdAt;
  final String? updatedAt;
}
