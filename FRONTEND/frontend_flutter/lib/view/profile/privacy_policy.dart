import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';

class PrivacyPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.lightGray,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        iconTheme: IconThemeData(color: TColor.primaryColor1),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: TColor.primaryColor1,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            '''At Sehat, your privacy is important to us. This policy explains how we collect, use, and protect your personal information. When you use our app, we may collect personal details such as your name, email, age, and gender, along with health-related data including sleep logs, nutrition entries, and medical predictions (e.g., diabetes or hypertension). We also gather app usage statistics and device information to help improve your experience. This data is used strictly to power app features, generate predictions, enhance performance, and support academic research. We do not sell your data or use it for advertising. Your information may be shared only with trusted services like hosting providers or used anonymously in academic contexts. We employ strong security practices such as encryption and authentication, but no system is entirely foolproof. Your data is stored only as long as needed for services or research, and you can request to delete your account at any time. Sehat is not intended for children under 13, and we do not knowingly collect their data. By using the app, you consent to this policy. You have the right to access, correct, or delete your data and can contact us at SehatApp@gmail.com for any privacy-related concerns. We may update this policy from time to time, and any changes will be reflected within the app. ''',
            style: TextStyle(
              color: TColor.primaryColor1,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
