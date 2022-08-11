

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:test2/firebase_options.dart';
import 'package:test2/usermodel.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: LoginSignup(),
    );
  }
}

class LoginSignup extends StatefulWidget {
  const LoginSignup({Key? key}) : super(key: key);

  @override
  State<LoginSignup> createState() => _LoginSignupState();
}

class _LoginSignupState extends State<LoginSignup> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: auth.authStateChanges(),
        builder: (context, snaphot) {

          if(snaphot.connectionState==ConnectionState.active){
            if(snaphot.hasData){
              return MainScreen();
            }else if(snaphot.hasError){
              return Center(child: Text("Error"),);
            }
          }
          if(snaphot.connectionState==ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: email,
                  decoration: InputDecoration(
                    hintText: "email",
                    border: OutlineInputBorder()
                  ),
                ),
                TextField(
                  controller: password,
                  decoration: InputDecoration(
                      hintText: "password",
                      border: OutlineInputBorder()
                  ),
                ),
                ElevatedButton(onPressed: ()async{

                  var x = await auth.signInWithEmailAndPassword(email: email.text.trim(), password: password.text.trim());
                  print(x.user?.email);


                }, child: Text("Login")),
                ElevatedButton(onPressed: (){
                    //auth.createUserWithEmailAndPassword(email: email.text.trim(), password: password.text.trim());
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProfileScreen()));

                }, child: Text("Signup")),

              ],
            ),
          );
        }
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    print(auth.currentUser?.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            auth.signOut();
          }, icon: Icon(Icons.logout)),
          IconButton(onPressed: (){
              //Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ProfileScreen()));
          }, icon: Icon(Icons.person)),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController fullname = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController refarralid = TextEditingController();
  TextEditingController password = TextEditingController();
  File? imagefile;
  String? fileName;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: () async{
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    type: FileType.custom,
                    allowedExtensions: ["png", "jpg"]
                  );

                  String? path = result?.files.single.path;
                  String? name = result?.files.single.name;
                  this.setState(() {
                    imagefile = File(path!);
                    fileName = name;
                    print(imagefile!.path);
                  });
                  print(path);
                  print(name);
              },
              child: CircleAvatar(
                //backgroundImage: imagefile!=null?FileImage(imagefile!):NetworkImage("") as ImageProvider,
                radius: 50,

              ),
            ),
            TextField(
              controller: username,
              decoration: InputDecoration(
                hintText: "username",
                border: OutlineInputBorder()
              ),
            ),
            TextField(
              controller: email,
              decoration: InputDecoration(
                hintText: "email",
                  border: OutlineInputBorder()
              ),
            ),
            TextField(
              controller: fullname,
              decoration: InputDecoration(
                hintText: "fullname",
                  border: OutlineInputBorder()
              ),
            ),
            TextField(
              controller: country,
              decoration: InputDecoration(
                hintText: "country",
                  border: OutlineInputBorder()
              ),
            ),
            TextField(
              controller: refarralid,
              decoration: InputDecoration(
                hintText: "refarral id",
                  border: OutlineInputBorder()
              ),
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(
                hintText: 'password',
                  border: OutlineInputBorder()
              ),
            ),

            ElevatedButton(onPressed: ()async{

              final storage = FirebaseStorage.instance;
              final x = await storage.ref("profile/$fileName").putFile(imagefile!);
              x.ref.getDownloadURL().then((value) async{
                final auth = FirebaseAuth.instance;
                final y = await auth.createUserWithEmailAndPassword(email: email.text.trim(), password: password.text.trim());
                final store = FirebaseFirestore.instance.collection("users").doc(y.user!.uid);
                MyUser myuser = MyUser();
                myuser.email = y.user!.email;
                myuser.uid = y.user!.uid;
                myuser.profileimage=value;
                myuser.refarralid=refarralid.text;
                myuser.fullname=fullname.text;
                myuser.country=country.text;
                myuser.username=username.text;
                store.set(myuser.toJson()).then((value) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MainScreen()));
                });
              });



            }, child: Text("Create account"))


          ],
        ),
      ),
    );
  }
}


