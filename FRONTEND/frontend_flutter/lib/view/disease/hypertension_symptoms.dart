import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api_constants.dart';
import 'hypertension_output.dart';

class HypertensionSymptomsView extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const HypertensionSymptomsView({Key? key, this.userData}) : super(key: key);

  @override
  State<HypertensionSymptomsView> createState() =>
      _HypertensionSymptomsViewState();
}

Map<String, String> smokingDropdownToBackend = {
  "Never": "never",
  "Former": "former",
  "Currently": "current",
  "Not currently": "not current",
  "Has Smoked Before": "ever",
  "No info": "no info"
};

class _HypertensionSymptomsViewState extends State<HypertensionSymptomsView> {
  String gender = 'Male';
  String diabetes = 'No';
  String heartDisease = 'No';
  String smokingHistory = 'No info';
  final TextEditingController ageController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController hba1cController = TextEditingController();
  final TextEditingController bloodGlucoseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.userData != null) {
      // Use the pre-calculated BMI if available
      if (widget.userData!['calculatedBMI'] != null) {
        bmiController.text = widget.userData!['calculatedBMI'].toString();
      } else {
        // Fallback to calculating BMI if not passed
        var height = widget.userData!['height'];
        var weight = widget.userData!['weight'];

        if (height != null && weight != null) {
          try {
            double heightValue =
                height is String ? double.parse(height) : height.toDouble();
            double weightValue =
                weight is String ? double.parse(weight) : weight.toDouble();
            heightValue = heightValue / 100;
            double bmi = weightValue / (heightValue * heightValue);
            bmiController.text = bmi.toStringAsFixed(2);
          } catch (e) {
            print("Error calculating BMI: $e");
            bmiController.text = "Error calculating BMI";
          }
        } else {
          bmiController.text = "Height or weight missing";
        }
      }
    } else {
      bmiController.text = "No user data available";
    }

    // Set age if available in userData
    if (widget.userData != null && widget.userData!['age'] != null) {
      ageController.text = widget.userData!['age'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TColor.lightGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Hypertension Symptoms",
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Gender:"),
              _buildDropdown(
                value: gender,
                items: ['Male', 'Female'],
                onChanged: (value) => setState(() => gender = value!),
              ),
              _buildLabel("Age:"),
              _buildTextField(ageController, "Enter age", TextInputType.number),
              _buildLabel("Diabetes:"),
              _buildDropdown(
                value: diabetes,
                items: ['Yes', 'No'],
                onChanged: (value) => setState(() => diabetes = value!),
              ),
              _buildLabel("Previous Heart Disease:"),
              _buildDropdown(
                value: heartDisease,
                items: ['Yes', 'No'],
                onChanged: (value) => setState(() => heartDisease = value!),
              ),
              _buildLabel("Smoking Status:"),
              _buildDropdown(
                value: smokingHistory,
                items: [
                  'No info',
                  'Never',
                  'Former',
                  'Currently',
                  'Not currently',
                  'Has Smoked Before'
                ],
                onChanged: (value) => setState(() => smokingHistory = value!),
              ),
              _buildLabel("BMI:"),
              _buildTextField(bmiController, "BMI will be auto-calculated",
                  TextInputType.number,
                  enabled: false),
              _buildLabel("Avg. Sugar Levels (2-3 months):",
                  subtitle: "Normal range: 4.0-5.6%"),
              _buildTextField(
                  hba1cController, "Enter HBA1C level", TextInputType.number),
              _buildLabel("Blood Glucose Level (random):",
                  subtitle:
                      "Normal range: 70-99 mg/dL       Pre-Hypertensive: 120-129"),
              _buildTextField(bloodGlucoseController,
                  "Enter blood glucose level", TextInputType.number),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Center(child: CircularProgressIndicator());
                        },
                      );

                      try {
                        // Prepare request data
                        final requestData = {
                          'user_id': widget.userData?['UserID'] ?? '',
                          'gender': gender.toLowerCase(),
                          'age': ageController.text,
                          'heart_disease': heartDisease.toLowerCase(),
                          'smoking_history':
                              smokingDropdownToBackend[smokingHistory] ??
                                  'no info',
                          'bmi': bmiController.text,
                          'HbA1c_level': hba1cController.text,
                          'blood_glucose_level': bloodGlucoseController.text,
                          'diabetes': diabetes.toLowerCase()
                        };

                        // Send request to backend
                        final response = await http.post(
                          Uri.parse(ApiConstants.predictDiseaseHypertension),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(requestData),
                        );

                        // Close loading indicator
                        Navigator.pop(context);

                        if (response.statusCode == 200) {
                          // Parse response
                          final responseData = jsonDecode(response.body);
                          final prediction = responseData['prediction'];

                          // Navigate to output page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HypertensionOutputView(
                                prediction: prediction.toString(),
                                userData: widget.userData ?? {},
                                inputData: requestData,
                              ),
                            ),
                          );
                        } else {
                          // Show error dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Error'),
                                content: Text(
                                    'Failed to get prediction. Please try again.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('OK'),
                                  )
                                ],
                              );
                            },
                          );
                        }
                      } catch (e) {
                        // Close loading indicator
                        Navigator.pop(context);

                        // Show error dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text('An error occurred: $e'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('OK'),
                                )
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primaryColor1,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Check Symptoms",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              color: TColor.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    TextInputType keyboardType, {
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        // Add number validation for HBA1c and glucose fields
        if ((controller == hba1cController ||
                controller == bloodGlucoseController) &&
            !RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
          return 'Please enter a valid number';
        }
        return null;
      },
      // Add input formatter for numbers only
      inputFormatters: (controller == hba1cController ||
              controller == bloodGlucoseController)
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))]
          : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor:
            enabled ? TColor.lightGray : TColor.lightGray.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        errorStyle: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return FormField<String>(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an option';
        }
        return null;
      },
      initialValue: value,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                underline: Container(),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (newValue) {
                  onChanged(newValue);
                  state.didChange(newValue);
                },
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  state.errorText!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
