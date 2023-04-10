import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signup_login/services/auth_service.dart';
import '../components/my_textfield.dart';
import '../components/logo.dart';
import '../components/my_button.dart';
import '../components/square_tile.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key,required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
//text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  //sign user in method
  void signUserIn() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    //try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text,
      );
      //pop the loading circle
      Navigator.pop(context);
      //concole
    } on FirebaseAuthException catch (e) {
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
                 height: height * .40,
                decoration:const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("lib/images/5187559.png"),
                  ),
                ),
              ),
                const SizedBox(
                  height: 25,
                ),

                //welcome back, you've been missed!
               const Text(
                  'Akademi Galeri\'ye Hoşgeldiniz!',
                  style: TextStyle(
                    color: Color.fromARGB(255, 52, 147, 255),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),

                MyTextField(
                  controller: usernameController,
                  hintText: 'E-mail',
                  obscureText: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                //password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password', //arka yazısı
                  obscureText: true, // şifre görünmemesi nokta kümesi
                ),
                const SizedBox(
                  height: 10,
                ),

                //forgot password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot  password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),

                //sign in button

                MyButton(
                  text: 'Sign In',
                  onTap: signUserIn,
                ),

                const SizedBox(
                  height: 10,
                ),

                //or continue with

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                     
                      
                    ],
                  ),
                ),
               
                //google+ apple signin buttons


                //not a member? register now?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Register now',
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
