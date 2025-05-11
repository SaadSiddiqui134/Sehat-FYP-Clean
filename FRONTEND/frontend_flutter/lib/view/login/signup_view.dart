import 'dart:io';

import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/common_widget/round_textfield.dart';
import 'package:fitness/view/login/complete_profile_view.dart';
import 'package:fitness/view/login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fitness/api_constants.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

//CreateUSer Functionality
void _handleSignup(
    BuildContext context,
    String firstname,
    String lastname,
    String email,
    String password,
    String gender,
    String weight,
    String height_cm) async {
  try {
    final response = await http.post(
      Uri.parse(ApiConstants.createUser),
      body: {
        'UserFirstName': firstname,
        'UserLastName': lastname,
        'UserEmail': email,
        'UserPassword': password,
        'UserGender': gender,
        'UserWeight': weight,
        'UserHeight': height_cm
      },
    );
    print(response.body);

    if (response.statusCode == 200) {
      // If successful, navigate to the next screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User Created Successfully')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginView(
                  userDataFromSignup: {
                    'firstname': firstname,
                    'lastname': lastname,
                    'email': email,
                    'gender': gender,
                    'weight': weight,
                    'height': height_cm
                  },
                  // Add more fields as needed
                )),
      );
    } else {
      // Show the error in case of failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: ${json.decode(response.body)['message']}')),
      );
    }
  } catch (e) {
    print("Error: ${e.toString()}"); // Log the error message
    // Handle network errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$e")),
    );
  }
}

