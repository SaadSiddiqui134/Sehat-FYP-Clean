
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('user/', include('userManagement.urls')),
    path('sleep/', include('sleep_tracker.urls')),
    path('disease/', include('mlmodels.urls')),
    path('detect/', include('mlmodels.urls')),
    path('meals/', include('nurition_tracker.urls')),
]
