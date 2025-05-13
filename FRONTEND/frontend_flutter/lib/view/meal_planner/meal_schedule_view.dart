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

  DateTime selectedDate = DateTime.now();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.userData == null || widget.userData!['UserID'] == null) {
        _showError('Please log in to view meal schedule');
        Navigator.pop(context);
        return;
      }
      fetchMealsByDate(selectedDate);
    });
  }

  // Helper method to show error messages
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
    if (!mounted) return;

    setState(() {
      isLoading = true;
      // Clear previous data
      breakfastArr = [];
      lunchArr = [];
      dinnerArr = [];
      breakfastCalories = 0;
      lunchCalories = 0;
      dinnerCalories = 0;
      // Reset nutrition array
      nutritionArr.forEach((item) {
        item["value"] = "0";
      });
    });

    try {
      final formattedDate = _formatDateForApi(date);
      final userId = widget.userData?['UserID'];

      if (userId == null) {
        print("Error: No user ID found in userData");
        _showError('Error: User ID not found');
        return;
      }

      print("Fetching meals for user ID: $userId and date: $formattedDate");
      final url = ApiConstants.mealsDataByDate(userId, formattedDate);
      print("Fetching meals from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Fetched meal data: $data");

        // Check if there are any meals for this date
        bool hasMeals = (data['Breakfast']?.isNotEmpty ?? false) ||
            (data['Lunch']?.isNotEmpty ?? false) ||
            (data['Dinner']?.isNotEmpty ?? false);

        if (!hasMeals) {
          setState(() {
            isLoading = false;
            // Keep arrays empty and nutrition values at 0
          });
          return;
        }

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
                "category": meal['category'] ?? "Breakfast"
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
                "category": meal['category'] ?? "Lunch"
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
                "category": meal['category'] ?? "Dinner"
              });
              dinnerCalories += (meal['calories'] as num).toInt();
            }
          }

          // Update nutrition summary only if we have meals
          if (hasMeals) {
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
                  totalCarbs +=
                      (meal['carbohydrates_total_g'] as num).toDouble();
                }
              }
            }

            // Update nutrition array with calculated values
            nutritionArr[0]["value"] = totalCalories.toString();
            nutritionArr[1]["value"] = totalProtein.toStringAsFixed(1);
            nutritionArr[2]["value"] = totalFat.toStringAsFixed(1);
            nutritionArr[3]["value"] = totalCarbs.toStringAsFixed(1);
          }
        });
      } else {
        print("Error response: ${response.statusCode}");
        print("Error response body: ${response.body}");
        _showError('Error loading meals: ${response.statusCode}');
      }
    } catch (e) {
      print("Exception: $e");
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
            fullCalendarScroll: FullCalendarScroll.horizontal,
            fullCalendarDay: WeekDay.short,
            selectedDateColor: Colors.white,
            dateColor: Colors.black,
            locale: 'en',
            initialDate: selectedDate,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            onDateSelected: (date) {
              setState(() {
                selectedDate = date;
              });
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
                            DateFormat('MMM d, yyyy').format(selectedDate),
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          TextButton(
                            onPressed: () {
                              fetchMealsByDate(selectedDate);
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
                    if (breakfastArr.isEmpty &&
                        lunchArr.isEmpty &&
                        dinnerArr.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.no_meals_outlined,
                                size: 50,
                                color: TColor.gray,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "No meals logged for ${DateFormat('MMM d, yyyy').format(selectedDate)}",
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          // Breakfast Section
                          if (breakfastArr.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 8),
                                  child: Text(
                                    "Breakfast",
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: breakfastArr.length,
                                  itemBuilder: (context, index) {
                                    var mObj = Map<String, dynamic>.from(
                                        breakfastArr[index]);
                                    return _buildMealRow(mObj);
                                  },
                                ),
                              ],
                            ),

                          // Lunch Section
                          if (lunchArr.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 8),
                                  child: Text(
                                    "Lunch",
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: lunchArr.length,
                                  itemBuilder: (context, index) {
                                    var mObj = Map<String, dynamic>.from(
                                        lunchArr[index]);
                                    return _buildMealRow(mObj);
                                  },
                                ),
                              ],
                            ),

                          // Dinner Section
                          if (dinnerArr.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 8),
                                  child: Text(
                                    "Dinner",
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: dinnerArr.length,
                                  itemBuilder: (context, index) {
                                    var mObj = Map<String, dynamic>.from(
                                        dinnerArr[index]);
                                    return _buildMealRow(mObj);
                                  },
                                ),
                              ],
                            ),

                          // Nutrition Summary
                          if (breakfastArr.isNotEmpty ||
                              lunchArr.isNotEmpty ||
                              dinnerArr.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 8),
                                  child: Text(
                                    "Nutrition Summary",
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: nutritionArr.length,
                                  itemBuilder: (context, index) {
                                    var nObj =
                                        nutritionArr[index] as Map? ?? {};
                                    return NutritionRow(nObj: nObj);
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    SizedBox(height: media.width * 0.05),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMealRow(Map mObj) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mObj["name"]?.toString() ?? "Unknown Meal",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            mObj["time"]?.toString() ?? "",
                            style: TextStyle(
                              color: TColor.gray,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TColor.primaryColor2.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${mObj["calories"]?.toString() ?? "0"} kCal",
                        style: TextStyle(
                          color: TColor.primaryColor1,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNutrientInfo(
                  "Protein", "${mObj["protein"]?.toString() ?? "0"}g"),
              _buildNutrientInfo(
                  "Carbohydrates", "${mObj["carbs"]?.toString() ?? "0"}g"),
              _buildNutrientInfo("Fats", "${mObj["fat"]?.toString() ?? "0"}g"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: TColor.gray,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: TColor.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
