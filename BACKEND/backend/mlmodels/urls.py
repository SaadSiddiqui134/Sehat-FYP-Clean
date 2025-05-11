from django.contrib import admin        
from django.urls import path, include
from . import views

urlpatterns = [
    path('predict/diabetes/', views.predict_diabetes, name='predict_diabetes'),
    path('predict/hypertension/', views.predict_hypertension, name='predict_hypertension'),
    path('food/', views.detect_food, name='detect_food'),
    path('dr/',views.predict_retinopathy_severity, name='dr_severity')
]
