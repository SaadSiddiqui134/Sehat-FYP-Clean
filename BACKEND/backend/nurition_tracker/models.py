from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone

# Create your models here.

class FoodLog(models.Model):
    MEAL_CATEGORIES = [
        ('Breakfast', 'Breakfast'),
        ('Lunch', 'Lunch'),
        ('Dinner', 'Dinner'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='food_logs')
    meal_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=255)
    category = models.CharField(max_length=10, choices=MEAL_CATEGORIES, default='Breakfast')
    calories = models.FloatField()
    serving_size = models.FloatField()
    protein_g = models.FloatField()
    carbohydrates_total_g = models.FloatField()
    fat_saturated = models.FloatField()
    fat_total_g = models.FloatField()
    sugar_g = models.FloatField()
    fiber_g = models.FloatField()
    potassium_mg = models.FloatField()
    sodium_g = models.FloatField()
    cholesterol_mg = models.FloatField()
    meal_log_time = models.DateTimeField(default=timezone.now)
    

    class Meta:
        db_table = 'food_log'
        ordering = ['-meal_log_time']

    def __str__(self):
        return f"{self.name} - {self.user.username} - {self.meal_log_time.strftime('%Y-%m-%d %H:%M')}"
