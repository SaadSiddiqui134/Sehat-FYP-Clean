import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';

class DiabetesOutputView extends StatelessWidget {
  final String prediction;
  final Map<String, dynamic> userData;
  final Map<String, dynamic> inputData;

  const DiabetesOutputView({
    Key? key,
    required this.prediction,
    required this.userData,
    required this.inputData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPositive = prediction.toString() == "1";

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Diabetes Prediction',
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
                        ? 'You have diabetes'
                        : 'You do not have diabetes',
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
                        ? 'Since you have been predicted to have diabetes, here are some important recommendations:'
                        : 'To maintain good health and prevent diabetes in the future:',
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isPositive) ...[
                    _buildBulletPoint(
                        'Schedule an appointment with your doctor for proper diagnosis and treatment plan'),
                    _buildBulletPoint(
                        'Monitor your blood sugar levels regularly'),
                    _buildBulletPoint(
                        'Maintain a healthy diet with controlled carbohydrate intake'),
                    _buildBulletPoint(
                        'Engage in regular physical activity (at least 30 minutes daily)'),
                    _buildBulletPoint('Maintain a healthy weight'),
                    _buildBulletPoint(
                        'Avoid smoking and limit alcohol consumption'),
                    _buildBulletPoint(
                        'Get regular check-ups for blood pressure and cholesterol'),
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
        'Eat a balanced diet with fruits, vegetables, and whole grains'));
    tips.add(_buildBulletPoint('Exercise regularly and keep a healthy weight'));
    tips.add(_buildBulletPoint('Limit sugary drinks and junk food'));
    tips.add(_buildBulletPoint('Get enough sleep and manage stress'));
    tips.add(_buildBulletPoint('Visit your doctor for regular check-ups'));

    // Personalized tips
    try {
      if (inputData.containsKey('Age')) {
        final age = int.tryParse(inputData['Age'].toString()) ?? 0;
        if (age > 45) {
          tips.add(_buildBulletPoint(
              'Since you are over 45, get regular diabetes screenings.'));
        }
      }
      if (inputData.containsKey('BMI')) {
        final bmi = double.tryParse(inputData['BMI'].toString()) ?? 0;
        if (bmi > 25) {
          tips.add(_buildBulletPoint(
              'Consider weight management strategies to lower your BMI.'));
        }
      }
      if (inputData.containsKey('BloodPressure')) {
        final bp = double.tryParse(inputData['BloodPressure'].toString()) ?? 0;
        if (bp > 130) {
          tips.add(_buildBulletPoint(
              'Monitor your blood pressure and reduce salt intake.'));
        }
      }
      if (inputData.containsKey('Glucose')) {
        final glucose = double.tryParse(inputData['Glucose'].toString()) ?? 0;
        if (glucose > 110) {
          tips.add(_buildBulletPoint(
              'Watch your sugar intake and monitor your glucose levels.'));
        }
      }
    } catch (e) {
      // Ignore errors in parsing
    }
    return tips;
  }
}
