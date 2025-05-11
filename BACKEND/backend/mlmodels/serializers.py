from rest_framework import serializers
from .models import DiabetesPredictionLog, HypertensionPredictionLog
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email']
        
class DiabetesPredictionLogSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = DiabetesPredictionLog
        fields = [
            'id',
            'user',
            'gender',
            'age',
            'hypertension',
            'heart_disease',
            'smoking_history',
            'bmi',
            'HbA1c_level',
            'blood_glucose_level',
            'prediction',
            'timestamp'
        ]
        read_only_fields = ['id', 'timestamp']
        
    def create(self, validated_data):
        # Get the user from the context if not provided
        user = self.context.get('user')
        if user:
            validated_data['user'] = user
        return DiabetesPredictionLog.objects.create(**validated_data)
        
class DiabetesPredictionInputSerializer(serializers.Serializer):
    user_id = serializers.IntegerField(required=False)
    gender = serializers.CharField(max_length=10)
    age = serializers.FloatField()
    hypertension = serializers.CharField(max_length=5)
    heart_disease = serializers.CharField(max_length=5)
    smoking_history = serializers.CharField(max_length=20)
    bmi = serializers.FloatField()
    HbA1c_level = serializers.FloatField()
    blood_glucose_level = serializers.FloatField()
    
    def validate_gender(self, value):
        valid_values = ['male', 'female']
        if value.lower() not in valid_values:
            raise serializers.ValidationError("Gender must be either 'male' or 'female'")
        return value.lower()
        
    def validate_hypertension(self, value):
        valid_values = ['yes', 'no', 'true', 'false']
        if value.lower() not in valid_values:
            raise serializers.ValidationError("Hypertension must be 'yes' or 'no'")
        return value.lower()
        
    def validate_heart_disease(self, value):
        valid_values = ['yes', 'no', 'true', 'false']
        if value.lower() not in valid_values:
            raise serializers.ValidationError("Heart disease must be 'yes' or 'no'")
        return value.lower()
        
    def validate_smoking_history(self, value):
        valid_values = ['no info', 'current', 'ever', 'former', 'never', 'not current']
        if value.lower() not in valid_values:
            raise serializers.ValidationError("Invalid smoking history value")
        return value.lower()

class HypertensionPredictionLogSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = HypertensionPredictionLog
        fields = [
            'id',
            'user',
            'gender',
            'age',
            'heart_disease',
            'smoking_history',
            'bmi',
            'HbA1c_level',
            'blood_glucose_level',
            'diabetes',
            'prediction',
            'timestamp'
        ]
        read_only_fields = ['id', 'timestamp']
        
    def create(self, validated_data):
        user = self.context.get('user')
        if user:
            validated_data['user'] = user
        return HypertensionPredictionLog.objects.create(**validated_data)
        
class HypertensionPredictionInputSerializer(serializers.Serializer):
    user_id = serializers.IntegerField(required=False)
    gender = serializers.CharField(max_length=10)
    age = serializers.FloatField()
    heart_disease = serializers.CharField(max_length=5)
    diabetes = serializers.CharField(max_length=5)
    smoking_history = serializers.CharField(max_length=20)
    bmi = serializers.FloatField()
    HbA1c_level = serializers.FloatField()
    blood_glucose_level = serializers.FloatField()
    
    def validate_gender(self, value):
        valid_values = ['male', 'female']
        if value.lower() not in valid_values:
            raise serializers.ValidationError("Gender must be either 'male' or 'female'")
        return value.lower()
    
    def validate_heart_disease(self, value):
        valid_values = ['yes', 'no', 'true', 'false']
        if value.lower() not in valid_values:
            raise serializers.ValidationError("Heart disease must be 'yes' or 'no'")
        return value.lower()
    
    def validate_diabetes(self, value):
        valid_values = ['yes', 'no', 'true', 'false']
        if value.lower() not in valid_values:
            raise serializers.ValidationError("Diabetes must be 'yes' or 'no'")
        return value.lower()
    
    def validate_smoking_history(self, value):
        valid_values = ['no info', 'current', 'ever', 'former', 'never', 'not current']
        if value.lower() not in valid_values:
            raise serializers.ValidationError("Invalid smoking history value")
        return value.lower()
