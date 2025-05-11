import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../api_constants.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/find_eat_cell.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/today_meal_row.dart';
import 'meal_food_details_view.dart';
import 'meal_schedule_view.dart';
import 'dart:convert';
import 'dart:async';

class MealPlannerView extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const MealPlannerView({Key? key, this.userData}) : super(key: key);

  @override
  State<MealPlannerView> createState() => _MealPlannerViewState();
}

class _MealPlannerViewState extends State<MealPlannerView>
    with WidgetsBindingObserver {
  List todayMealArr = [
    {
      "name": "Salmon Nigiri",
      "image": "assets/img/m_1.png",
      "time": "28/05/2023 07:00 AM"
    },
    {
      "name": "Lowfat Milk",
      "image": "assets/img/m_2.png",
      "time": "28/05/2023 08:00 AM"
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

  // Nutrition data
  late final int totalCalories;
  int consumedCalories = 0;

  // Add this variable to track the current query
  String currentQuery = "";

  TextEditingController searchController = TextEditingController();
  String selectedMealType = "Breakfast";
  bool isLoading = false;
  Map<String, dynamic>? nutritionData;
  Timer? _refreshTimer;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Calculate calories based on user data
    totalCalories = calculateDailyCalories();

    // Register this object as an observer to detect app state changes
    WidgetsBinding.instance.addObserver(this);

    // Initialize with userData if available
    if (widget.userData != null) {
      // Example: You could calculate calorie needs based on user data
      if (widget.userData!.containsKey('calculatedBMI') &&
          widget.userData!.containsKey('weight') &&
          widget.userData!.containsKey('height')) {
        // Here you could set personalized nutrition targets
        // For example, update totalCalories based on weight, height, BMI
      }
    }

    // Add a listener to update currentQuery whenever the text changes
    searchController.addListener(() {
      setState(() {
        currentQuery = searchController.text;
      });
    });

    // Initial fetch
    fetchMealsByDate();

    // Set up a timer to refresh data every 5 minutes
    _refreshTimer = Timer.periodic(Duration(minutes: 2), (timer) {
      if (mounted) {
        fetchMealsByDate();
      }
    });
  }

  @override
  void dispose() {
    // Remove observer and cancel timer
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when app resumes from background
    if (state == AppLifecycleState.resumed) {
      fetchMealsByDate();
    }
  }

  // Add a manual refresh method
  Future<void> refreshMeals() async {
    return fetchMealsByDate();
  }

  // Function to fetch nutrition data
  Future<void> fetchNutritionData(String query) async {
    if (query.isEmpty) return;

    // Update currentQuery with the latest search
    setState(() {
      currentQuery = query;
      isLoading = true;
      nutritionData = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.apiUrl}$query'),
        headers: {
          'X-Api-Key': ApiConstants.apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nutritionData = data;
          isLoading = false;
        });

        // Show nutrition data in a dialog
        _showNutritionDialog(data);
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Dialog to display nutrition info and confirm logging
  void _showNutritionDialog(Map<String, dynamic> data) {
    // Extract the first item from the items array
    if (data['items'] == null || data['items'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No nutrition data found')),
      );
      return;
    }

    final item = data['items'][0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nutrition Info: ${item['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Meal type: $selectedMealType'),
              SizedBox(height: 10),
              Text('Calories: ${item['calories']} kCal'),
              Text('Protein: ${item['protein_g']}g'),
              Text('Carbs: ${item['carbohydrates_total_g']}g'),
              Text('Fat: ${item['fat_total_g']}g'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logMeal(item);
            },
            child: Text('Log Meal'),
          ),
        ],
      ),
    );
  }

  // Function to log the meal to your backend
  Future<void> _logMeal(Map<String, dynamic> item) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Use the user ID from userData
      int userId = widget.userData?['userID'] ?? 1;

      final mealData = {
        'user_id': userId,
        'name': item['name'],
        'category': selectedMealType,
        'calories': item['calories'],
        'serving_size': item['serving_size_g'],
        'protein_g': item['protein_g'],
        'carbohydrates_total_g': item['carbohydrates_total_g'],
        'fat_saturated': item['fat_saturated_g'],
        'fat_total_g': item['fat_total_g'],
        'sugar_g': item['sugar_g'],
        'fiber_g': item['fiber_g'],
        'potassium_mg': item['potassium_mg'],
        'sodium_g': item['sodium_mg'] / 1000, // Convert mg to g
        'cholesterol_mg': item['cholesterol_mg'],
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/meals/log/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(mealData),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Meal logged successfully!')),
        );
        // Refresh the meals data
        fetchMealsByDate();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging meal: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Add this function to your _MealPlannerViewState class
  Future<void> fetchMealsByDate() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get today's date in the format YYYY-MM-DD
      final now = DateTime.now();
      final formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // Use user ID from userData, or default to 1
      final userId = widget.userData?['userID'] ?? 1;
      print("Using user ID: $userId");

      // Construct the URL
      final url = ApiConstants.mealsDataByDate(userId, formattedDate);
      print("Request URL: $url");

      // Make the API request
      print("Sending GET request...");
      print("Using date: $formattedDate");
      print("Using user ID: $userId");
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Log response details
      print("Response status code: ${response.statusCode}");
      print("Response headers: ${response.headers}");
      print("Response body: ${response.body}");

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Decoded JSON data: $data");

        // Log meal counts
        if (data['Breakfast'] != null) {
          print("Breakfast meals: ${data['Breakfast'].length}");
        }
        if (data['Lunch'] != null) {
          print("Lunch meals: ${data['Lunch'].length}");
        }
        if (data['Dinner'] != null) {
          print("Dinner meals: ${data['Dinner'].length}");
        }
        print("Total calories: ${data['total_calories']}");

        // Update your UI with the meal data
        setState(() {
          // Create a new list for today's meals
          List todayMeals = [];

          // Add breakfast meals
          if (data['Breakfast'] != null) {
            for (var meal in data['Breakfast']) {
              print("Adding breakfast meal: ${meal['name']}");
              todayMeals.add({
                "name": meal['name'],
                "image": "assets/img/m_1.png", // Default image
                "time": meal['meal_log_time'],
                "calories": meal['calories'],
                "category": "Breakfast"
              });
            }
          }

          // Add lunch meals
          if (data['Lunch'] != null) {
            for (var meal in data['Lunch']) {
              print("Adding lunch meal: ${meal['name']}");
              todayMeals.add({
                "name": meal['name'],
                "image": "assets/img/m_2.png", // Default image
                "time": meal['meal_log_time'],
                "calories": meal['calories'],
                "category": "Lunch"
              });
            }
          }

          // Add dinner meals
          if (data['Dinner'] != null) {
            for (var meal in data['Dinner']) {
              print("Adding dinner meal: ${meal['name']}");
              todayMeals.add({
                "name": meal['name'],
                "image": "assets/img/m_3.png", // Default image
                "time": meal['meal_log_time'],
                "calories": meal['calories'],
                "category": "Dinner"
              });
            }
          }

          print("Final todayMeals list: $todayMeals");
          print("todayMeals length: ${todayMeals.length}");

          // Update todayMealArr with the fetched meals
          todayMealArr = todayMeals;
          print("Updated todayMealArr. Length: ${todayMealArr.length}");

          // Update consumed calories
          consumedCalories = data['total_calories'] != null
              ? data['total_calories'].toInt()
              : 0;
          print("Updated consumedCalories: $consumedCalories");
        });
      } else {
        print("Error response: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading meals: ${response.statusCode}')),
        );
      }
    } catch (e, stackTrace) {
      print("Exception in fetchMealsByDate: $e");
      print("Stack trace: $stackTrace");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        print('Image selected: ${image.path}');
        // Read the image file as bytes
        final bytes = await image.readAsBytes();
        print('Image bytes length: ${bytes.length}');
        // Convert to base64
        final base64Image = base64Encode(bytes);
        print('Base64 image length: ${base64Image.length}');

        setState(() {
          isLoading = true;
        });

        try {
          print('Sending request to: ${ApiConstants.detectFood}');
          // Send to backend for food detection
          final response = await http.post(
            Uri.parse(ApiConstants.detectFood),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'image': base64Image,
            }),
          );

          print('Response status code: ${response.statusCode}');
          print('Response body: ${response.body}');

          setState(() {
            isLoading = false;
          });

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            // Show the detected food in a dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Food Detected'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Detected Food: ${data['food']}'),
                    Text(
                        'Confidence: ${(data['confidence'] * 100).toStringAsFixed(1)}%'),
                    SizedBox(height: 10),
                    Text('Would you like to log this food?'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Pre-fill the search with the detected food
                      searchController.text = data['food'];
                      fetchNutritionData(data['food']);
                    },
                    child: Text('Log Food'),
                  ),
                ],
              ),
            );
          } else {
            print('Error response: ${response.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error detecting food: ${response.body}')),
            );
          }
        } catch (e, stackTrace) {
          print('Error in API call: $e');
          print('Stack trace: $stackTrace');
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error picking image: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('Take Photo'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.camera);
                  },
                ),
                GestureDetector(
                  child: ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Choose from Gallery'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
          "Meal Planner",
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
      body: RefreshIndicator(
        onRefresh: refreshMeals,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: TColor.lightGray,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: TColor.gray,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Log food",
                                hintStyle: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 14,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  currentQuery = value;
                                });
                              },
                              onSubmitted: (value) {
                                fetchNutritionData(value);
                              },
                            ),
                          ),
                          if (isLoading)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: TColor.primaryColor1,
                              ),
                            )
                          else
                            IconButton(
                              icon: Icon(Icons.search,
                                  color: TColor.primaryColor1, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              onPressed: () {
                                fetchNutritionData(searchController.text);
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: TColor.secondaryColor1.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                isExpanded: true,
                                value: selectedMealType,
                                items: ["Breakfast", "Lunch", "Dinner"]
                                    .map((name) => DropdownMenuItem(
                                          value: name,
                                          child: Text(
                                            name,
                                            style: TextStyle(
                                                color: TColor.gray,
                                                fontSize: 14),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedMealType = value.toString();
                                  });
                                },
                                icon: Icon(Icons.expand_more,
                                    color: TColor.primaryColor1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: TColor.primaryColor1,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: _showImageSourceDialog,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Meal Nutritions",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    // Calorie Card (Similar to BMI card in home_view.dart)
                    Container(
                      height: media.width * 0.35,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Daily Calories",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_fire_department,
                                        color: Colors.white.withOpacity(0.9),
                                        size: 18,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Total alloted calories: $totalCalories kCal",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.done_all,
                                        color: Colors.white.withOpacity(0.9),
                                        size: 18,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Consumed calories: $consumedCalories kCal",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.offline_bolt,
                                        color: Colors.white.withOpacity(0.9),
                                        size: 18,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "Calories left: ${totalCalories - consumedCalories} kCal",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(
                        color: TColor.primaryColor2.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Daily Meal Schedule",
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(
                            width: 85,
                            height: 30,
                            child: RoundButton(
                              title: "Check",
                              type: RoundButtonType.bgGradient,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MealScheduleView(),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today Meals",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: todayMealArr.length,
                        itemBuilder: (context, index) {
                          var mObj = todayMealArr[index] as Map? ?? {};
                          return _buildMealRow(mObj);
                        }),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
              //   child: Text(
              //     "Find Something to Eat",
              //     style: TextStyle(
              //         color: TColor.black,
              //         fontSize: 16,
              //         fontWeight: FontWeight.w700),
              //   ),
              // ),
              // SizedBox(
              //   height: media.width * 0.4,
              //   child: ListView.builder(
              //       padding: const EdgeInsets.symmetric(horizontal: 15.0),
              //       scrollDirection: Axis.horizontal,
              //       itemCount: findEatArr.length,
              //       itemBuilder: (context, index) {
              //         var fObj = findEatArr[index] as Map? ?? {};
              //         return InkWell(
              //           onTap: () {
              //             Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                     builder: (context) =>
              //                         MealFoodDetailsView(eObj: fObj)));
              //           },
              //           child: _buildSimplifiedFindEatCell(fObj, index, context),
              //         );
              //       }),
              // ),
              SizedBox(
                height: media.width * 0.05,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimplifiedFindEatCell(
      Map fObj, int index, BuildContext context) {
    var media = MediaQuery.of(context).size;
    bool isEvent = index % 2 == 0;
    return Container(
      margin: const EdgeInsets.all(8),
      width: media.width * 0.4,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isEvent
                ? [
                    TColor.primaryColor2.withOpacity(0.5),
                    TColor.primaryColor1.withOpacity(0.5)
                  ]
                : [
                    TColor.secondaryColor2.withOpacity(0.5),
                    TColor.secondaryColor1.withOpacity(0.5)
                  ],
          ),
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              fObj["name"],
              style: TextStyle(
                  color: TColor.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              fObj["number"],
              style: TextStyle(color: TColor.gray, fontSize: 12),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SizedBox(
              width: 90,
              height: 25,
              child: RoundButton(
                  fontSize: 12,
                  type: isEvent
                      ? RoundButtonType.bgGradient
                      : RoundButtonType.bgSGradient,
                  title: "Select",
                  onPressed: () {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealRow(Map mObj) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
        child: Row(
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
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  Text(
                    mObj["time"].toString(),
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.more_vert,
              color: TColor.gray,
              size: 20,
            )
          ],
        ));
  }

  // Add this method to your _MealPlannerViewState class
  int calculateDailyCalories() {
    if (widget.userData == null) {
      return 2500; // Default value if no user data
    }

    try {
      // Extract user data
      final gender = widget.userData!['gender'] ?? 'Male';
      final weight = double.tryParse(widget.userData!['weight'] ?? '0') ?? 0;
      final heightInCm =
          double.tryParse(widget.userData!['height'] ?? '0') ?? 0;
      final age = int.tryParse(widget.userData!['age'] ?? '30') ?? 30;
      final bmi =
          double.tryParse(widget.userData!['calculatedBMI'] ?? '0') ?? 0;

      // Calculate Basal Metabolic Rate (BMR) using Harris-Benedict Equation
      double bmr = 0;
      if (gender.toLowerCase() == 'male') {
        // Men: BMR = 88.362 + (13.397 × weight in kg) + (4.799 × height in cm) - (5.677 × age in years)
        bmr = 88.362 + (13.397 * weight) + (4.799 * heightInCm) - (5.677 * age);
      } else {
        // Women: BMR = 447.593 + (9.247 × weight in kg) + (3.098 × height in cm) - (4.330 × age in years)
        bmr = 447.593 + (9.247 * weight) + (3.098 * heightInCm) - (4.330 * age);
      }

      // Adjust calories based on BMI
      double activityFactor = 1.2; // Sedentary (little or no exercise)

      // Apply adjustments based on BMI
      if (bmi < 18.5) {
        // Underweight - need more calories
        activityFactor = 1.4; // Slightly higher to gain weight
      } else if (bmi >= 18.5 && bmi < 25) {
        // Normal weight - maintain
        activityFactor = 1.3; // Light activity
      } else if (bmi >= 25 && bmi < 30) {
        // Overweight - moderate deficit
        activityFactor = 1.2; // Slightly lower to lose weight gradually
      } else {
        // Obese - larger deficit
        activityFactor = 1.1; // Lower to create caloric deficit
      }

      // Calculate daily calories
      double dailyCalories = bmr * activityFactor;

      return dailyCalories.round();
    } catch (e) {
      print("Error calculating calories: $e");
      return 2500; // Default if calculation fails
    }
  }
}
