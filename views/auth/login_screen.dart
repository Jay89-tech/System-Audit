import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authController =
          Provider.of<AuthController>(context, listen: false);

      final success = await authController.signIn(
        _emailController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        // Navigation is handled by GoRouter redirect logic
      } else if (mounted) {
        // Show error message if login failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.errorMessage ?? 'Login failed'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Logo and Title Section
              _buildHeader(context),

              const SizedBox(height: 60),

              // Login Form
              _buildLoginForm(context),

              const SizedBox(height: 40),

              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Logo Container
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.deepBlue,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepBlue.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.assignment_ind_outlined,
            size: 50,
            color: AppColors.white,
          ),
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.darkGrey,
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Sign in to your Skills Audit account',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.mediumGrey,
              ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your work email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: MultiValidator([
                  RequiredValidator(errorText: 'Email is required'),
                  EmailValidator(errorText: 'Enter a valid email'),
                ]).call,
              ),

              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleLogin(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: RequiredValidator(
                  errorText: 'Password is required',
                ).call,
              ),

              const SizedBox(height: 8),

              // Error Message
              Consumer<AuthController>(
                builder: (context, authController, _) {
                  if (authController.errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        authController.errorMessage!,
                        style: TextStyle(
                          color: AppColors.errorRed,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 24),

              // Login Button
              Consumer<AuthController>(
                builder: (context, authController, _) {
                  return SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authController.isLoading ? null : _handleLogin,
                      child: authController.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : const Text('Sign In'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          height: 1,
          width: 40,
          color: AppColors.softGrey,
        ),
        const SizedBox(height: 16),
        Text(
          'Need help? Contact your HR administrator',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mediumGrey,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 16,
              color: AppColors.mediumGrey,
            ),
            const SizedBox(width: 8),
            Text(
              'Secure Authentication',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mediumGrey,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
