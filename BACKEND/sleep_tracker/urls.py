# urls.py

from django.urls import path
from .views import CreateSleepLogView, GetSleepLogsByUser, GetSleepLineChartData

urlpatterns = [
    path('sleepadd/', CreateSleepLogView.as_view(), name='add-sleep-log'),
    path('sleepGetByUser/<int:user_id>/', GetSleepLogsByUser.as_view(), name='get-sleep-logs'),
    path('sleepLineChart/<int:user_id>/', GetSleepLineChartData.as_view(), name='get-sleep-line-chart'),
]
