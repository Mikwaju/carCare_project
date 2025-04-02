import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/Logo.png', width: 180),
                const SizedBox(height: 20),
                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                // Mobile Number Field
                TextField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.phone,
                      color: Colors.blue,
                      size: 24, // Adjust size as needed
                    ),
                    labelText: "Enter your mobile number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Password Field
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock_open,
                      color: Colors.blue,
                      size: 24, // Adjust size as needed
                    ),
                    suffixIcon: Icon(
                      Icons.visibility,
                      color: Colors.grey,
                      size: 24,// Adjust size as needed
                    ),
                    labelText: "Enter your password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Button background color
                      foregroundColor: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign Up Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account?"),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // OR Divider
                const Text("or", style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 10),

                // Google Sign-In
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Image.asset('assets/Google.png', width: 24),
                    label: const Text("Continue with Google"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Apple Sign-In
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Image.asset('assets/Apple logo.png', width: 24),
                    label: const Text("Continue with Apple"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
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