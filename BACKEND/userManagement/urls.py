from django.urls import path
from . import views

urlpatterns = [
    path("users/", views.list_users, name="list_users"),
    path("details/<int:user_id>/", views.user_detail, name="user_detail"),
    path("create/", views.create_user, name="create_user"),
    path("<int:user_id>/update/", views.update_user, name="update_user"),
    path("<int:user_id>/delete/", views.delete_user, name="delete_user"),
    path('login/', views.login_user, name='login_user')
]
