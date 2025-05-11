import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static const String apiUrl =
      'https://api.calorieninjas.com/v1/nutrition?query='; // emulator
  // Change this one line to switch environments
  static const String baseUrl = 'http://10.0.2.2:8000'; // emulator
  static final String baseUrlDevice = dotenv.env['DEVICE_IP'] ??
      'http://10.0.2.2:8000/user/login/'; // real device

  // Add this line for the API key
  static final String apiKey = dotenv.env['API_KEY'] ?? '';

  // ---------------- USER MODULE ----------------
  static const String createUser = '$baseUrl/user/create/';
  static const String loginUser = '$baseUrl/user/login/';
  static const String updateUser = '$baseUrl/user/update/';
  static const String deleteUser = '$baseUrl/user/delete/';
  static const String getUserDetails = '$baseUrl/user/details/';

  static final String createUser2 = '$baseUrlDevice/user/create/';
  static final String loginUser2 = '$baseUrlDevice/user/login/';
  static final String updateUser2 = '$baseUrlDevice/user/update/';
  static final String deleteUser2 = '$baseUrlDevice/user/delete/';
  static final String getUserDetails2 = '$baseUrlDevice/user/details/';

  // ---------------- SLEEP TRACKER MODULE ----------------
  static const String logSleep = '$baseUrl/sleep/sleepadd/';
  // static const String getSleepLogs = '$baseUrl/sleep/sleepGetByUser/$id';
  static String getSleepLogsUserChart(int userIDForSleepChart) =>
      '$baseUrl/sleep/sleepLineChart/$userIDForSleepChart';
  static String getSleepLogsUser(int userIDForSleepLogs) =>
      '$baseUrl/sleep/sleepGetByUser/$userIDForSleepLogs';

  static final String logSleep2 = '$baseUrlDevice/sleep/log/';
  static final String getSleepLogs2 = '$baseUrlDevice/sleep/all/';
  static final String getSleepStats2 = '$baseUrlDevice/sleep/stats/';

  // ---------------- DISEASE MODULE ----------------
  static const String predictDiseaseDiabetes =
      '$baseUrl/disease/predict/diabetes/';
  static const String predictDiseaseHypertension =
      '$baseUrl/disease/predict/hypertension/';
  static const String diseaseHistory = '$baseUrl/disease/history/';

  static final String predictDisease2 = '$baseUrlDevice/disease/predict/';
  static final String diseaseHistory2 = '$baseUrlDevice/disease/history/';

  // ---------------- NUTRITION TRACKER MODULE ----------------
  static final String logMealsCalories = '$baseUrl/meals/logCalories/';
  static final String logMeals = '$baseUrl/meals/log/';
  static final String mealsData = '$baseUrl/meals/getData/';

  // Updated to accept parameters
  static String mealsDataByDate(int userId, String formattedDate) =>
      '$baseUrl/meals/getData/date/?date=$formattedDate&user_id=$userId';

  static final String logMeals2 = '$baseUrlDevice/meals/log/';
  static final String mealsData2 = '$baseUrlDevice/meals/getData/';
  static String mealsDataByDate2(int userId, String formattedDate) =>
      '$baseUrlDevice/meals/getData/date/?date=$formattedDate&user_id=$userId';
  static final String detectFood = '$baseUrl/detect/food/';
}
