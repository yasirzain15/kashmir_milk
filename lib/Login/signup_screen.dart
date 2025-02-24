// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kashmeer_milk/utils/utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image(image: AssetImage('assets/login.png')),
                SizedBox(height: 10),
                Text(
                  'Sign Up here !',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff878787),
                    ),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          // height: 51,
                          width: 311,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xff000000).withOpacity(0.25),
                                blurRadius: 9,
                                spreadRadius: 0,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _usernameController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'User Name',
                              hintStyle: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xffafafbd),
                                ),
                              ),
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: Color(0xffaaaaaa),
                              ),
                              filled: true,
                              fillColor: const Color(0xffffffff),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter user name';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          // height: 51,
                          width: 311,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xff000000).withOpacity(0.25),
                                blurRadius: 9,
                                spreadRadius: 0,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Email',
                              hintStyle: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xffafafbd),
                                ),
                              ),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Color(0xffaaaaaa),
                              ),
                              filled: true,
                              fillColor: const Color(0xffffffff),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter email';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          // height: 51,
                          width: 311,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xff000000).withOpacity(0.25),
                                blurRadius: 9,
                                spreadRadius: 0,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Password',
                              hintStyle: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xffafafbd),
                                ),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xffaaaaaa),
                              ),
                              filled: true,
                              fillColor: const Color(0xffffffff),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          // height: 51,
                          width: 311,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xff000000).withOpacity(0.25),
                                blurRadius: 9,
                                spreadRadius: 0,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Confirm Password',
                              hintStyle: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xffafafbd),
                                ),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xffaaaaaa),
                              ),
                              filled: true,
                              fillColor: const Color(0xffffffff),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please confirm your password';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    )),
                SizedBox(height: 57),
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        loading = true;
                      });
                      // Do something
                      _auth
                          .createUserWithEmailAndPassword(
                              email: _emailController.text.toString(),
                              password: _passwordController.text.toString())
                          .then((value) {
                        loading = false;
                      }).onError((error, stackTrace) {
                        Utils().toastMessage(error.toString());
                        loading = false;
                      });
                    }
                  },
                  child: Container(
                    height: 36.53,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Color(0xff78c1f3),
                    ),
                    child: Center(
                      child: loading
                          ? CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Color(0xffffffff),
                            )
                          : Text(
                              'Submit Request',
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xffffffff),
                              )),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 22,
                ),
                Container(
                  height: 36.53,
                  width: 300,
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                  ),
                  child: Center(
                    child: Text(
                      'Contact Us',
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff4caf50),
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
