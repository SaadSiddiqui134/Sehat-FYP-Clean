import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';

class HypertensionOutputView extends StatelessWidget {
  final String prediction;
  final Map<String, dynamic> userData;
  final Map<String, dynamic> inputData;

  const HypertensionOutputView({
    Key? key,
    required this.prediction,
    required this.userData,
    required this.inputData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Prediction value received: $prediction');
    final bool isPositive = prediction.toString() == "1" || prediction == 1;

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Hypertension Prediction',
          style: TextStyle(
            color: TColor.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        iconTheme: IconThemeData(color: TColor.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Prediction Result',
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPositive
                        ? 'You have hypertension'
                        : 'You do not have hypertension',
                    style: TextStyle(
                      fontSize: 22,
                      color: isPositive ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    isPositive
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_rounded,
                    color: isPositive ? Colors.red : Colors.green,
                    size: 40,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Input Data',
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...inputData.entries.map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: TextStyle(
                            color: TColor.gray,
                            fontSize: 14,
                          ),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommendations',
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isPositive
                        ? 'Since you have been predicted to have hypertension, here are some important recommendations:'
                        : 'To maintain good health and prevent hypertension in the future:',
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isPositive) ...[
                    _buildBulletPoint(
                        'Consult your doctor for a proper diagnosis and treatment plan'),
                    _buildBulletPoint('Monitor your blood pressure regularly'),
                    _buildBulletPoint('Reduce salt intake in your diet'),
                    _buildBulletPoint('Maintain a healthy weight'),
                    _buildBulletPoint('Engage in regular physical activity'),
                    _buildBulletPoint('Limit alcohol consumption'),
                    _buildBulletPoint('Avoid smoking'),
                    _buildBulletPoint(
                        'Manage stress through relaxation techniques'),
                  ],
                  ..._buildPersonalizedTips(inputData),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primaryColor1,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Back',
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
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: TColor.gray,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPersonalizedTips(Map<String, dynamic> inputData) {
    List<Widget> tips = [];
    // Default general tips
    tips.add(_buildBulletPoint(
        'Eat a balanced diet rich in fruits, vegetables, and whole grains'));
    tips.add(_buildBulletPoint('Exercise regularly and keep a healthy weight'));
    tips.add(_buildBulletPoint('Limit processed and high-sodium foods'));
    tips.add(_buildBulletPoint('Get enough sleep and manage stress'));
    tips.add(_buildBulletPoint('Visit your doctor for regular check-ups'));

    // Personalized tips
    try {
      if (inputData.containsKey('age')) {
        final age = int.tryParse(inputData['age'].toString()) ?? 0;
        if (age > 45) {
          tips.add(_buildBulletPoint(
              'Since you are over 45, monitor your blood pressure more frequently.'));
        }
      }
      if (inputData.containsKey('bmi')) {
        final bmi = double.tryParse(inputData['bmi'].toString()) ?? 0;
        if (bmi > 25) {
          tips.add(_buildBulletPoint(
              'Consider weight management strategies to lower your BMI.'));
        }
      }
      if (inputData.containsKey('blood_glucose_level')) {
        final glucose =
            double.tryParse(inputData['blood_glucose_level'].toString()) ?? 0;
        if (glucose > 110) {
          tips.add(_buildBulletPoint(
              'Monitor your blood sugar levels as high glucose can impact blood pressure.'));
        }
      }
      if (inputData.containsKey('smoking_history')) {
        final smoking = inputData['smoking_history'].toString().toLowerCase();
        if (smoking == 'current' ||
            smoking == 'ever' ||
            smoking == 'has smoked before') {
          tips.add(_buildBulletPoint(
              'Quitting smoking can significantly reduce your risk of hypertension.'));
        }
      }
    } catch (e) {
      // Ignore errors in parsing
    }
    return tips;
  }
}
