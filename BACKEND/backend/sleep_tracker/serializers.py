from rest_framework import serializers
from userManagement.models import User
from .models import SleepLog   



class SleepLogSerializer(serializers.ModelSerializer):
    UserID = serializers.IntegerField(write_only=True)
    duration_hours = serializers.SerializerMethodField()
    duration_minutes = serializers.SerializerMethodField()

    class Meta:
        model = SleepLog
        fields = [
            'id',
            'UserID',
            'date',
            'sleep_start',
            'sleep_end',
            'duration',
            'duration_hours',
            'duration_minutes',
        ]
        read_only_fields = ['duration', 'duration_hours','duration_minutes']

    def get_duration_hours(self, obj):
        if obj.duration:
            total_seconds = int(obj.duration.total_seconds())
            hours = total_seconds // 3600
            return hours
        return 0

    def get_duration_minutes(self, obj):
        if obj.duration:
            total_seconds = int(obj.duration.total_seconds())
            minutes = (total_seconds % 3600) // 60
            return minutes
        return 0
    
    def get_duration_formatted(self, obj):
        if obj.duration:
            total_seconds = int(obj.duration.total_seconds())
            hours, remainder = divmod(total_seconds, 3600)
            minutes, _ = divmod(remainder, 60)
            return f"{hours}h {minutes}m"
        return None


      
    def create(self, validated_data):
        from sleep_tracker.models import User
        user_id = validated_data.pop('UserID')
        user = User.objects.get(UserID=user_id)
        return SleepLog.objects.create(user=user, **validated_data)