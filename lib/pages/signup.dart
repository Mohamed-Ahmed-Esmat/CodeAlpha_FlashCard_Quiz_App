import 'package:flash_card_quiz_app/pages/home.dart';
import 'package:flash_card_quiz_app/pages/login.dart';
import 'package:flash_card_quiz_app/services/authentication_services.dart';
import 'package:flash_card_quiz_app/widgets/loading.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var hidePassword = true;
  bool loading = false;
  var passIcons = const Icon(Icons.visibility_off);
  final List<String> allowedDomains = ['gmail.com', 'hotmail.com', 'yahoo.com'];

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a password';
    }

    final passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');

    if (!passwordRegExp.hasMatch(value)) {
      String error = '';

      if (value.length < 8) {
        error += 'Password must be at least 8 characters long. ';
      } else if (!value.contains(RegExp(r'[A-Z]'))) {
        error += 'Password must contain at least one uppercase letter. ';
      } else if (!value.contains(RegExp(r'\d'))) {
        error += 'Password must contain at least one digit.';
      }

      return error.trim(); // Return the combined error message
    }

    return null; // Return null if the password is valid
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a Name';
    }

    // Regular expression to match alphabetic characters only
    final RegExp nameRegExp = RegExp(r'^[a-zA-Z]+$');

    if (!nameRegExp.hasMatch(value)) {
      return 'Name can only contain letters';
    }

    return null; // Return null if the name is valid
  }

  // Custom email validator
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter an E-mail';
    }

    final emailParts = value.split('@');
    if (emailParts.length != 2 || !allowedDomains.contains(emailParts[1])) {
      return 'Enter a valid email address';
    }

    return null; // Return null if the email is valid
  }

  Future<void> _handleSignUp() async {
    setState(() => loading = true);

    if (_formKey.currentState!.validate()) {
      // Custom password validation
      final password = passwordController.text;
      final passwordRegExp = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');

      if (!passwordRegExp.hasMatch(password)) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: Password does not meet the criteria."),
          ),
        );
        return;
      }

      String? result = await AuthenticationService().signUp(
        emailController.text,
        passwordController.text,
        nameController.text,
      );

      // Dismiss the loading page
      setState(() => loading = false);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $result"),
          ),
        );
      } else {
        // Navigate to the home page and replace the current route
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
        // Remove the previous routes from the stack
        Navigator.of(context).removeRoute(
          ModalRoute.of(context)!,
        );
      }
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            appBar: AppBar(
              title: const Text("Sign Up"),
              centerTitle: true,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                      child: Text(
                        "Name",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                      child: TextFormField(
                        validator: validateName,
                        controller: nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          hintText: 'Enter your name',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                      child: Text(
                        "E-mail",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                      child: TextFormField(
                        validator: validateEmail,
                        controller: emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          hintText: 'Enter your e-mail',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                      child: Text(
                        "Password",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                      child: TextFormField(
                        validator: validatePassword,
                        obscureText: hidePassword,
                        controller: passwordController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          hintText: 'Enter your password',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => loading = true);
                              await _handleSignUp();
                            }
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: OutlinedButton(
                          onPressed: () {
                            // Add your Google sign-up logic here
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 50.0,
                                height: 50.0,
                                alignment: Alignment.center,
                                child: Image.asset("assets/images/google.png"),
                              ),
                              const Text(
                                "Register with Google",
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already signed up ?",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          child: const Text("Login"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
