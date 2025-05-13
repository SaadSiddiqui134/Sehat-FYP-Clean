import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../../api_constants.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/nutritions_row.dart';

class MealScheduleView extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const MealScheduleView({super.key, this.userData});

  @override
  State<MealScheduleView> createState() => _MealScheduleViewState();
}

class _MealScheduleViewState extends State<MealScheduleView> {
  CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();

  late DateTime _selectedDateAppBBar;
  bool isLoading = false;

  // Data structures for meals
  List<Map<String, dynamic>> breakfastArr = [];
  List<Map<String, dynamic>> lunchArr = [];
  List<Map<String, dynamic>> dinnerArr = [];

  // Nutrition summaries
  int breakfastCalories = 0;
  int lunchCalories = 0;
  int dinnerCalories = 0;

  List nutritionArr = [
    {
      "title": "Calories",
      "image": "assets/img/burn.png",
      "unit_name": "kCal",
      "value": "0",
      "max_value": "500",
    },
    {
      "title": "Proteins",
      "image": "assets/img/proteins.png",
      "unit_name": "g",
      "value": "0",
      "max_value": "100",
    },
    {
      "title": "Fats",
      "image": "assets/img/egg.png",
      "unit_name": "g",
      "value": "0",
      "max_value": "100",
    },
    {
      "title": "Carbs",
      "image": "assets/img/carbo.png",
      "unit_name": "g",
      "value": "0",
      "max_value": "100",
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedDateAppBBar = DateTime.now();

    // Initial data fetch for current date
    fetchMealsByDate(_selectedDateAppBBar);
  }

  // Format date to YYYY-MM-DD for API calls
  String _formatDateForApi(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Format time from API for display
  String _formatTimeForDisplay(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  // Fetch all meals for a specific date
  Future<void> fetchMealsByDate(DateTime date) async {
    setState(() {
      isLoading = true;
      // Clear previous data
      breakfastArr = [];
      lunchArr = [];
      dinnerArr = [];
      breakfastCalories = 0;
      lunchCalories = 0;
      dinnerCalories = 0;
    });

    try {
      final formattedDate = _formatDateForApi(date);
      final userId = widget.userData?['UserID'] ?? 1;

      print("Using user ID: $userId"); // Add logging
      final url = ApiConstants.mealsDataByDate(userId, formattedDate);
      print("Fetching meals from: $url"); // Add logging

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Fetched meal data: $data");

        setState(() {
          // Process breakfast meals
          if (data['Breakfast'] != null) {
            for (var meal in data['Breakfast']) {
              breakfastArr.add({
                "name": meal['name'],
                "time": _formatTimeForDisplay(meal['meal_log_time']),
                "image": "assets/img/m_1.png",
                "calories": meal['calories'],
                "protein": meal['protein_g'],
                "carbs": meal['carbohydrates_total_g'],
                "fat": meal['fat_total_g'],
                "category": "Breakfast"
              });
              breakfastCalories += (meal['calories'] as num).toInt();
            }
          }

          // Process lunch meals
          if (data['Lunch'] != null) {
            for (var meal in data['Lunch']) {
              lunchArr.add({
                "name": meal['name'],
                "time": _formatTimeForDisplay(meal['meal_log_time']),
                "image": "assets/img/m_2.png",
                "calories": meal['calories'],
                "protein": meal['protein_g'],
                "carbs": meal['carbohydrates_total_g'],
                "fat": meal['fat_total_g'],
                "category": "Lunch"
              });
              lunchCalories += (meal['calories'] as num).toInt();
            }
          }

          // Process dinner meals
          if (data['Dinner'] != null) {
            for (var meal in data['Dinner']) {
              dinnerArr.add({
                "name": meal['name'],
                "time": _formatTimeForDisplay(meal['meal_log_time']),
                "image": "assets/img/m_3.png",
                "calories": meal['calories'],
                "protein": meal['protein_g'],
                "carbs": meal['carbohydrates_total_g'],
                "fat": meal['fat_total_g'],
                "category": "Dinner"
              });
              dinnerCalories += (meal['calories'] as num).toInt();
            }
          }

          // Update nutrition summary
          int totalCalories = data['total_calories'] != null
              ? (data['total_calories'] as num).toInt()
              : 0;
          double totalProtein = 0;
          double totalFat = 0;
          double totalCarbs = 0;

          // Calculate total nutrition values from all meals
          for (var category in [
            data['Breakfast'],
            data['Lunch'],
            data['Dinner']
          ]) {
            if (category != null) {
              for (var meal in category) {
                totalProtein += (meal['protein_g'] as num).toDouble();
                totalFat += (meal['fat_total_g'] as num).toDouble();
                totalCarbs += (meal['carbohydrates_total_g'] as num).toDouble();
              }
            }
          }

          // Update nutrition array with calculated values
          nutritionArr[0]["value"] = totalCalories.toString();
          nutritionArr[1]["value"] = totalProtein.toStringAsFixed(1);
          nutritionArr[2]["value"] = totalFat.toStringAsFixed(1);
          nutritionArr[3]["value"] = totalCarbs.toStringAsFixed(1);
        });
      } else {
        print("Error response: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading meals: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch breakfast meals for a specific date
  Future<void> fetchBreakfastMeals(DateTime date) async {
    setState(() {
      isLoading = true;
      breakfastArr = [];
      breakfastCalories = 0;
    });

    try {
      final formattedDate = _formatDateForApi(date);
      final userId = widget.userData?['UserID'] ?? 1;

      final url = ApiConstants.mealsDataByDate(userId, formattedDate);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          if (data['Breakfast'] != null) {
            for (var meal in data['Breakfast']) {
              breakfastArr.add({
                "name": meal['name'],
                "time": _formatTimeForDisplay(meal['meal_log_time']),
                "image": "assets/img/m_1.png",
                "calories": meal['calories'],
                "category": "Breakfast"
              });
              breakfastCalories += (meal['calories'] as num).toInt();
            }
          }
        });
      } else {
        print("Error response: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading breakfast meals')),
        );
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch lunch meals for a specific date
  Future<void> fetchLunchMeals(DateTime date) async {
    setState(() {
      isLoading = true;
      lunchArr = [];
      lunchCalories = 0;
    });

    try {
      final formattedDate = _formatDateForApi(date);
      final userId = widget.userData?['UserID'] ?? 1;

      final url = ApiConstants.mealsDataByDate(userId, formattedDate);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          if (data['Lunch'] != null) {
            for (var meal in data['Lunch']) {
              lunchArr.add({
                "name": meal['name'],
                "time": _formatTimeForDisplay(meal['meal_log_time']),
                "image": "assets/img/m_2.png",
                "calories": meal['calories'],
                "category": "Lunch"
              });
              lunchCalories += (meal['calories'] as num).toInt();
            }
          }
        });
      } else {
        print("Error response: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading lunch meals')),
        );
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch dinner meals for a specific date
  Future<void> fetchDinnerMeals(DateTime date) async {
    setState(() {
      isLoading = true;
      dinnerArr = [];
      dinnerCalories = 0;
    });

    try {
      final formattedDate = _formatDateForApi(date);
      final userId = widget.userData?['UserID'] ?? 1;

      final url = ApiConstants.mealsDataByDate(userId, formattedDate);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          if (data['Dinner'] != null) {
            for (var meal in data['Dinner']) {
              dinnerArr.add({
                "name": meal['name'],
                "time": _formatTimeForDisplay(meal['meal_log_time']),
                "image": "assets/img/m_3.png",
                "calories": meal['calories'],
                "category": "Dinner"
              });
              dinnerCalories += (meal['calories'] as num).toInt();
            }
          }
        });
      } else {
        print("Error response: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dinner meals')),
        );
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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
          "Meal Schedule",
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarAgenda(
            controller: _calendarAgendaControllerAppBar,
            appbar: false,
            selectedDayPosition: SelectedDayPosition.center,
            leading: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/img/ArrowLeft.png",
                  width: 15,
                  height: 15,
                )),
            training: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/img/ArrowRight.png",
                  width: 15,
                  height: 15,
                )),
            weekDay: WeekDay.short,
            dayNameFontSize: 12,
            dayNumberFontSize: 16,
            dayBGColor: Colors.grey.withOpacity(0.15),
            titleSpaceBetween: 15,
            backgroundColor: Colors.transparent,
            // fullCalendar: false,
            fullCalendarScroll: FullCalendarScroll.horizontal,
            fullCalendarDay: WeekDay.short,
            selectedDateColor: Colors.white,
            dateColor: Colors.black,
            locale: 'en',

            initialDate: DateTime.now(),
            calendarEventColor: TColor.primaryColor2,
            firstDate: DateTime.now().subtract(const Duration(days: 140)),
            lastDate: DateTime.now().add(const Duration(days: 60)),

            onDateSelected: (date) {
              setState(() {
                _selectedDateAppBBar = date;
              });
              // Fetch meals for the selected date
              fetchMealsByDate(date);
            },
            selectedDayLogo: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: TColor.primaryG,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  color: TColor.primaryColor1,
                ),
              ),
            ),
          if (!isLoading)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Today's Meal",
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          TextButton(
                            onPressed: () {
                              // Refresh all meals
                              fetchMealsByDate(_selectedDateAppBBar);
                            },
                            child: Text(
                              "${breakfastArr.length + lunchArr.length + dinnerArr.length} Items | ${breakfastCalories + lunchCalories + dinnerCalories} calories",
                              style:
                                  TextStyle(color: TColor.gray, fontSize: 12),
                            ),
                          )
                        ],
                      ),
                    ),
                    (breakfastArr.isEmpty &&
                            lunchArr.isEmpty &&
                            dinnerArr.isEmpty)
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Text(
                              "No meals logged for this date",
                              style:
                                  TextStyle(color: TColor.gray, fontSize: 14),
                            ),
                          )
                        : Column(
                            children: [
                              // Display breakfast meals
                              ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: breakfastArr.length,
                                  itemBuilder: (context, index) {
                                    var mObj = Map<String, dynamic>.from(
                                        breakfastArr[index]);
                                    mObj["category"] = "Breakfast";
                                    return _buildMealRow(mObj, index);
                                  }),
                              // Display lunch meals
                              ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: lunchArr.length,
                                  itemBuilder: (context, index) {
                                    var mObj = Map<String, dynamic>.from(
                                        lunchArr[index]);
                                    mObj["category"] = "Lunch";
                                    return _buildMealRow(mObj, index);
                                  }),
                              // Display dinner meals
                              ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: dinnerArr.length,
                                  itemBuilder: (context, index) {
                                    var mObj = Map<String, dynamic>.from(
                                        dinnerArr[index]);
                                    mObj["category"] = "Dinner";
                                    return _buildMealRow(mObj, index);
                                  }),
                            ],
                          ),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${DateFormat('MMM d, yyyy').format(_selectedDateAppBBar)} Meal Nutritions",
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: nutritionArr.length,
                        itemBuilder: (context, index) {
                          var nObj = nutritionArr[index] as Map? ?? {};

                          return NutritionRow(
                            nObj: nObj,
                          );
                        }),
                    SizedBox(
                      height: media.width * 0.05,
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildMealRow(Map mObj, int index) {
    // Debug print to see what's in the meal object
    print("Meal object: $mObj");
    print("Category value: ${mObj["category"]}");

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mObj["name"].toString(),
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  "Category: ${mObj["category"] ?? "Meal"}",
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${mObj["calories"]} kCal",
            style: TextStyle(
                color: TColor.primaryColor1,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