class _SignUpViewState extends State<SignUpView> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000), // Earliest date
      lastDate: DateTime(2100), // Latest date
    );
    if (picked != null) {
      // Format and set the selected date
      setState(() {
        _dateController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  bool isCheck = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heighttController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: TColor.white,
        body: SingleChildScrollView(
            child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Hey there,",
                    style: TextStyle(color: TColor.gray, fontSize: 16),
                  ),
                  Text(
                    "Create an Account",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  RoundTextField(
                    hitText: "First Name",
                    icon: "assets/img/user_text.png",
                    controller: _firstNameController,
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  RoundTextField(
                    hitText: "Last Name",
                    icon: "assets/img/user_text.png",
                    controller: _lastNameController,
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  RoundTextField(
                    hitText: "Email",
                    icon: "assets/img/email.png",
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  RoundTextField(
                    hitText: "Password",
                    icon: "assets/img/lock.png",
                    obscureText: true,
                    controller: _passwordController,
                    rightIcon: TextButton(
                        onPressed: () {},
                        child: Container(
                            alignment: Alignment.center,
                            width: 20,
                            height: 20,
                            child: Image.asset(
                              "assets/img/show_password.png",
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                              color: TColor.gray,
                            ))),
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: TColor.lightGray,
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: [
                              Container(
                                  alignment: Alignment.center,
                                  width: 50,
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Image.asset(
                                    "assets/img/gender.png",
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                    color: TColor.gray,
                                  )),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    value: _genderController.text.isEmpty
                                        ? null
                                        : _genderController.text,
                                    items: ["Male", "Female"]
                                        .map((name) => DropdownMenuItem<String>(
                                              value: name,
                                              child: Text(
                                                name,
                                                style: TextStyle(
                                                    color: TColor.gray,
                                                    fontSize: 14),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _genderController.text =
                                              value; // Update the controller
                                        });
                                      }
                                    },
                                    isExpanded: true,
                                    hint: Text(
                                      "Choose Gender",
                                      style: TextStyle(
                                          color: TColor.gray, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              )
                            ],
                          ),
                        ),
                        // SizedBox(
                        //   height: media.width * 0.04,
                        // ),
                        // TextField(
                        //   controller: _dateController,
                        //   readOnly: true, // Make the TextField non-editable
                        //   decoration: const InputDecoration(
                        //     labelText: "Select a Date",
                        //     suffixIcon: Icon(Icons.calendar_today),
                        //   ),
                        //   onTap: () => _selectDate(context),
                        // ),
                        SizedBox(
                          height: media.width * 0.04,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RoundTextField(
                                controller: _weightController,
                                hitText: "Your Weight",
                                icon: "assets/img/weight.png",
                                keyboardType: TextInputType
                                    .number, // Show numeric keyboard
                                //  inputFormatters: [
                                //   FilteringTextInputFormatter.digitsOnly, // Allow digits only
                                //   ],
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: TColor.secondaryG,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                "KG",
                                style: TextStyle(
                                    color: TColor.white, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: media.width * 0.04,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RoundTextField(
                                controller: _heighttController,
                                hitText: "Your Height",
                                icon: "assets/img/hight.png",
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: TColor.secondaryG,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                "CM",
                                style: TextStyle(
                                    color: TColor.white, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                        Row(
                          // crossAxisAlignment: CrossAxisAlignment.,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  isCheck = !isCheck;
                                });
                              },
                              icon: Icon(
                                isCheck
                                    ? Icons.check_box_outlined
                                    : Icons.check_box_outline_blank_outlined,
                                color: TColor.gray,
                                size: 20,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "By continuing you accept our Privacy Policy and\nTerm of Use",
                                style:
                                    TextStyle(color: TColor.gray, fontSize: 10),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: media.width * 0.1,
                        ),
                        RoundButton(
                            title: "Register",
                            onPressed: () {
                              final firstname = _firstNameController.text;
                              final lastname = _lastNameController.text;
                              final email = _emailController.text;
                              final password = _passwordController.text;
                              final gender = _genderController.text;
                              final weight = _weightController.text;
                              final height = _heighttController.text;
                              _handleSignup(context, firstname, lastname, email,
                                  password, gender, weight, height);
                            }),
                        SizedBox(
                          height: media.width * 0.04,
                        ),
                        // Row(
                        //   // crossAxisAlignment: CrossAxisAlignment.,
                        //   children: [
                        //     Expanded(
                        //         child: Container(
                        //       height: 1,
                        //       color: TColor.gray.withOpacity(0.5),
                        //     )),
                        //     Text(
                        //       "  Or  ",
                        //       style:
                        //           TextStyle(color: TColor.black, fontSize: 12),
                        //     ),
                        //     Expanded(
                        //         child: Container(
                        //       height: 1,
                        //       color: TColor.gray.withOpacity(0.5),
                        //     )),
                        //   ],
                        // ),
                        // SizedBox(
                        //   height: media.width * 0.04,
                        // ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     GestureDetector(
                        //       onTap: () {},
                        //       child: Container(
                        //         width: 50,
                        //         height: 50,
                        //         alignment: Alignment.center,
                        //         decoration: BoxDecoration(
                        //           color: TColor.white,
                        //           border: Border.all(
                        //             width: 1,
                        //             color: TColor.gray.withOpacity(0.4),
                        //           ),
                        //           borderRadius: BorderRadius.circular(15),
                        //         ),
                        //         child: Image.asset(
                        //           "assets/img/google.png",
                        //           width: 20,
                        //           height: 20,
                        //         ),
                        //       ),
                        //     ),
                        //     SizedBox(
                        //       width: media.width * 0.04,
                        //     ),
                        //     GestureDetector(
                        //       onTap: () {},
                        //       child: Container(
                        //         width: 50,
                        //         height: 50,
                        //         alignment: Alignment.center,
                        //         decoration: BoxDecoration(
                        //           color: TColor.white,
                        //           border: Border.all(
                        //             width: 1,
                        //             color: TColor.gray.withOpacity(0.4),
                        //           ),
                        //           borderRadius: BorderRadius.circular(15),
                        //         ),
                        //         child: Image.asset(
                        //           "assets/img/facebook.png",
                        //           width: 20,
                        //           height: 20,
                        //         ),
                        //       ),
                        //     )
                        //   ],
                        // ),
                        SizedBox(
                          height: media.width * 0.04,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginView()));
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "Login",
                                style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: media.width * 0.04,
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
        )));
  }
}
