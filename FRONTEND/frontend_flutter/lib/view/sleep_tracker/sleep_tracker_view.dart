import 'package:fitness/view/sleep_tracker/sleep_schedule_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitness/api_constants.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/today_sleep_schedule_row.dart';

class SleepTrackerView extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const SleepTrackerView({Key? key, this.userData}) : super(key: key);

  @override
  State<SleepTrackerView> createState() => _SleepTrackerViewState();
}

class _SleepTrackerViewState extends State<SleepTrackerView> {
  List todaySleepArr = [
    {
      "name": "Bedtime",
      "image": "assets/img/bed.png",
      "time": "01/06/2023 09:00 PM",
      "duration": "in 6hours 22minutes"
    },
    {
      "name": "Alarm",
      "image": "assets/img/alaarm.png",
      "time": "02/06/2023 05:10 AM",
      "duration": "in 14hours 30minutes"
    },
  ];

  List findEatArr = [
    {
      "name": "Breakfast",
      "image": "assets/img/m_3.png",
      "number": "120+ Foods"
    },
    {"name": "Lunch", "image": "assets/img/m_4.png", "number": "130+ Foods"},
  ];

  List<int> showingTooltipOnSpots = [4];
  List<Map<String, dynamic>> sleepData = [];
  double avgSleep = 0;
  double totalSleepTime = 0;
  bool isLoading = true;
  double maxYValue = 10.0; // Default maxY

  @override
  void initState() {
    super.initState();
    fetchSleepData();
  }

