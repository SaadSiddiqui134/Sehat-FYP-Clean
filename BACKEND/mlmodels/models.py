from django.db import models
from django.contrib.auth.models import User

# Create your models here.
class DiabetesPredictionLog(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    gender = models.CharField(max_length=10)
    age = models.FloatField()
    hypertension = models.CharField(max_length=5)
    heart_disease = models.CharField(max_length=5)
    smoking_history = models.CharField(max_length=20)
    bmi = models.FloatField()
    HbA1c_level = models.FloatField()
    blood_glucose_level = models.FloatField()
    prediction = models.BooleanField()
    timestamp = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.user.username}'s diabetes prediction on {self.timestamp}"

class HypertensionPredictionLog(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    gender = models.CharField(max_length=10)
    age = models.FloatField()
    heart_disease = models.CharField(max_length=5)   
    smoking_history = models.CharField(max_length=20)
    bmi = models.FloatField()
    HbA1c_level = models.FloatField()
    blood_glucose_level = models.FloatField()
    diabetes = models.CharField(max_length=5)
    prediction = models.BooleanField()
    timestamp = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.user.username}'s hypertension prediction on {self.timestamp}"