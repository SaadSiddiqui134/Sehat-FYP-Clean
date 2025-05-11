from django.urls import path
from . import views

app_name = 'nutrition_tracker'

urlpatterns = [
    # Log meals endpoints
    path('log/', views.log_meal, name='log_meal'),
    
    # Get meal data endpoints
    path('getData/', views.get_meals, name='get_meals'),
    path('getData/date/', views.get_meals_by_date, name='get_meals_by_date'),
]
