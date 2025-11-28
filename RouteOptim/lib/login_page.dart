import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:route_optim/home_page.dart';
import 'package:route_optim/user.dart';

import 'admin_page.dart';
import 'auth_service.dart';
import 'main.dart';


User? user;


class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

final authService = AuthService();

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final enableButton = false.obs;
  final firstSwitchValue = ''.obs;
  final isSelected = 'sign in'.obs;
  final isLoading = false.obs;

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SizedBox(
                  //   height: 50,
                  //   child: Image.asset('assets/images/information.png'),
                  // ),
                  // const SizedBox(height: 20,),
                  const Text('RouteOptim', style: TextStyle(fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
                  const Text('Sign in to access portal'),
                  const SizedBox(height: 20,),
                  Card(
                    color: Colors.white,
                    child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text('Welcome Back',
                              style: TextStyle(fontSize: 16),),
                            Obx(() =>
                                ToggleButtons(
                                  borderRadius: BorderRadius.circular(50),
                                  borderColor: Colors.grey.shade300,
                                  selectedBorderColor: Colors.grey.shade400,
                                  fillColor: Colors.white,
                                  color: Colors.black54,
                                  selectedColor: Colors.black,
                                  constraints: const BoxConstraints(
                                      minHeight: 36, minWidth: 90),
                                  isSelected: [
                                    isSelected.value == 'sign in',
                                    isSelected.value == 'sign up'
                                  ],
                                  onPressed: (int index) {
                                    isSelected.value =
                                    index == 0 ? 'sign in' : 'sign up';
                                  },
                                  children: const [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Icon(Icons.login_outlined, size: 16),
                                        SizedBox(width: 6),
                                        Text('Sign In'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Icon(Icons.app_registration_outlined,
                                            size: 16),
                                        SizedBox(width: 6),
                                        Text('Sign Up'),
                                      ],
                                    ),
                                  ],
                                )
                            ),
                            const SizedBox(height: 20,),
                            Obx(() => isSelected.value == 'sign in'
                                ? viewSignIn()
                                : viewSignUp()
                            ),
                          ],
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget viewSignIn() {
    return Column(
      spacing: 8,
      children: [
        TextField(
          controller: emailController,
          onChanged: (a) {
            enableButton.value = emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
          },
          decoration: InputDecoration(
            hintText: 'Email',
            prefixIcon: const Icon(Icons.email_outlined),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        TextField(
          controller: passwordController,
          obscureText: true,
          onChanged: (a) {
            enableButton.value = emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
          },
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: const Icon(Icons.password_outlined),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        Obx(() {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: enableButton.value ? 1.0 : 0.5,
            child: ElevatedButton(
              onPressed: (enableButton.value && !isLoading.value) ? () async {
                isLoading.value = true;
                user = await authService.login(emailController.text, passwordController.text);
                isLoading.value = false;
                if (user != null) {
                  Get.off(() => user!.role ? const AdminPage() : HomePage());
                  Get.snackbar(
                    'Result',
                    'Welcome back ${user!.name.split(' ')[0]}!',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else {
                  Get.snackbar(
                    'Result',
                    'Incorrect credentials',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: !isLoading.value ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  Icon(
                    Icons.login_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  Text('Sign In', style: TextStyle(
                      fontSize: 16, color: Colors.white)),
                ],
              ) : const CircularProgressIndicator(color: Colors.white,),
            ),
          );
        }),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 1,
          children: [
            const Text('Don\'t have an account?',
              style: TextStyle(fontSize: 14),),
            TextButton(
                onPressed: () {
                  isSelected.value = 'sign up';
                },
                child: const Text('Sign Up', style: TextStyle(
                    fontSize: 16, color: Colors.blue),)
            ),
          ],
        ),
      ],
    );
  }

  Widget viewSignUp() {
    final viewPass = true.obs;

    return Column(
      spacing: 8,
      children: [
        TextField(
          controller: nameController,
          onChanged: (a) {
            enableButton.value = emailController.text.isNotEmpty &&
                passwordController.text.isNotEmpty && nameController.text.isNotEmpty;
          },
          decoration: InputDecoration(
            hintText: 'Name',
            prefixIcon: const Icon(Icons.person_outline),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        TextField(
          controller: emailController,
          onChanged: (a) {
            enableButton.value = emailController.text.isNotEmpty &&
                passwordController.text.isNotEmpty && nameController.text.isNotEmpty;
          },
          decoration: InputDecoration(
            hintText: 'Email',
            prefixIcon: const Icon(Icons.email_outlined),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
        Obx(() => TextField(
          controller: passwordController,
          obscureText: viewPass.value,
          onChanged: (a) {
            enableButton.value = emailController.text.isNotEmpty &&
                passwordController.text.isNotEmpty && nameController.text.isNotEmpty;
          },
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(viewPass.value ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                viewPass.value = !viewPass.value;
              },
            ),
            hintText: 'Password',
            prefixIcon: const Icon(Icons.password_outlined),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        )
        ),
        Obx(() {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: enableButton.value ? 1.0 : 0.5,
            child: ElevatedButton(
              onPressed: (enableButton.value && !isLoading.value) ? () async {
                isLoading.value = true;
                try {
                  final result = await authService.register(
                      emailController.text,
                      passwordController.text,
                      nameController.text
                  );
                  if (result) {
                    Get.snackbar(
                        'Registration Successful',
                        'You can now sign in with your credentials',
                        backgroundColor: Colors.green,
                        colorText: Colors.white
                    );
                  } else {
                    Get.snackbar(
                        'Registration Failed',
                        'Please try again later',
                        backgroundColor: Colors.red,
                        colorText: Colors.white
                    );
                  }
                } on Exception catch (e) {
                  // TODO
                  Get.snackbar(
                      'Error in registration',
                      e.toString(),
                      backgroundColor: Colors.red,
                      colorText: Colors.white
                  );
                  print(e);
                } finally {
                  isLoading.value = false;
                  isSelected.value = 'sign in';
                }
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: !isLoading.value ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  Icon(
                    Icons.app_registration_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  Text('Sign Up', style: TextStyle(fontSize: 16, color: Colors.white)),
                ],
              ) : const CircularProgressIndicator(color: Colors.white,),
            ),
          );
        }),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 1,
          children: [
            const Text('Already have an account?', style: TextStyle(fontSize: 14),),
            TextButton(
                onPressed: () {
                  isSelected.value = 'sign in';
                },
                child: const Text('Sign In', style: TextStyle(
                    fontSize: 16, color: Colors.blue),)
            ),
          ],
        ),
      ],
    );
  }
}