  Future<void> fetchSleepData() async {
    if (widget.userData == null) return;

    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      final response = await http.get(
        Uri.parse(
            ApiConstants.getSleepLogsUserChart(widget.userData!['UserID'])),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final List<Map<String, dynamic>> dailyData =
              List<Map<String, dynamic>>.from(data['data']['daily_data']);
          final double currentAvgSleep = data['data']['avg_sleep'];
          final double currentTotalSleepTime = data['data']['total_sleep_time'];

          // Calculate max Y value based on data
          double maxHours = 10.0; // Minimum maxY
          if (dailyData.isNotEmpty) {
            maxHours = dailyData
                .map((d) => d['hours'] as double)
                .reduce((a, b) => a > b ? a : b);
            maxHours =
                (maxHours / 2).ceil() * 2; // Round up to nearest even number
            if (maxHours < 10) maxHours = 10; // Ensure minimum
            maxHours += 2; // Add some padding
          }

          setState(() {
            sleepData = dailyData;
            avgSleep = currentAvgSleep;
            totalSleepTime = currentTotalSleepTime;
            maxYValue = maxHours; // Update maxYValue
            isLoading = false;
          });
          print('Sleep data loaded: $sleepData');
          print('Average sleep: $avgSleep');
          print('Total sleep time: $totalSleepTime');
          print('Calculated maxYValue: $maxYValue');
        }
      }
    } catch (e) {
      print('Error fetching sleep data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
      ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          TColor.primaryColor2,
          TColor.primaryColor1,
        ]),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(colors: [
            TColor.primaryColor2,
            TColor.white,
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        spots: List.generate(7, (index) {
          if (index < sleepData.length) {
            final hours = sleepData[index]['hours'] as double;
            print('Creating spot for day ${index + 1} with hours $hours');
            return FlSpot(index.toDouble() + 1, hours);
          }
          return FlSpot(index.toDouble() + 1, 0.0);
        }),
      );

  SideTitles get rightTitles => SideTitles(
        getTitlesWidget: rightTitleWidgets,
        showTitles: true,
        interval: maxYValue / 5, // Dynamic interval based on maxYValue
        reservedSize: 40,
      );

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    // Only show labels if they are within the range 0 to maxYValue
    if (value < 0 || value > maxYValue) {
      return Container();
    }
    // Show labels at calculated intervals
    if (value % (maxYValue / 5) != 0 && value != 0) {
      return Container();
    }

    final text = '${value.toInt()}h'; // Format label as hours

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

    // Value should be between 1 and 7
    if (value < 1 || value > 7) {
      return const Text('');
    }

    final index = value.toInt() - 1;
    if (index < 0 || index >= sleepData.length) {
      return const Text('');
    }

    final day = sleepData[index]['day'].toString().substring(0, 3);
    print('Creating bottom title for value $value, index $index, day $day');

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: Text(day, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    // Ensure lineBarsData1 is accessed only when not loading and data is available
    final tooltipsOnBar =
        !isLoading && lineBarsData1.isNotEmpty ? lineBarsData1[0] : null;

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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              "Sleep Tracker",
              style: TextStyle(
                color: TColor.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              "Track your sleep pattern",
              style: TextStyle(
                color: TColor.gray.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: TColor.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: TColor.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sleep Duration",
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 15),
                              Container(
                                height: media.width * 0.5,
                                child: LineChart(
                                  LineChartData(
                                    showingTooltipIndicators: tooltipsOnBar !=
                                            null
                                        ? showingTooltipOnSpots.map((index) {
                                            // Add bounds check for tooltipsOnBar.spots
                                            if (index >= 0 &&
                                                index <
                                                    tooltipsOnBar
                                                        .spots.length) {
                                              return ShowingTooltipIndicators([
                                                LineBarSpot(
                                                  tooltipsOnBar,
                                                  lineBarsData1
                                                      .indexOf(tooltipsOnBar),
                                                  tooltipsOnBar.spots[index],
                                                ),
                                              ]);
                                            } else {
                                              return ShowingTooltipIndicators(
                                                  []); // Return empty if index is out of bounds
                                            }
                                          }).toList()
                                        : [], // Empty list if tooltipsOnBar is null
                                    lineTouchData: LineTouchData(
                                      enabled: true,
                                      handleBuiltInTouches: false,
                                      touchCallback: (FlTouchEvent event,
                                          LineTouchResponse? response) {
                                        if (response == null ||
                                            response.lineBarSpots == null) {
                                          return;
                                        }
                                        if (event is FlTapUpEvent) {
                                          final spotIndex = response
                                              .lineBarSpots!.first.spotIndex;
                                          showingTooltipOnSpots.clear();
                                          setState(() {
                                            showingTooltipOnSpots
                                                .add(spotIndex);
                                          });
                                        }
                                      },
                                      mouseCursorResolver: (FlTouchEvent event,
                                          LineTouchResponse? response) {
                                        if (response == null ||
                                            response.lineBarSpots == null) {
                                          return SystemMouseCursors.basic;
                                        }
                                        return SystemMouseCursors.click;
                                      },
                                      getTouchedSpotIndicator:
                                          (LineChartBarData barData,
                                              List<int> spotIndexes) {
                                        return spotIndexes.map((index) {
                                          return TouchedSpotIndicatorData(
                                            FlLine(
                                              color: Colors.transparent,
                                            ),
                                            FlDotData(
                                              show: true,
                                              getDotPainter: (spot, percent,
                                                      barData, index) =>
                                                  FlDotCirclePainter(
                                                radius: 3,
                                                color: Colors.white,
                                                strokeWidth: 1,
                                                strokeColor:
                                                    TColor.primaryColor2,
                                              ),
                                            ),
                                          );
                                        }).toList();
                                      },
                                      touchTooltipData: LineTouchTooltipData(
                                        tooltipBgColor: TColor.secondaryColor1,
                                        tooltipRoundedRadius: 5,
                                        getTooltipItems:
                                            (List<LineBarSpot> lineBarsSpot) {
                                          return lineBarsSpot
                                              .map((lineBarSpot) {
                                            return LineTooltipItem(
                                              "${lineBarSpot.y.toInt()} hours",
                                              const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          }).toList();
                                        },
                                      ),
                                    ),
                                    lineBarsData: lineBarsData1,
                                    minY: 0, // Start Y axis at 0
                                    maxY: maxYValue, // Use dynamic maxYValue
                                    titlesData: FlTitlesData(
                                        show: true,
                                        leftTitles: AxisTitles(),
                                        topTitles: AxisTitles(),
                                        bottomTitles: AxisTitles(
                                          sideTitles: bottomTitles,
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: rightTitles,
                                        )),
                                    gridData: FlGridData(
                                      show: true,
                                      drawHorizontalLine: true,
                                      horizontalInterval: 2,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: TColor.gray.withOpacity(0.15),
                                          strokeWidth: 2,
                                        );
                                      },
                                    ),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: media.width * 0.08),
                        Container(
                          width: double.maxFinite,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                TColor.primaryColor2.withOpacity(0.8),
                                TColor.primaryColor1.withOpacity(0.9),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: TColor.primaryColor2.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Average Duration Of Sleep",
                                style: TextStyle(
                                  color: TColor.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  Text(
                                    "${avgSleep.toString()}h",
                                    style: TextStyle(
                                      color: TColor.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Image.asset(
                                      "assets/img/sleep_timer.png",
                                      width: media.width * 0.15,
                                      color: TColor.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: media.width * 0.08),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            color: TColor.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Daily Sleep Schedule",
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Check your detailed sleep history",
                                    style: TextStyle(
                                      color: TColor.gray.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Container(
                                height: 35,
                                width: 90,
                                child: RoundButton(
                                  title: "View All",
                                  type: RoundButtonType.bgGradient,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SleepScheduleView(
                                            userData: widget.userData),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: media.width * 0.05),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
