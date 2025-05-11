from django.db import models
from django.utils import timezone

class User(models.Model):
    UserID = models.AutoField(primary_key=True, unique=True)
    UserFirstName = models.CharField(max_length=200)
    UserLastName = models.CharField(max_length=200)
    UserEmail = models.EmailField(max_length=200, unique=True)
    UserPassword = models.CharField(max_length=255)
    UserGender = models.CharField(max_length=10, default='Male')  # Gender Field
    UserWeight = models.FloatField(null=True, blank=True)  # Weight Field
    UserHeight = models.FloatField(null=True, blank=True)  # Height Field
    last_login = models.DateTimeField(default=timezone.now)
    created_at = models.DateTimeField(auto_now_add=True)  # Timestamp when user is created

    def __str__(self):
        return f"{self.UserFirstName} {self.UserLastName}"
