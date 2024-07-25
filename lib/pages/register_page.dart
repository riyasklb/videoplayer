import 'dart:io';
import 'package:chat_application/model/users_profile.dart';
import 'package:chat_application/service/media_service%20.dart';
import 'package:chat_application/service/storge_service.dart';
import 'package:chat_application/widget/custiom_formfiled.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:chat_application/service/alert_service.dart';
import 'package:chat_application/service/auth_service.dart';
import 'package:chat_application/service/database_service.dart';

import 'package:chat_application/service/navigation_service.dart';

import 'package:chat_application/widget/const.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthService _authService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  late StorgeService _storageService;
  late MediaService _mediaService;

  bool isLoading = false;
  File? selectedImage;
  String? name, email, password, dateOfBirth;

  @override
  void initState() {
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _storageService = _getIt.get<StorgeService>();
    _mediaService = _getIt.get<MediaService>();
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Register',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: _registerForm(),
              ),
            ),
            SizedBox(height: 24),
            _loginAccountLink(),
          ],
        ),
      ),
    );
  }

  Widget _registerForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          _profilePictureSelection(),
          SizedBox(height: 16),
          CustomFormField(
            hintText: 'Email',
            regExpressionvalidation: EMAIL_VALIDATION_REGEX,
            onSaved: (value) => email = value,
          ),
          SizedBox(height: 16),
          CustomFormField(
            hintText: 'User name',
            regExpressionvalidation: NAME_VALIDATION_REGEX,
            onSaved: (value) => name = value,
          ),
          SizedBox(height: 16),
          CustomFormField(
            hintText: 'Password',
            regExpressionvalidation: PASSWORD_VALIDATION_REGEX,
           // obscureText: true,
            onSaved: (value) => password = value,
          ),
          SizedBox(height: 16),
          CustomFormField(
            hintText: 'Date of Birth (YYYY-MM-DD)',
            regExpressionvalidation: DATE_OF_BIRTH_VALIDATION_REGEX,
            onSaved: (value) => dateOfBirth = value,
          ),
          SizedBox(height: 24),
          _registerButton(),
        ],
      ),
    );
  }

  Widget _profilePictureSelection() {
    return InkWell(
      onTap: () async {
        File? file = await _mediaService.getimagefromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.14,
        backgroundColor: Colors.grey,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _registerUser,
        child: isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Text('Register'),
      ),
    );
  }

  void _registerUser() async {
    if (_registerFormKey.currentState!.validate()) {
      _registerFormKey.currentState!.save();
      setState(() {
        isLoading = true;
      });

      try {
        bool result = await _authService.register(email!, password!);
        if (result) {
          String? pfpURL = await _storageService.uploadUserPfp(
            file: selectedImage!,
            uid: _authService.user!.uid,
          );

          if (pfpURL != null) {
            await _databaseService.createUserProfile(
              userProfile: UserProfile(
                uid: _authService.user!.uid,
                name: name,
                email: email,
                dateOfBirth: dateOfBirth,
                pfpURL: pfpURL,
              ),
            );

            setState(() {
              isLoading = false;
            });

            _navigationService.goBack();
            _navigationService.pushReplacementNamed('/playscreen');

            _alertService.showToasr(
              text: 'User registered successfully',
              icon: Icons.check,
            );
          } else {
            throw Exception('Unable to upload profile picture');
          }
        } else {
          throw Exception('Unable to register user');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        _alertService.showToasr(
          text: '$e',
          icon: Icons.error,
        );

        print(e);
      }
    }
  }

  Widget _loginAccountLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account? "),
        GestureDetector(
          onTap: () {
            _navigationService.pushNamed("/login");
          },
          child: Text(
            "Login",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
