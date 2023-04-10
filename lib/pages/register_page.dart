import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signup_login/services/auth_service.dart';
import '../components/my_textfield.dart';
import '../components/logo.dart';
import '../components/my_button.dart';
import '../components/square_tile.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

//text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullnameController = TextEditingController();

  //sign user up method
  void signUserUp() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      //check if password or confirm password
      if (passwordController.text == confirmPasswordController.text) {
        //create the user in Firebase Authentication
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: usernameController.text,
          password: passwordController.text,
        );

        //get the user id
        final String userId = userCredential.user!.uid;

        //create user data object
        final Map<String, dynamic> userData = {
          'userId': userId,
          'fullName': fullnameController.text,
          'email': usernameController.text,
          'createdAt': FieldValue.serverTimestamp(),
          'bio':'',
          'photoUrl':'',
          
          
        };

        //add the user data to Firestore
        await users.doc(userId).set(userData);

        //pop the loading circle
        Navigator.pop(context);
      } else {
        //pop the loading circle
        Navigator.pop(context);

        //show error message, passwords don't match
        showErrorMessage("Passwords don't match!");
      }
    } on FirebaseAuthException catch (e) {
      //pop the loading circle
      Navigator.pop(context);

      //show error message
      showErrorMessage(e.code);
    }
  }

  //error message to email and password
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               

               //logo
                Container(
                 height: height * .35,
                decoration:const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("lib/images/registerimage.png"),
                  ),
                ),
              ),
                const SizedBox(
                  height: 25,
                ),


                //Let\'s create an account for you!
               const Text(
                  'Hadi Akademi Galeriye katıl!! ',
                  style: TextStyle(
                    
                    
                    color: Color.fromARGB(255, 52, 147, 255),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height:5,
                ),
                MyTextField(
                  controller: fullnameController,
                  hintText: 'Full Name',
                  obscureText: false,
                ),
                const SizedBox(
                  height: 5,
                ),

                MyTextField(
                  controller: usernameController,
                  hintText: 'E-mail',
                  obscureText: false,
                ),
                const SizedBox(
                  height: 5,
                ),
                //password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password', //arka yazısı
                  obscureText: true, // şifre görünmemesi nokta kümesi
                ),
                const SizedBox(
                  height: 5,
                ),
                //confirm password
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password', //arka yazısı
                  obscureText: true, // şifre görünmemesi nokta kümesi
                ),
                const SizedBox(
                  height: 5,
                ),

                //sign in button

                MyButton(
                  text: 'Sign Up',
                  onTap: signUserUp,
                ),

                const SizedBox(
                  height: 20,
                ),

                //not a member? register now?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
