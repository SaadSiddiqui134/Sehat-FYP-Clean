import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/common_widget/workout_row.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import '../../common/colo_extension.dart';
import 'activity_tracker_view.dart';
import 'finished_workout_view.dart';
import 'notification_view.dart';
import '../sleep_tracker/sleep_tracker_view.dart';
import 'package:fitness/view/workout_tracker/workout_tracker_view.dart';
import 'package:fitness/view/meal_planner/meal_planner_view.dart';
import 'package:fitness/view/disease/disease_home.dart';
import 'dart:math' as math;

class HomeView extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const HomeView({Key? key, this.userData}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  List lastWorkoutArr = [
    {
      "name": "Full Body Workout",
      "image": "assets/img/Workout1.png",
      "kcal": "180",
      "time": "20",
      "progress": 0.3
    },
    {
      "name": "Lower Body Workout",
      "image": "assets/img/Workout2.png",
      "kcal": "200",
      "time": "30",
      "progress": 0.4
    },
    {
      "name": "Ab Workout",
      "image": "assets/img/Workout3.png",
      "kcal": "300",
      "time": "40",
      "progress": 0.7
    },
  ];
  List<int> showingTooltipOnSpots = [21];

  List<FlSpot> get allSpots => const [
        FlSpot(0, 20),
        FlSpot(1, 25),
        FlSpot(2, 40),
        FlSpot(3, 50),
        FlSpot(4, 35),
        FlSpot(5, 40),
        FlSpot(6, 30),
        FlSpot(7, 20),
        FlSpot(8, 25),
        FlSpot(9, 40),
        FlSpot(10, 50),
        FlSpot(11, 35),
        FlSpot(12, 50),
        FlSpot(13, 60),
        FlSpot(14, 40),
        FlSpot(15, 50),
        FlSpot(16, 20),
        FlSpot(17, 25),
        FlSpot(18, 40),
        FlSpot(19, 50),
        FlSpot(20, 35),
        FlSpot(21, 80),
        FlSpot(22, 30),
        FlSpot(23, 20),
        FlSpot(24, 25),
        FlSpot(25, 40),
        FlSpot(26, 50),
        FlSpot(27, 35),
        FlSpot(28, 50),
        FlSpot(29, 60),
        FlSpot(30, 40)
      ];

  List waterArr = [
    {"title": "6am - 8am", "subtitle": "600ml"},
    {"title": "9am - 11am", "subtitle": "500ml"},
    {"title": "11am - 2pm", "subtitle": "1000ml"},
    {"title": "2pm - 4pm", "subtitle": "700ml"},
    {"title": "4pm - now", "subtitle": "900ml"},
  ];

  late AnimationController _bmiAnimationController;
  late Animation<double> _bmiAnimation;

  @override
  void initState() {
    super.initState();

    _bmiAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _bmiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bmiAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    _bmiAnimationController.forward();
  }

  @override
  void dispose() {
    _bmiAnimationController.dispose();
    super.dispose();
  }

  List<PieChartSectionData> showingSections(double weight, double heightInCm) {
    double heightInM = heightInCm / 100;
    double bmi =
        weight > 0 && heightInM > 0 ? weight / (heightInM * heightInM) : 0;

    return List.generate(2, (i) {
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: TColor.primaryColor2,
            value: 33 * _bmiAnimation.value,
            title: '',
            radius: 55,
            titlePositionPercentageOffset: 0.55,
            badgeWidget: AnimatedBuilder(
              animation: _bmiAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bmiAnimation.value,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TColor.primaryColor1.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      bmi > 0 ? bmi.toStringAsFixed(1) : "N/A",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.white.withOpacity(0.8),
            value: 75,
            title: '',
            radius: 45,
            titlePositionPercentageOffset: 0.55,
          );
        default:
          throw Error();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final u_id = widget.userData?['userID'];
    final firstName = widget.userData?['UserFirstName'] ?? 'Guest';
    final lastname = widget.userData?['UserLastName'] ?? ' ';
    final email = widget.userData?['email'] ?? ' email@gmail.com';
    final gender = widget.userData?['gender'] ?? 'Male';
    final weight = double.tryParse(widget.userData?['weight'] ?? '80') ?? 80;
    final heightInCm =
        double.tryParse(widget.userData?['height'] ?? '170') ?? 170;

    // Calculate BMI
    final bmi = weight / (heightInCm / 100 * heightInCm / 100);

    // Create a new map with all existing userData plus BMI
    final updatedUserData = {
      ...?widget.userData,
      'calculatedBMI': bmi.toStringAsFixed(2),
    };

    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: allSpots,
        isCurved: false,
        barWidth: 3,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(colors: [
            TColor.primaryColor2.withOpacity(0.4),
            TColor.primaryColor1.withOpacity(0.1),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        dotData: FlDotData(show: false),
        gradient: LinearGradient(
          colors: TColor.primaryG,
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return Scaffold(
      backgroundColor: TColor.white,
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: [
        //       TColor.primaryColor1.withOpacity(0.3),
        //       TColor.primaryColor2.withOpacity(0.3),
        //     ],
        //   ),
        // ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome,",
                            style: TextStyle(
                              color: TColor.gray,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            firstName != 'Guest'
                                ? "${firstName.trim()} ${lastname.trim()}"
                                : "Guest",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const NotificationView(),
                            //   ),
                            // );
                          },
                          icon: Image.asset(
                            "assets/img/notification_active.png",
                            width: 25,
                            height: 25,
                            fit: BoxFit.fitHeight,
                          ))
                    ],
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Container(
                    height: media.width * 0.4,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          TColor.primaryColor2.withOpacity(0.8),
                          TColor.primaryColor1.withOpacity(0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: TColor.primaryColor2.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "BMI (Body Mass Index)",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Height: ${heightInCm.toStringAsFixed(1)} cm",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "Weight: ${weight.toStringAsFixed(1)} kg",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "BMI: ${(weight / (heightInCm / 100 * heightInCm / 100)).toStringAsFixed(1)}",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: AnimatedBuilder(
                                animation: _bmiAnimation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _bmiAnimation.value * 2 * math.pi,
                                    child: SizedBox(
                                      height: media.width * 0.25,
                                      width: media.width * 0.25,
                                      child: PieChart(
                                        PieChartData(
                                          pieTouchData:
                                              PieTouchData(enabled: false),
                                          startDegreeOffset: 250,
                                          borderData: FlBorderData(show: false),
                                          sectionsSpace: 1,
                                          centerSpaceRadius: 0,
                                          sections: showingSections(
                                              weight, heightInCm),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Expanded(
                            //   child: _buildNavigationCard(
                            //     "Workout Tracker",
                            //     "Track your fitness progress",
                            //     Icons.fitness_center,
                            //     TColor.primaryColor2,
                            //     () => Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) => WorkoutTrackerView(
                            //             userData: widget.userData),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            SizedBox(height: 15),
                            Expanded(
                              child: _buildNavigationCard(
                                "Meal Planner",
                                "Plan your nutrition",
                                Icons.restaurant_menu,
                                TColor.secondaryColor1,
                                () {
                                  // Create an updated userData map that includes BMI
                                  final bmi = weight /
                                      (heightInCm / 100 * heightInCm / 100);
                                  final updatedUserData = {
                                    ...?widget.userData,
                                    'calculatedBMI': bmi.toStringAsFixed(2),
                                    'weight': weight.toString(),
                                    'height': heightInCm.toString(),
                                  };

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MealPlannerView(
                                          userData: updatedUserData),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        _buildNavigationCard(
                          "Sleep Tracker",
                          "Monitor your sleep patterns",
                          Icons.bedtime,
                          TColor.primaryColor1,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SleepTrackerView(userData: widget.userData),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        _buildNavigationCard(
                          "Disease Management",
                          "Track and manage your health conditions",
                          Icons.medical_services,
                          TColor.secondaryColor1,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DiseaseHomeView(userData: updatedUserData),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
      );

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
      ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          TColor.primaryColor2.withOpacity(0.5),
          TColor.primaryColor1.withOpacity(0.5),
        ]),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 35),
          FlSpot(2, 70),
          FlSpot(3, 40),
          FlSpot(4, 80),
          FlSpot(5, 25),
          FlSpot(6, 70),
          FlSpot(7, 35),
        ],
      );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          TColor.secondaryColor2.withOpacity(0.5),
          TColor.secondaryColor1.withOpacity(0.5),
        ]),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: false,
        ),
        spots: const [
          FlSpot(1, 80),
          FlSpot(2, 50),
          FlSpot(3, 90),
          FlSpot(4, 40),
          FlSpot(5, 80),
          FlSpot(6, 35),
          FlSpot(7, 60),
        ],
      );

  SideTitles get rightTitles => SideTitles(
        getTitlesWidget: rightTitleWidgets,
        showTitles: true,
        interval: 20,
        reservedSize: 40,
      );

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(text,
        style: TextStyle(
          color: TColor.gray,
          fontSize: 12,
        ),
        textAlign: TextAlign.center);
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    var style = TextStyle(
      color: TColor.gray,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text('Sun', style: style);
        break;
      case 2:
        text = Text('Mon', style: style);
        break;
      case 3:
        text = Text('Tue', style: style);
        break;
      case 4:
        text = Text('Wed', style: style);
        break;
      case 5:
        text = Text('Thu', style: style);
        break;
      case 6:
        text = Text('Fri', style: style);
        break;
      case 7:
        text = Text('Sat', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }

  Widget _buildNavigationCard(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: color,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: color,
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                color: TColor.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
