from django.contrib import admin        
from django.urls import path, include
from . import views

urlpatterns = [
    path('predict/diabetes/', views.predict_diabetes, name='predict_diabetes'),
    path('predict/hypertension/', views.predict_hypertension, name='predict_hypertension'),
]
