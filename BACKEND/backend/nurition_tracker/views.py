from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import FoodLog
from .serializers import FoodLogSerializer, FoodLogCreateSerializer, FoodLogSummarySerializer
from django.utils import timezone
from django.db.models import Sum
from django.contrib.auth.models import User

# Create your views here.

@api_view(['POST'])
def log_meal(request):
   
    data = request.data.copy()
    user_id = data.get('user_id')
    
    if not user_id:
        return Response(
            {'error': 'user_id is required'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        user = User.objects.get(id=user_id)
    except User.DoesNotExist:
        return Response(
            {'error': f'User with id {user_id} does not exist'}, 
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Validate required nutritional fields
    required_fields = [
        'name', 'calories', 'serving_size', 'protein_g', 
        'carbohydrates_total_g', 'fat_saturated', 'fat_total_g',
        'sugar_g', 'fiber_g', 'potassium_mg', 'sodium_g', 'cholesterol_mg'
    ]
    
    missing_fields = [field for field in required_fields if field not in data]
    if missing_fields:
        return Response(
            {'error': f'Missing required fields: {", ".join(missing_fields)}'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Ensure category is valid
    if 'category' in data and data['category'] not in ['Breakfast', 'Lunch', 'Dinner']:
        return Response(
            {'error': 'category must be one of: Breakfast, Lunch, Dinner'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Nutritional data validation - ensure all values are numeric
    numeric_fields = [
        'calories', 'serving_size', 'protein_g', 
        'carbohydrates_total_g', 'fat_saturated', 'fat_total_g',
        'sugar_g', 'fiber_g', 'potassium_mg', 'sodium_g', 'cholesterol_mg'
    ]
    
    for field in numeric_fields:
        try:
            data[field] = float(data[field])
        except (ValueError, TypeError):
            return Response(
                {'error': f'Field {field} must be a number'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
    
    serializer = FoodLogCreateSerializer(data=data)
    
    if serializer.is_valid():
        # Use the context to pass the user
        food_log = serializer.save(
            user=user,  # Pass user directly as argument to save()
            meal_log_time=timezone.now()  # Pass time directly as argument
        )
        
        response_serializer = FoodLogSerializer(food_log)
        return Response(response_serializer.data, status=status.HTTP_201_CREATED)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
def get_meals(request):
    """
    Get all meals for a specific user
    """
    user_id = request.query_params.get('user_id', None)
    
    if not user_id:
        return Response(
            {'error': 'user_id query parameter is required'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    
    meals = FoodLog.objects.filter(user_id=user_id)
    serializer = FoodLogSummarySerializer(meals, many=True)
    return Response(serializer.data)

@api_view(['GET'])
def get_meals_by_date(request):
    """
    Get meals filtered by date for a specific user
    """
    user_id = request.query_params.get('user_id', None)
    date_str = request.query_params.get('date', None)
    
    if not user_id:
        return Response(
            {'error': 'user_id query parameter is required'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        if date_str:
            # Parse the date from string
            date = timezone.datetime.strptime(date_str, '%Y-%m-%d').date()
        else:
            # Default to today
            date = timezone.now().date()
        
        # Filter meals by user and date
        meals = FoodLog.objects.filter(
            user_id=user_id,
            meal_log_time__date=date
        )
        
        # Group by meal category
        result = {
            'date': date.strftime('%Y-%m-%d'),
            'Breakfast': FoodLogSummarySerializer(
                meals.filter(category='Breakfast'), many=True
            ).data,
            'Lunch': FoodLogSummarySerializer(
                meals.filter(category='Lunch'), many=True
            ).data,
            'Dinner': FoodLogSummarySerializer(
                meals.filter(category='Dinner'), many=True
            ).data,
            'total_calories': meals.aggregate(total=Sum('calories'))['total'] or 0
        }
        
        # After checking if meals exist for the requested date, if none found:
        if not result['Breakfast'] and not result['Lunch'] and not result['Dinner']:
            # Find the most recent date with meals
            most_recent_meal = FoodLog.objects.filter(user_id=user_id).order_by('-meal_log_time__date').first()
            if most_recent_meal:
                # Use that date instead
                formatted_date = most_recent_meal.meal_log_time.date()
                # Re-query with this date
                result['Breakfast'] = FoodLogSummarySerializer(
                    FoodLog.objects.filter(user_id=user_id, meal_log_time__date=formatted_date, category='Breakfast'), many=True
                ).data
                result['Lunch'] = FoodLogSummarySerializer(
                    FoodLog.objects.filter(user_id=user_id, meal_log_time__date=formatted_date, category='Lunch'), many=True
                ).data
                result['Dinner'] = FoodLogSummarySerializer(
                    FoodLog.objects.filter(user_id=user_id, meal_log_time__date=formatted_date, category='Dinner'), many=True
                ).data
                result['total_calories'] = FoodLog.objects.filter(user_id=user_id, meal_log_time__date=formatted_date).aggregate(total=Sum('calories'))['total'] or 0
        
        return Response(result)
        
    except Exception as e:
        return Response(
            {'error': f'Error retrieving meals: {str(e)}'},
            status=status.HTTP_400_BAD_REQUEST
        )
