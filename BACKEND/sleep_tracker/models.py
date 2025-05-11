
from django.db import models
from django.utils import timezone
from userManagement.models import User  # import your custom User model

class SleepLog(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="sleep_logs")
    date = models.DateField()
    sleep_start = models.DateTimeField()
    sleep_end = models.DateTimeField()
    duration = models.DurationField(blank=True, null=True)

    def save(self, *args, **kwargs):
        if self.sleep_start and self.sleep_end:
            self.duration = self.sleep_end - self.sleep_start
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.user.UserFirstName} - {self.date}"
