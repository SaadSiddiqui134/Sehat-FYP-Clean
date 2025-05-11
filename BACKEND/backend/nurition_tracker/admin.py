from django.contrib import admin
from .models import FoodLog

@admin.register(FoodLog)
class FoodLogAdmin(admin.ModelAdmin):
    list_display = ('meal_id', 'user', 'name', 'calories', 'meal_log_time')
    list_filter = ('user', 'meal_log_time')
    search_fields = ('name', 'user__username')
    ordering = ('-meal_log_time',)
    readonly_fields = ('meal_log_time',)
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('user', 'name', 'serving_size', 'calories')
        }),
        ('Macronutrients', {
            'fields': ('protein_g', 'carbohydrates_total_g', 'fat_total_g', 'fat_saturated')
        }),
        ('Additional Nutrients', {
            'fields': ('sugar_g', 'fiber_g', 'potassium_mg', 'sodium_g', 'cholesterol_mg')
        }),
        ('Timestamp', {
            'fields': ('meal_log_time',)
        }),
    )
