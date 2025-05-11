import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';

class ContactUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.lightGray,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        iconTheme: IconThemeData(color: TColor.primaryColor1),
        title: Text(
          'About Us',
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '''Sehat is an all-in-one health and wellness application developed to help users take control of their health through technology. Designed as a Final Year Project by Computer Science students, Sehat integrates innovative features to promote healthier lifestyles and informed decision-making.

Our application provides tools for tracking sleep patterns, logging nutrition, and predicting the risk of chronic conditions like diabetes and hypertension using machine learning models. It also offers food recognition capabilities and personalized insights based on user input.

We believe in making healthcare more accessible, data-driven, and user-friendly. Whether you're aiming to improve your sleep, monitor your diet, or stay ahead of potential health risks, Sehat is your personal wellness companion.''',
                style: TextStyle(
                  color: TColor.primaryColor1,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 28),
              Text(
                'Contact Us',
                style: TextStyle(
                  color: TColor.primaryColor1,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: TColor.primaryColor2.withOpacity(0.10),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.email, color: TColor.primaryColor1),
                        SizedBox(width: 12),
                        Text(
                          'SehatApp@gmail.com',
                          style: TextStyle(
                            color: TColor.primaryColor1,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    Row(
                      children: [
                        Icon(Icons.phone, color: TColor.primaryColor1),
                        SizedBox(width: 12),
                        Text(
                          '+92 123 456 789',
                          style: TextStyle(
                            color: TColor.primaryColor1,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, color: TColor.primaryColor1),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '123 Jinnah Street, Karachi, Pakistan',
                            style: TextStyle(
                              color: TColor.primaryColor1,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
