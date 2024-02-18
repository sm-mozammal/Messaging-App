//
//
// class UserModel {
//   String uid;
//   String? name;
//   String email;
//   String? role;
//
//
//   UserModel(
//       {required this.uid,
//         this.name,
//         required this.email,
//         this.role,
//         });
//
//   Map<String, dynamic> toMap() {
//     return <String, dynamic> {
//       'uid' : uid,
//       'name' : name,
//       'email' : email,
//       'role' : role,
//     };
//   }
//
//   factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
//     uid: map['uid'],
//     name: map['name'],
//     email: map['email'],
//     role: map['role'],
//
//   );
// }