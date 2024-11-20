import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../models/salary.dart';

class SalaryPage extends StatefulWidget {
  @override
  _SalaryPageState createState() => _SalaryPageState();
}

class _SalaryPageState extends State<SalaryPage> {
  // Color scheme from home page
  static const Color primaryColor = Color(0xFF1E2B3C);
  static const Color backgroundColor = Color(0xFF2C3E50);
  static const Color accentColor = Color(0xFF3498DB);
  static const Color cardBorderColor = Color(0xFF3498DB);

  final ApiService _apiService = ApiService();
  Map<int, List<Salary>> groupedSalaries = {};
  bool isLoading = true;
  String? error;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSalaries();
  }

  Future<void> fetchSalaries() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await _apiService.fetchSalaries();
      final salaries = (data['salaries'] as List)
          .map((salary) => Salary.fromJson(salary))
          .toList();

      final grouped = <int, List<Salary>>{};
      for (var salary in salaries) {
        final year = int.parse(salary.month.split('-')[0]);
        if (!grouped.containsKey(year)) {
          grouped[year] = [];
        }
        grouped[year]!.add(salary);
      }

      setState(() {
        groupedSalaries = Map.fromEntries(
            grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> downloadSalarySlip(Salary salary) async {
    try {
      final result = await showDialog<bool>(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) => AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Download Salary Slip',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your password to download the salary slip',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: cardBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: cardBorderColor.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.white70),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Download'),
            ),
          ],
        ),
      );

      if (result == true) {
        final pdfBytes = await _apiService.downloadSalarySlip(
          slipId: salary.slipId,
          regNumber: salary.regNumber,
          password: _passwordController.text,
        );

        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/salary_slip_${salary.month}.pdf');
        await file.writeAsBytes(pdfBytes);

        await OpenFile.open(file.path);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Salary slip downloaded successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download salary slip: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      _passwordController.clear();
    }
  }

  Widget _buildSalaryCard(Salary salary) {
    final monthYear =
        DateFormat('MMMM yyyy').format(DateTime.parse('${salary.month}-01'));

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardBorderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                monthYear,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                salary.name,
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              Text(
                salary.address,
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rs. ${salary.netSalary.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => downloadSalarySlip(salary),
                    icon: Icon(Icons.download, size: 20, color: Colors.white),
                    label: Text(
                      'Download Slip',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: accentColor.withOpacity(0.2),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearSection(int year, List<Salary> salaries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            year.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...salaries.map((salary) => _buildSalaryCard(salary)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor,
            backgroundColor,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new, // iOS-style back button
              color: Colors.white,
              size: 20,
            ),
            splashRadius: 24,
            padding: EdgeInsets.only(
                left: 16), // Adjust padding for better alignment
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Salary History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: accentColor,
                ),
              )
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          error!,
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: fetchSalaries,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchSalaries,
                    color: accentColor,
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      children: groupedSalaries.entries.map((entry) {
                        return _buildYearSection(entry.key, entry.value);
                      }).toList(),
                    ),
                  ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
