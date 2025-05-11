from django.contrib import admin
from .models import DiabetesPredictionLog, HypertensionPredictionLog

# Register your models here.
@admin.register(DiabetesPredictionLog)
class DiabetesPredictionLogAdmin(admin.ModelAdmin):
    list_display = ('user', 'prediction', 'gender', 'age', 'bmi', 'HbA1c_level', 'blood_glucose_level', 'timestamp')
    list_filter = ('prediction', 'gender', 'hypertension', 'heart_disease', 'smoking_history')
    search_fields = ('user__username', 'user__email')
    date_hierarchy = 'timestamp'
    readonly_fields = ('timestamp',)
    fieldsets = (
        ('User Information', {
            'fields': ('user', 'gender', 'age')
        }),
        ('Health Factors', {
            'fields': ('hypertension', 'heart_disease', 'smoking_history')
        }),
        ('Measurements', {
            'fields': ('bmi', 'HbA1c_level', 'blood_glucose_level')
        }),
        ('Results', {
            'fields': ('prediction', 'timestamp')
        }),
    )

@admin.register(HypertensionPredictionLog)
class HypertensionPredictionLogAdmin(admin.ModelAdmin):
    list_display = ('user', 'prediction', 'gender', 'age', 'heart_disease', 'diabetes', 'bmi', 'timestamp')
    list_filter = ('prediction', 'gender', 'heart_disease', 'diabetes', 'smoking_history')
    search_fields = ('user__username', 'user__email')
    date_hierarchy = 'timestamp'
    readonly_fields = ('timestamp',)
    fieldsets = (
        ('User Information', {
            'fields': ('user', 'gender', 'age')
        }),
        ('Health Factors', {
            'fields': ('heart_disease', 'diabetes', 'smoking_history')
        }),
        ('Measurements', {
            'fields': ('bmi', 'HbA1c_level', 'blood_glucose_level')
        }),
        ('Results', {
            'fields': ('prediction', 'timestamp')
        }),
    )
