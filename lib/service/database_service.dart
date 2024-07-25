import 'package:chat_application/model/users_profile.dart';
import 'package:chat_application/service/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

class DatabaseService {
  final GetIt _getIt = GetIt.instance;
  late CollectionReference<UserProfile> _usersCollection; // Specify UserProfile type
  late AuthService _authService;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  DatabaseService() {
    _authService = _getIt.get<AuthService>();
    _setupCollectionPreferences();
  }

  void _setupCollectionPreferences() {
    _usersCollection = _firebaseFirestore.collection('users').withConverter<UserProfile>(
      fromFirestore: (snapshot, _) => UserProfile.fromJson(snapshot.data()!),
      toFirestore: (UserProfile userProfile, _) => userProfile.toJson(),
    );
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await _usersCollection.doc(userProfile.uid).set(userProfile);
  }

  Stream<DocumentSnapshot<UserProfile>> getUserProfile(String uid) {
    return _usersCollection.doc(uid).snapshots();
  }
}
