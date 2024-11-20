import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApplyLeavePage extends StatefulWidget {
  const ApplyLeavePage({super.key});

  @override
  _ApplyLeavePageState createState() => _ApplyLeavePageState();
}

class _ApplyLeavePageState extends State<ApplyLeavePage>
    with SingleTickerProviderStateMixin {
  String? _selectedLeaveType;
  final TextEditingController _regNumberController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF2C3E50);
  static const Color backgroundColor = Color(0xFF34495E);
  static const Color cardColor = Color(0xFF2980B9);
  static const Color highlightColor = Color(0xFF1ABC9C);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _calculateDuration() {
    if (_fromDateController.text.isNotEmpty &&
        _toDateController.text.isNotEmpty) {
      try {
        final fromParts = _fromDateController.text.split('/');
        final toParts = _toDateController.text.split('/');

        final fromDate = DateTime(
          int.parse(fromParts[2]),
          int.parse(fromParts[1]),
          int.parse(fromParts[0]),
        );

        final toDate = DateTime(
          int.parse(toParts[2]),
          int.parse(toParts[1]),
          int.parse(toParts[0]),
        );

        final difference = toDate.difference(fromDate).inDays + 1;

        if (difference > 0) {
          setState(() {
            _durationController.text = difference.toString();
          });
        } else {
          setState(() {
            _durationController.text = '';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('End date must be after start date'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Error calculating duration: $e');
      }
    }
  }

  Future<void> _submitLeaveRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final String regNumber = _regNumberController.text;
        final String duration = _durationController.text;
        final String leaveType = _selectedLeaveType!;
        final List<String> fromParts = _fromDateController.text.split('/');
        final String fromDate =
            '${fromParts[2]}-${fromParts[1].padLeft(2, '0')}-${fromParts[0].padLeft(2, '0')}';
        final List<String> toParts = _toDateController.text.split('/');
        final String toDate =
            '${toParts[2]}-${toParts[1].padLeft(2, '0')}-${toParts[0].padLeft(2, '0')}';
        final String reason = _reasonController.text;

        final response = await ApiService.applyLeave(
          regNumber,
          duration,
          leaveType,
          fromDate,
          toDate,
          reason,
        );

        setState(() => _isLoading = false);

        if (response['success']) {
          _showSuccessDialog();
        } else {
          _showErrorDialog(response['message']);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorDialog('An error occurred. Please try again.');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: backgroundColor.withOpacity(0.9),
          title: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: highlightColor,
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                'Success!',
                style: TextStyle(color: highlightColor),
              ),
            ],
          ),
          content: const Text(
            'Your leave request has been submitted successfully.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: highlightColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: backgroundColor.withOpacity(0.9),
          title: const Column(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 50,
              ),
              SizedBox(height: 10),
              Text(
                'Error',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: highlightColor.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: highlightColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: highlightColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: cardColor.withOpacity(0.3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            backgroundColor,
            cardColor,
          ],
          stops: const [0.2, 0.6, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Apply Leave',
            style: TextStyle(
              fontFamily: 'Audiowide',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: cardColor.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _regNumberController,
                              decoration: _buildInputDecoration(
                                  'Register Number', Icons.person),
                              style: const TextStyle(color: Colors.white),
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _durationController,
                              decoration:
                                  _buildInputDecoration('Duration', Icons.work),
                              style: const TextStyle(color: Colors.white),
                              readOnly: true,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: _buildInputDecoration(
                                  'Leave Type', Icons.calendar_today),
                              dropdownColor: cardColor,
                              value: _selectedLeaveType,
                              items: ['Annual', 'Casual', 'Medical']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedLeaveType = newValue;
                                });
                              },
                              validator: (value) =>
                                  value == null ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: cardColor.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _fromDateController,
                                    decoration: _buildInputDecoration(
                                        'From', Icons.calendar_today),
                                    readOnly: true,
                                    style: const TextStyle(color: Colors.white),
                                    onTap: () async {
                                      final DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now()
                                            .add(const Duration(days: 365)),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.dark(
                                                primary: highlightColor,
                                                onPrimary: Colors.white,
                                                surface: cardColor,
                                                onSurface: Colors.white,
                                              ),
                                              dialogBackgroundColor:
                                                  backgroundColor,
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          _fromDateController.text =
                                              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                          _calculateDuration();
                                        });
                                      }
                                    },
                                    validator: (value) => value?.isEmpty ?? true
                                        ? 'Required'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _toDateController,
                                    decoration: _buildInputDecoration(
                                        'To', Icons.calendar_today),
                                    readOnly: true,
                                    style: const TextStyle(color: Colors.white),
                                    onTap: () async {
                                      final DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now()
                                            .add(const Duration(days: 365)),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.dark(
                                                primary: highlightColor,
                                                onPrimary: Colors.white,
                                                surface: cardColor,
                                                onSurface: Colors.white,
                                              ),
                                              dialogBackgroundColor:
                                                  backgroundColor,
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          _toDateController.text =
                                              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                          _calculateDuration();
                                        });
                                      }
                                    },
                                    validator: (value) => value?.isEmpty ?? true
                                        ? 'Required'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _reasonController,
                              decoration:
                                  _buildInputDecoration('Reason', Icons.notes),
                              style: const TextStyle(color: Colors.white),
                              maxLines: 3,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                highlightColor,
                                highlightColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: highlightColor.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitLeaveRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Submit Leave Request',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _regNumberController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    _reasonController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
