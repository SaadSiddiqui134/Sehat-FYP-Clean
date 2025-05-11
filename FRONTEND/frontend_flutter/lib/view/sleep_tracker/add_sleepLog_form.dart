import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/api_constants.dart';

class SleepAddAlarmView2 extends StatefulWidget {
  final DateTime date; // optional, in case you pass from calendar
  final Map<String, dynamic>? userData;
  final VoidCallback? onSleepLogAdded;

  const SleepAddAlarmView2({
    Key? key,
    required this.date,
    required this.userData,
    this.onSleepLogAdded,
  }) : super(key: key);

  @override
  State<SleepAddAlarmView2> createState() => _SleepAddAlarmViewState2();
}

class _SleepAddAlarmViewState2 extends State<SleepAddAlarmView2> {
  final _formKey = GlobalKey<FormState>();

  DateTime? sleepStart;
  DateTime? sleepEnd;

  bool isSubmitting = false;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.date; // or DateTime.now()
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _submitSleepLog() async {
    if (selectedDate == null || sleepStart == null || sleepEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select date, start and end times.')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.logSleep),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'UserID': widget.userData!['UserID'],
          'date': selectedDate!.toIso8601String().split("T")[0],
          'sleep_start': sleepStart!.toIso8601String(),
          'sleep_end': sleepEnd!.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        if (widget.onSleepLogAdded != null) {
          widget.onSleepLogAdded!();
        }
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add sleep log.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (pickedTime != null) {
      final selected = DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      setState(() {
        if (isStart) {
          sleepStart = selected;
        } else {
          sleepEnd = selected;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.lightGray,
      appBar: AppBar(
        title: Text("Add Sleep Log"),
        backgroundColor: TColor.lightGray,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ListTile(
                title: Text(sleepStart != null
                    ? "Sleep Start: ${sleepStart!.hour}:${sleepStart!.minute.toString().padLeft(2, '0')}"
                    : "Select Sleep Start Time"),
                trailing: Icon(Icons.access_time),
                onTap: () => _pickDateTime(isStart: true),
              ),
              ListTile(
                title: Text(sleepEnd != null
                    ? "Sleep End: ${sleepEnd!.hour}:${sleepEnd!.minute.toString().padLeft(2, '0')}"
                    : "Select Sleep End Time"),
                trailing: Icon(Icons.access_time),
                onTap: () => _pickDateTime(isStart: false),
              ),
              ListTile(
                title: Text(selectedDate != null
                    ? "Selected Date: ${selectedDate!.toLocal().toString().split(' ')[0]}"
                    : "Select Date"),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.backgroundColor2,
                    foregroundColor: TColor.white),
                onPressed: isSubmitting ? null : _submitSleepLog,
                child: isSubmitting
                    ? CircularProgressIndicator(color: TColor.white)
                    : Text("Submit Sleep Log"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
