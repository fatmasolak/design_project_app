import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<String?> getUserTypeFromFirestore(String userId) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      return userSnapshot.get('User');
    } else {
      return 'Admin';
    }
  } catch (e) {
    print(e);
    return null;
  }
}

final currentUserTypeProvider = FutureProvider<String?>((ref) async {
  // Burada FirebaseAuth ile kullanıcı oturum durumunu kontrol edebilirsiniz ve gerekli kullanıcı ID'sini alabilirsiniz.
  final userId = FirebaseAuth.instance.currentUser!.uid;

  final userType = await getUserTypeFromFirestore(userId);

  return userType;
});
