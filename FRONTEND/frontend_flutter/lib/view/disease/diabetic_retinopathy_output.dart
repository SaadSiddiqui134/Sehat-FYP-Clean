import 'diabetic_retinopathy_output.dart';
import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';

class DiabeticRetinopathyOutputView extends StatelessWidget {
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
      body: Center(
        child: Text(
          'This is the Diabetic Retinopathy Output Page.\n(Show severity result here.)',
          style: TextStyle(
            color: TColor.primaryColor1,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
