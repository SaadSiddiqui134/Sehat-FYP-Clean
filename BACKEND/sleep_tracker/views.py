from django.shortcuts import render,  get_object_or_404
from django.views.decorators.csrf import csrf_exempt
from django.utils import timezone
from .models import SleepLog
from django.http import JsonResponse
from .serializers import SleepLogSerializer
from rest_framework.views import APIView 
from datetime import datetime, timedelta
from django.db.models import Avg, Sum
from django.db.models.functions import TruncDate

# Create your views here.
class CreateSleepLogView(APIView):
    def post(self, request):
        serializer = SleepLogSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return JsonResponse({"success": True, "data": serializer.data}, status=201)
        return JsonResponse({"success": False, "errors": serializer.errors}, status=400)

class GetSleepLogsByUser(APIView):
    def get(self, request, user_id):
        if not user_id:
            return JsonResponse({"success": False, "error": "UserID required"}, status=400)
        
        sleep_logs = SleepLog.objects.filter(user__UserID=user_id).order_by('-date')
        serializer = SleepLogSerializer(sleep_logs, many=True)
        return JsonResponse({"success": True, "data": serializer.data}, status=200)

class GetSleepLineChartData(APIView):
    def get(self, request, user_id):
        if not user_id:
            return JsonResponse({"success": False, "error": "UserID required"}, status=400)
        
        # Get the last 7 days of sleep data
        end_date = timezone.now()
        start_date = end_date - timedelta(days=6)  # Changed to 6 to get exactly 7 days
        
        print(f"Fetching sleep data for UserID: {user_id}")
        print(f"Date range: {start_date.strftime('%Y-%m-%d')} to {end_date.strftime('%Y-%m-%d')}")
        
        # Get sleep logs for the last 7 days
        sleep_logs = SleepLog.objects.filter(
            user__UserID=user_id,
            date__range=[start_date, end_date]
        ).order_by('date')
        
        print(f"Found {sleep_logs.count()} sleep logs in the date range.")
        for log in sleep_logs:
            print(f"  Log Date: {log.date}, Duration: {log.duration}")
        
        # Initialize daily data with zeros for all 7 days
        daily_data = []
        total_sleep_time = 0
        total_days = 0
        
        # Create a dictionary of existing sleep logs by date
        sleep_by_date = {
            log.date.strftime('%Y-%m-%d'): log 
            for log in sleep_logs
        }
        
        # Generate data for all 7 days
        for i in range(7):
            current_date = start_date + timedelta(days=i)
            date_str = current_date.strftime('%Y-%m-%d')
            day_name = current_date.strftime('%A')
            
            if date_str in sleep_by_date:
                log = sleep_by_date[date_str]
                if log.duration:
                    hours = log.duration.total_seconds() / 3600
                    total_sleep_time += hours
                    total_days += 1
                    daily_data.append({
                        'day': day_name,
                        'date': date_str,
                        'hours': round(hours, 2)
                    })
                else:
                    daily_data.append({
                        'day': day_name,
                        'date': date_str,
                        'hours': 0.0
                    })
            else:
                daily_data.append({
                    'day': day_name,
                    'date': date_str,
                    'hours': 0.0
                })
        
        # Calculate average sleep time
        avg_sleep = round(total_sleep_time / total_days, 2) if total_days > 0 else 0
        
        response_data = {
            'daily_data': daily_data,
            'avg_sleep': avg_sleep,
            'total_sleep_time': round(total_sleep_time, 2)
        }
        
        return JsonResponse({"success": True, "data": response_data}, status=200)