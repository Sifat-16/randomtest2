class MyUser{
  String? username;
  String? uid;
  String? email;
  String? fullname;
  String? country;
  String? refarralid;
  String? profileimage;
  double balance=0;

  Map<String, dynamic> toJson()=>{
    "username":username,
    "uid":uid,
    "email":email,
    "fullname":fullname,
    "country":country,
    "refarralid":refarralid,
    "profileimage":profileimage,
    "balance":balance
  };
}