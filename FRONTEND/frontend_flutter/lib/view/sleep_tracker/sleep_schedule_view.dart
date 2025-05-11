import 'dart:convert';
import 'dart:math';
import 'package:fitness/view/sleep_tracker/add_sleepLog_form.dart';
import 'package:http/http.dart' as http;
import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:fitness/view/sleep_tracker/add_sleepLog_form.dart';
import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:fitness/api_constants.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/today_sleep_schedule_row.dart';

class SleepScheduleView extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback? onSleepLogAdded;
  const SleepScheduleView({Key? key, this.userData, this.onSleepLogAdded})
      : super(key: key);

  @override
  State<SleepScheduleView> createState() => _SleepScheduleViewState();
}

class _SleepScheduleViewState extends State<SleepScheduleView> {
  CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();
  late DateTime _selectedDateAppBar;

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

  List<int> showingTooltipOnSpots = [4];

  List<dynamic> userSleepLogs = [];
  int latestHours = 0;
  int latestMinutes = 0;
  double latestRatio = 0.0;
  @override
  void initState() {
    super.initState();
    _selectedDateAppBar = DateTime.now();

    fetchSleepLogs();
  }

  Future<void> fetchSleepLogs() async {
    final userIDForSleepLogs = widget.userData?['UserID'];
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.getSleepLogsUser(userIDForSleepLogs)));

      print("response GET sleepLog code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['data'];

        if (data is List && data.isNotEmpty) {
          // Sort the data by date (most recent first)
          data.sort((a, b) {
            try {
              // Assuming date format is YYYY-MM-DD
              DateTime dateA = DateTime.parse(a['date'] ?? "");
              DateTime dateB = DateTime.parse(b['date'] ?? "");
              return dateB.compareTo(dateA); // Descending order
            } catch (e) {
              print(
                  "Error parsing date during sort in fetchSleepLogs: $e, Data: a=${a['date']}, b=${b['date']}");
            }
            return 0;
          });

          // Calculate based on the first item AFTER sorting
          final latestLog = data.first;
          final hours = latestLog?['duration_hours'] ?? 0;
          final minutes = latestLog?['duration_minutes'] ?? 0;
          final totalMinutes = hours * 60 + minutes;
          final idealMinutes = 8 * 60 + 30; // 510
          final ratio = (totalMinutes / idealMinutes).clamp(0.0, 1.0);

          setState(() {
            userSleepLogs = List<dynamic>.from(data);
            latestHours = hours;
            latestMinutes = minutes;
            latestRatio = ratio;
          });
        } else {
          // Handle empty data case
          setState(() {
            userSleepLogs = [];
            latestHours = 0;
            latestMinutes = 0;
            latestRatio = 0.0;
          });
        }
      } else {
        print("Failed to load sleep logs: ${response.statusCode}");
        setState(() {
          userSleepLogs = [];
          latestHours = 0;
          latestMinutes = 0;
          latestRatio = 0.0;
        });
      }
    } catch (e) {
      print("Error fetching or processing sleep logs: $e");
      setState(() {
        userSleepLogs = [];
        latestHours = 0;
        latestMinutes = 0;
        latestRatio = 0.0;
      });
    }
  }

  String formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final time = DateTime.parse(iso);
      final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (e) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
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
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Sleep Schedule",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/img/more_btn.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(20),
                    height: media.width * 0.4,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          TColor.primaryColor2.withOpacity(0.4),
                          TColor.primaryColor1.withOpacity(0.4),
                        ]),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Ideal Hours for Sleep",
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "8hours 30minutes",
                                style: TextStyle(
                                    color: TColor.primaryColor2,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                            ]),
                        Image.asset(
                          "assets/img/sleep_timer.png",
                          width: media.width * 0.25,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  // child: Text(
                  //   "Your Schedule",
                  //   style: TextStyle(
                  //       color: TColor.black,
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.w700),
                  // ),
                ),
                // CalendarAgenda(
                //   controller: _calendarAgendaControllerAppBar,
                //   appbar: false,
                //   selectedDayPosition: SelectedDayPosition.center,
                //   leading: IconButton(
                //       onPressed: () {},
                //       icon: Image.asset(
                //         "assets/img/ArrowLeft.png",
                //         width: 15,
                //         height: 15,
                //       )),
                //   training: IconButton(
                //       onPressed: () {},
                //       icon: Image.asset(
                //         "assets/img/ArrowRight.png",
                //         width: 15,
                //         height: 15,
                //       )),
                //   weekDay: WeekDay.short,
                //   dayNameFontSize: 12,
                //   dayNumberFontSize: 16,
                //   dayBGColor: Colors.grey.withOpacity(0.15),
                //   titleSpaceBetween: 15,
                //   backgroundColor: Colors.transparent,
                //   // fullCalendar: false,
                //   fullCalendarScroll: FullCalendarScroll.horizontal,
                //   fullCalendarDay: WeekDay.short,
                //   selectedDateColor: Colors.white,
                //   dateColor: Colors.black,
                //   locale: 'en',

                //   initialDate: DateTime.now(),
                //   calendarEventColor: TColor.primaryColor2,
                //   firstDate: DateTime.now().subtract(const Duration(days: 140)),
                //   lastDate: DateTime.now().add(const Duration(days: 60)),

                //   onDateSelected: (date) {
                //     _selectedDateAppBBar = date;
                //   },
                //   selectedDayLogo: Container(
                //     width: double.maxFinite,
                //     height: double.maxFinite,
                //     decoration: BoxDecoration(
                //       gradient: LinearGradient(
                //           colors: TColor.primaryG,
                //           begin: Alignment.topCenter,
                //           end: Alignment.bottomCenter),
                //       borderRadius: BorderRadius.circular(10.0),
                //     ),
                //   ),
                // ),
                //  SizedBox(
                //     height: media.width * 0.03,
                //   ),

                // ListView.builder(
                //     padding: const EdgeInsets.symmetric(horizontal: 20),
                //     physics: const NeverScrollableScrollPhysics(),
                //     shrinkWrap: true,
                //     itemCount: todaySleepArr.length,
                //     itemBuilder: (context, index) {
                //       var sObj = todaySleepArr[index] as Map? ?? {};
                //       return TodaySleepScheduleRow(
                //         sObj: sObj,
                //       );
                //     }),
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 50,
                      dataRowHeight: 56,
                      horizontalMargin: 24,
                      columnSpacing: 30,
                      headingRowColor: MaterialStateProperty.all(
                          TColor.primaryColor2.withOpacity(0.1)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      columns: [
                        DataColumn(
                          label: Text(
                            'Date',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: TColor.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Sleep Start',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: TColor.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Sleep End',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: TColor.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Duration',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: TColor.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                      rows: userSleepLogs.take(7).map((log) {
                        final date = log['date'] ?? '';
                        final start = formatTime(log['sleep_start']);
                        final end = formatTime(log['sleep_end']);
                        final duration =
                            '${log['duration_hours'] ?? 0}h ${log['duration_minutes'] ?? 0}m';

                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                date,
                                style: TextStyle(
                                  color: TColor.black.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                start,
                                style: TextStyle(
                                  color: TColor.black.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                end,
                                style: TextStyle(
                                  color: TColor.black.withOpacity(0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: TColor.primaryColor2.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  duration,
                                  style: TextStyle(
                                    color: TColor.primaryColor2,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),

                SizedBox(
                  height: media.width * 0.03,
                ),

                Container(
                    width: double.maxFinite,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          TColor.secondaryColor2.withOpacity(0.4),
                          TColor.secondaryColor1.withOpacity(0.4)
                        ]),
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "You will get ${latestHours}hrs and ${latestMinutes} min"
                          "\nfor tonight",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SimpleAnimationProgressBar(
                              height: 15,
                              width: media.width - 80,
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: Colors.purple,
                              ratio: latestRatio,
                              direction: Axis.horizontal,
                              curve: Curves.fastLinearToSlowEaseIn,
                              duration: const Duration(seconds: 1),
                              borderRadius: BorderRadius.circular(7.5),
                              gradientColor: LinearGradient(
                                  colors: TColor.secondaryG,
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight),
                            ),
                            Text(
                              "${(latestRatio * 100).toStringAsFixed(0)}%",
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ],
            ),
            SizedBox(
              height: media.width * 0.05,
            ),
          ],
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SleepAddAlarmView2(
                date: DateTime.now(),
                userData: widget.userData,
                onSleepLogAdded: widget.onSleepLogAdded,
              ),
            ),
          );
          if (result == true) {
            fetchSleepLogs();
          }
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.secondaryG),
              borderRadius: BorderRadius.circular(27.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
              ]),
          alignment: Alignment.center,
          child: Icon(
            Icons.add,
            size: 20,
            color: TColor.white,
          ),
        ),
      ),
    );
  }
}
