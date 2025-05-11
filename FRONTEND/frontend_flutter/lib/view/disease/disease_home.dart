import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';
import 'diabetes_symptoms.dart';
import 'hypertension_symptoms.dart';

class DiseaseHomeView extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const DiseaseHomeView({Key? key, this.userData}) : super(key: key);

  @override
  State<DiseaseHomeView> createState() => _DiseaseHomeViewState();
}

class _DiseaseHomeViewState extends State<DiseaseHomeView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> diseases = [
    'Diabetes',
    'Hypertension',
    'Diabetic Retinopathy'
  ];

  // Disease information map
  final Map<String, Map<String, String>> diseaseInfo = {
    'Diabetes': {
      'What is Diabetes?':
          'Diabetes is a chronic disease that occurs when your blood glucose (blood sugar) is too high. This happens when your body either doesn\'t make enough insulin or can\'t use the insulin it makes effectively.',
      'Common Symptoms':
          '• Increased thirst and urination\n• Extreme hunger\n• Unexplained weight loss\n• Fatigue\n• Blurred vision\n• Slow-healing sores',
      'Risk Factors':
          '• Family history\n• Obesity\n• Physical inactivity\n• Age (45 or older)\n• High blood pressure\n• History of gestational diabetes',
    },
    'Hypertension': {
      'What is Hypertension?':
          'Hypertension, or high blood pressure, is a condition where the force of blood against your artery walls is consistently too high. This can lead to serious health problems if left untreated.',
      'Common Symptoms':
          '• Most people have no symptoms\n• Headaches\n• Shortness of breath\n• Nosebleeds\n• Chest pain\n• Dizziness',
      'Risk Factors':
          '• Age\n• Family history\n• Obesity\n• High sodium diet\n• Physical inactivity\n• Excessive alcohol consumption',
    },
    'Diabetic Retinopathy': {
      'What is Diabetic Retinopathy?':
          'Diabetic retinopathy is a diabetes complication that affects the eyes. It is caused by damage to the blood vessels of the light-sensitive tissue at the back of the eye (retina).',
      'Common Symptoms':
          '• Spots or dark strings floating in your vision (floaters)\n• Blurred vision\n• Fluctuating vision\n• Impaired color vision\n• Dark or empty areas in your vision\n• Vision loss',
      'Risk Factors':
          '• Duration of diabetes\n• Poor control of blood sugar level\n• High blood pressure\n• High cholesterol\n• Pregnancy\n• Tobacco use',
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: diseases.length, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Refresh the UI when tab changes
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "Disease Management",
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: TColor.gray.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: TColor.primaryColor1,
              labelColor: TColor.primaryColor1,
              unselectedLabelColor: TColor.gray,
              tabs: diseases.map((disease) => Tab(text: disease)).toList(),
            ),
          ),
        ),
      ),
      backgroundColor: TColor.white,
      body: TabBarView(
        controller: _tabController,
        children:
            diseases.map((disease) => _buildDiseaseContent(disease)).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: () {
            if (diseases[_tabController.index] == 'Diabetes') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiabetesSymptomsView(
                    userData: widget.userData,
                  ),
                ),
              );
            } else if (diseases[_tabController.index] == 'Hypertension') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HypertensionSymptomsView(
                    userData: widget.userData,
                  ),
                ),
              );
            } else if (diseases[_tabController.index] ==
                'Diabetic Retinopathy') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiabeticRetinopathySymptomsView(
                    userData: widget.userData,
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: TColor.primaryColor1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          child: Text(
            "Think you have this disease?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiseaseContent(String disease) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: diseaseInfo[disease]!.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                entry.value,
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}

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
                  onPressed: null, // Disabled
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primaryColor1.withOpacity(0.5),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.photo_library),
                  label: Text('Gallery'),
                  onPressed: null, // Disabled
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primaryColor1.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: null, // Disabled
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primaryColor2.withOpacity(0.5),
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
