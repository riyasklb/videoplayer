import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:chat_application/service/alert_service.dart';
import 'package:chat_application/service/auth_service.dart';
import 'package:chat_application/service/navigation_service.dart';
import 'package:chat_application/widget/const.dart';
import 'package:chat_application/widget/custiom_formfiled.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthService _authService;
  late AlertService _alertService;

  String? email, password;
bool isLoading=false;
  @override
  void initState() {
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Login',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            _loginForm(),
            SizedBox(height: 24),
            _createAccountLink(),
          ],
        ),
      ),
    );
  }

  Widget _loginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomFormField(
            hintText: 'Email',
           
            onSaved: (value) {
              setState(() {
                email = value;
              });
            }, regExpressionvalidation: EMAIL_VALIDATION_REGEX,
          ),
          SizedBox(height: 16),
          CustomFormField(
            hintText: 'Password',
            regExpressionvalidation: PASSWORD_VALIDATION_REGEX, 
            // obscureText: true,
            onSaved: (value) {
              setState(() {
                password = value;
              });}
            // },
          ),
          SizedBox(height: 24),
          _loginButton(),
        ],
      ),
    );
  }

  Widget _loginButton() {
  
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          
          if (_loginFormKey.currentState?.validate() ?? false) {
            setState(() {
            isLoading=true;
          });
            _loginFormKey.currentState?.save();
            bool result = await _authService.login(email!, password!);

            if (result) {
              _navigationService.pushReplacementNamed('/playscreen');
              _alertService.showToasr(
                text: 'Successfully logged in',
                icon: Icons.check,
              );
               setState(() {
            isLoading=false;
          });
            } else {
               setState(() {
            isLoading=false;
          });
              _alertService.showToasr(
                text: 'Invalid credentials. Please try again.',
                icon: Icons.error,
              );
            }
          }
        },
        child:isLoading?Center(child: CircularProgressIndicator()) :Text('Login'),
      ),
    );
  }

  Widget _createAccountLink() {
    return GestureDetector(
      onTap: () {
        _navigationService.pushNamed('/registration');
      },
      child: Text(
        "Don't have an account? Sign up",
        style: TextStyle(fontSize: 16, color: Colors.blue),
      ),
    );
  }
}
