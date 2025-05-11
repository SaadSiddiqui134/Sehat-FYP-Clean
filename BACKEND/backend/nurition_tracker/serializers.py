from rest_framework import serializers
from .models import FoodLog
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username']

class FoodLogSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = FoodLog
        fields = [
            'meal_id',
            'user',
            'name',
            'calories',
            'serving_size',
            'protein_g',
            'carbohydrates_total_g',
            'fat_saturated',
            'fat_total_g',
            'sugar_g',
            'fiber_g',
            'potassium_mg',
            'sodium_g',
            'cholesterol_mg',
            'meal_log_time'
        ]
        read_only_fields = ['meal_id', 'meal_log_time']

    def create(self, validated_data):
        # Get the user from the context
        user = self.context['request'].user
        validated_data['user'] = user
        return super().create(validated_data)

class FoodLogCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = FoodLog
        fields = [
            'name',
            'calories',
            'serving_size',
            'protein_g',
            'carbohydrates_total_g',
            'fat_saturated',
            'fat_total_g',
            'sugar_g',
            'fiber_g',
            'potassium_mg',
            'sodium_g',
            'cholesterol_mg',
        ]

class FoodLogSummarySerializer(serializers.ModelSerializer):
    class Meta:
        model = FoodLog
        fields = [
            'meal_id',
            'name',
            'calories',
            'meal_log_time'
        ]    