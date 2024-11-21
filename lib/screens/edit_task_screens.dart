import 'package:flutter/material.dart';
import 'package:todo_app/models/task_model.dart';
import 'package:todo_app/services/notification_service.dart';
import 'package:todo_app/services/task_service.dart'; // Import TaskService

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key, required this.task});
  final TaskModel? task;

  @override
  // ignore: library_private_types_in_public_api
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _dueDate;

  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _dueDate = widget.task!.dueDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        backgroundColor:
            Colors.blueAccent, // Đồng bộ màu sắc với các màn hình khác
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề công việc
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Mô tả công việc
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Chọn ngày và giờ
              GestureDetector(
                onTap: () async {
                  // Chọn ngày
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (selectedDate != null) {
                    // Chọn giờ và phút
                    TimeOfDay? selectedTime = await showTimePicker(
                      // ignore: use_build_context_synchronously
                      context: context,
                      initialTime:
                          TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
                    );

                    if (selectedTime != null) {
                      setState(() {
                        _dueDate = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.blueAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _dueDate == null
                              ? 'Select Due Date'
                              : 'Due Date: ${_dueDate!.toLocal()}',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Nút lưu hoặc cập nhật công việc
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: Text(widget.task == null ? 'Add Task' : 'Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTask() {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _dueDate == null) {
      // Kiểm tra nếu có trường thông tin nào bị bỏ trống
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final task = TaskModel(
      id: widget.task?.id ?? '', // Nếu là task mới thì không có id
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _dueDate!,
    );

    if (widget.task == null) {
      // Thêm mới công việc
      _taskService.addTask(task).then((_) {
        debugPrint("Task added with ID: ${task.dueDate}");
        // Gửi thông báo sau khi công việc được thêm vào Firestore
        NotificationService.scheduleNotification(
          task.dueDate, // Sử dụng thời gian đến hạn của công việc
          'Thực hiện công việc: ${task.title}', // Tiêu đề thông báo
          'Đến giờ thực hiện công việc: ${task.description}', // Nội dung thông báo
        );
        Navigator.pop(context); // Quay lại màn hình trước
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding task: $e')),
        );
      });
    } else {
      // Cập nhật công việc
      _taskService.updateTask(task).then((_) {
        debugPrint("Task updated with ID: ${task.dueDate}");
        // Gửi thông báo sau khi công việc được thêm vào Firestore
        NotificationService.scheduleNotification(
          task.dueDate, // Sử dụng thời gian đến hạn của công việc
          'Thực hiện công việc: ${task.title}', // Tiêu đề thông báo
          'Đến giờ thực hiện công việc: ${task.description}', // Nội dung thông báo
        );
        Navigator.pop(context); // Quay lại màn hình trước
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $e')),
        );
      });
    }
  }
}
