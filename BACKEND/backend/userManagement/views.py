from django.shortcuts import render, get_object_or_404
from django.http import JsonResponse 
from django.contrib.auth.hashers import make_password, check_password
from django.contrib.auth import  login
from django.views.decorators.csrf import csrf_exempt
from django.utils import timezone
from .models import User

# List all users
def list_users(request):
    users = User.objects.all()
    user_list = [
        {
            "UserID": u.UserID,
            "UserFirstName": u.UserFirstName,
            "UserLastName": u.UserLastName,
            "UserEmail": u.UserEmail,
        }
        for u in users
    ]
    return JsonResponse({"users": user_list})

# Get details of a specific user
def user_detail(request, user_id):
    user_obj = get_object_or_404(User, UserID=user_id)
    user_data = {
        "UserID": user_obj.UserID,
        "UserFirstName": user_obj.UserFirstName,
        "UserLastName": user_obj.UserLastName,
        "UserEmail": user_obj.UserEmail,
    }
    return JsonResponse(user_data)

# Create a new user with hashed password
@csrf_exempt
def create_user(request):
    if request.method == "POST":
        # Retrieve data from the POST request
        first_name = request.POST.get("UserFirstName")
        last_name = request.POST.get("UserLastName")
        email = request.POST.get("UserEmail")
        password = request.POST.get("UserPassword")
        gender = request.POST.get("UserGender", 'Male')  # Default value if not provided
        weight = request.POST.get("UserWeight")  # User's weight
        height = request.POST.get("UserHeight")  # User's height
        created_at = timezone.now()  # Automatically set to the current time

        print(f"Received parameters: firstName: {first_name}, lastName: {last_name}, email: {email}, password: {password}, gender: {gender}, weight: {weight}, height: {height}")

        # Hash the password before saving to the database
        hashed_password = make_password(password)
        print(f"Hashed password: {hashed_password}")

        # Save the new user to the database
        user_obj = User.objects.create(
            UserFirstName=first_name,
            UserLastName=last_name,
            UserEmail=email,
            UserPassword=hashed_password,
            UserGender=gender,  # Include the gender field
            UserWeight=weight,   # Include the weight field
            UserHeight=height,   # Include the height field
            created_at=created_at  # Save the created_at timestamp
        )

        return JsonResponse({"status": "success", "UserID": user_obj.UserID})

    return JsonResponse({"status": "error", "message": "Invalid request method"}, status=405)
# Update an existing user's details (excluding password updates here)
def update_user(request, user_id):
    user_obj = get_object_or_404(User, UserID=user_id)
    if request.method == "POST":
        user_obj.UserFirstName = request.POST.get("UserFirstName", user_obj.UserFirstName)
        user_obj.UserLastName = request.POST.get("UserLastName", user_obj.UserLastName)
        user_obj.UserEmail = request.POST.get("UserEmail", user_obj.UserEmail)
        user_obj.save()
        return JsonResponse({"status": "success", "message": "User updated successfully"})
    return JsonResponse({"status": "error", "message": "Invalid request method"}, status=405)

# Delete a user
def delete_user(request, user_id):  
    user_obj = get_object_or_404(User, UserID=user_id)
    user_obj.delete()
    return JsonResponse({"status": "success", "message": "User deleted successfully"})


@csrf_exempt
def login_user(request):
    if request.method == "POST":
        email = request.POST.get("UserEmail")
        password = request.POST.get("UserPassword")
        print(f"Received email: {email}, password: {password}")
        try:
            # Find the user by email
            user_obj = User.objects.get(UserEmail=email)
            
            # Check if the password is correct
            if check_password(password, user_obj.UserPassword):
                # User is authenticated, log them in
                login(request, user_obj)
                return JsonResponse({
                    "success": True,
                    "data": {
                        "UserID": user_obj.UserID,
                        "UserFirstName": user_obj.UserFirstName, 
                        "UserLastName": user_obj.UserLastName, 
                        "UserEmail": user_obj.UserEmail, 
                        "UserGender": user_obj.UserGender, 
                        "UserWeight": str(user_obj.UserWeight), 
                        "UserHeight": str(user_obj.UserHeight)
                    },
                    "code": 200,
                })
            else:
                return JsonResponse({
                    "success": False,
                    "error": "Invalid email or password"
                }, status=400)
        except User.DoesNotExist:
            return JsonResponse({
                "success": False,
                "error": "User does not exist"
            }, status=400)

    return JsonResponse({
        "success": False,
        "error": "Only POST requests are allowed"
    }, status=405)