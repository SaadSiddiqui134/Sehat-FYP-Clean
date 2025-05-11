import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import 'diabetic_retinopathy_output.dart';

class DiabeticRetinopathySymptomsView extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const DiabeticRetinopathySymptomsView({Key? key, this.userData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.lightGray,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        iconTheme: IconThemeData(color: TColor.primaryColor1),
        title: Text(
          'Diabetic Retinopathy Symptoms',
          style: TextStyle(
            color: TColor.primaryColor1,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Upload a retina image to check for Diabetic Retinopathy severity.',
              style: TextStyle(
                color: TColor.primaryColor1,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            // Placeholder for image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: TColor.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TColor.primaryColor2, width: 1),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 60, color: TColor.gray),
                  SizedBox(height: 12),
                  Text(
                    'No image selected',
                    style: TextStyle(color: TColor.gray),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.photo_camera),
                  label: Text('Camera'),
                  onPressed: () {
                    print('Camera button pressed');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primaryColor1,
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.photo_library),
                  label: Text('Gallery'),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primaryColor2,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DiabeticRetinopathyOutputView()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Check Severity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
