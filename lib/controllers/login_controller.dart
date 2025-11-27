import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:log_auth/auth/api_client.dart';
import 'package:log_auth/model/login_model.dart';
import 'package:log_auth/route/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  var isLoggedIn = false.obs;
  var token = ''.obs;
  var username = ''.obs;
  var usermail = ''.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Call your ApiClient
      LoginModel? user = await ApiClient.postLogin(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Save data on successful login
      if (user != null) {
        isLoggedIn.value = true;
        token.value = user.accessToken;
        username.value = user.username ?? '';
        usermail.value = user.email ?? '';

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', user.accessToken);
        await prefs.setString('username', user.username ?? '');
        await prefs.setString('email', user.email ?? '');

        Get.snackbar(
          'Success',
          'Login successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        GoRouter.of(context).goNamed(Routes.home); // navigate to home
      }
    } catch (e) {
      // Show error returned from API
      Get.snackbar(
        'Error',
        e.toString().contains('400') || e.toString().contains('Invalid')
            ? 'Invalid credentials'
            : e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Auto login using saved token
  Future<void> autoLogin(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString('token');

    if (savedToken != null && savedToken.isNotEmpty) {
      token.value = savedToken;
      username.value = prefs.getString('username') ?? '';
      usermail.value = prefs.getString('email') ?? '';
      isLoggedIn.value = true;

      GoRouter.of(context).goNamed(Routes.home);
    }
  }

  Future<void> logout(BuildContext context) async {
    isLoggedIn.value = false;
    token.value = '';
    username.value = '';
    usermail.value = '';
    emailController.clear();
    passwordController.clear();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Get.snackbar(
      'Success',
      'Logged out successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    GoRouter.of(context).goNamed(Routes.login);
  }
}
