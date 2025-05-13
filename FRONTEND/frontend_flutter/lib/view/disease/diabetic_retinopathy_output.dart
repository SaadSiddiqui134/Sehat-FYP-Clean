import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';

class DiabeticRetinopathyOutputView extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final String severity;
  final double confidence;

  const DiabeticRetinopathyOutputView({
    Key? key,
    this.userData,
    required this.severity,
    required this.confidence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.lightGray,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        iconTheme: IconThemeData(color: TColor.primaryColor1),
        title: Text(
          'Retinopathy Severity Result',
          style: TextStyle(
            color: TColor.primaryColor1,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TColor.white,
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
                    'Severity Level',
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    severity,
                    style: TextStyle(
                      fontSize: 24,
                      color: _getSeverityColor(severity),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TColor.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommendations',
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._getRecommendations(severity),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'No DR':
        return Colors.green;
      case 'Mild':
        return Colors.yellow.shade700;
      case 'Moderate':
        return Colors.orange;
      case 'Severe':
        return Colors.red;
      case 'Proliferative DR':
        return Colors.red.shade900;
      default:
        return TColor.gray;
    }
  }

  List<Widget> _getRecommendations(String severity) {
    final List<String> recommendations = [];

    // General recommendations
    recommendations.add('Schedule regular eye examinations with your doctor');
    recommendations.add('Control your blood sugar levels');
    recommendations
        .add('Maintain healthy blood pressure and cholesterol levels');
    recommendations.add('Follow a healthy diet and exercise regularly');

    // Severity-specific recommendations
    switch (severity) {
      case 'No DR':
        recommendations.add(
            'Continue with regular check-ups and maintain good diabetes control');
        break;
      case 'Mild':
        recommendations
            .add('Increase frequency of eye examinations to every 6-12 months');
        recommendations.add('Monitor for any changes in vision');
        break;
      case 'Moderate':
        recommendations.add('Schedule follow-up within 3-6 months');
        recommendations
            .add('Consider additional testing as recommended by your doctor');
        break;
      case 'Severe':
        recommendations
            .add('Urgent consultation with an eye specialist is recommended');
        recommendations
            .add('Discuss treatment options with your healthcare provider');
        break;
      case 'Proliferative DR':
        recommendations
            .add('Immediate consultation with a retina specialist is required');
        recommendations
            .add('Discuss treatment options like laser therapy or surgery');
        recommendations
            .add('Close monitoring and frequent follow-up is essential');
        break;
    }

    return recommendations
        .map((rec) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ',
                      style: TextStyle(color: TColor.gray, fontSize: 14)),
                  Expanded(
                    child: Text(
                      rec,
                      style: TextStyle(color: TColor.gray, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }
}
