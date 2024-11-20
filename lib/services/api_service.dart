import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Login functionality

  static Future<Map<String, dynamic>> login(
      String regNumber, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'regNumber': regNumber, 'password': password}),
    );
    return response.statusCode == 200
        ? jsonDecode(response.body)
        : {'success': false, 'message': 'Login failed'};
  }

  //  send otp functinality

  static Future<Map<String, dynamic>> sendOtp(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return response.statusCode == 200
        ? jsonDecode(response.body)
        : {'success': false, 'message': 'Failed to send OTP'};
  }

  // verify otp functionality

  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': response.body.isNotEmpty
              ? jsonDecode(response.body)['message']
              : 'Failed to verify OTP'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Password reset functionality

  static Future<Map<String, dynamic>> resetPassword(
      String email, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'newPassword': newPassword}),
    );
    return response.statusCode == 200
        ? jsonDecode(response.body)
        : {'success': false, 'message': 'Password reset failed'};
  }

  // Get subordinates functionality

  static Future<Map<String, dynamic>> getAll() async {
    try {
      print('Fetching subordinates...'); // Debug log
      final response = await http.get(
        Uri.parse('$baseUrl/get-subordinates'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        return {
          'success': true,
          'subordinates': decodedResponse['subordinates'] ?? []
        };
      } else {
        return {'success': false, 'message': 'Failed to fetch subordinates'};
      }
    } catch (e) {
      print('Error in getSubordinates: $e'); // Debug log
      return {'success': false, 'message': 'Error connecting to server'};
    }
  }

  // Add subordinate functionality

  static Future<Map<String, dynamic>> add(
    String name,
    String address,
    String contactNumber,
    String gender,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add-subordinate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'address': address,
          'contactNumber': contactNumber,
          'gender': gender,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': response.body.isNotEmpty
              ? jsonDecode(response.body)['message']
              : 'Failed to add subordinate'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Update subordinate functionality

  static Future<Map<String, dynamic>> update(
    String id,
    String name,
    String address,
    String contactNumber,
    String gender,
  ) async {
    try {
      print('Updating subordinate: $id'); // Debug log
      print('Data: $name, $address, $contactNumber, $gender'); // Debug log

      final response = await http.put(
        Uri.parse('$baseUrl/update-subordinate/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'address': address,
          'contactNumber': contactNumber,
          'gender': gender,
        }),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': response.body.isNotEmpty
              ? jsonDecode(response.body)['message']
              : 'Failed to update subordinate'
        };
      }
    } catch (e) {
      print('Error in update: $e'); // Debug log
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Delete subordinate functionality

  static Future<Map<String, dynamic>> delete(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete-subordinate/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': response.body.isNotEmpty
              ? jsonDecode(response.body)['message']
              : 'Failed to delete subordinate'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  //Change password functionality

  static Future<Map<String, dynamic>> changePassword({
    required String regNumber,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        // Changed to POST to match backend
        Uri.parse('$baseUrl/change-password'), // Updated endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'regNumber': regNumber,
          'oldPassword': currentPassword, // Changed to match backend
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to change password'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get orders functionality
  static Future<Map<String, dynamic>> getAllOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'orders': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch orders',
          'orders': [],
        };
      }
    } catch (e) {
      print('Error fetching orders: $e');
      return {
        'success': false,
        'message': 'Error connecting to server',
        'orders': [],
      };
    }
  }

  // Leave application functionality
  static Future<Map<String, dynamic>> applyLeave(
    String regNumber,
    String duration,
    String leaveType,
    String fromDate,
    String toDate,
    String reason,
  ) async {
    try {
      print('Submitting leave request with data:'); // Debug log
      print('regNumber: $regNumber');
      print('duration: $duration');
      print('leaveType: $leaveType');
      print('fromDate: $fromDate');
      print('toDate: $toDate');
      print('reason: $reason');

      final response = await http.post(
        Uri.parse('$baseUrl/apply-leave'), // Changed to match your server route
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'regNumber': regNumber,
          'duration': duration,
          'leaveType': leaveType,
          'from_date': fromDate,
          'to_date': toDate,
          'reason': reason,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        return {
          'success': true,
          'message': decodedResponse['message'] ?? 'Leave applied successfully'
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              errorData['message'] ?? 'Failed to submit leave application'
        };
      }
    } catch (e) {
      print('Error in applyLeave: $e');
      return {
        'success': false,
        'message': 'Failed to submit leave application'
      };
    }
  }

  // Status Update
  static Future<Map<String, dynamic>> submitOrderStatus({
    required String orderId,
    required String regNumber,
    required String status,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_id': orderId,
          'reg_number': regNumber,
          'current_status': status,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ??
              'Failed to update order status'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error connecting to server'};
    }
  }

  Future<Map<String, dynamic>> fetchSalaries() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/salary/salaries'), // Updated to match client request
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Fetching salaries from: ${baseUrl}/salary/salaries');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load salaries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchSalaries: $e');
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<List<int>> downloadSalarySlip({
    required int slipId,
    required String regNumber,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/salary/generate-slip'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'regNumber': regNumber,
          'password': password,
          'slipId': slipId,
        }),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid password');
      } else {
        throw Exception('Failed to download salary slip');
      }
    } catch (e) {
      throw Exception('Error downloading salary slip: $e');
    }
  }

  // Get employee details
  Future<Map<String, dynamic>> getEmployeeDetails(String regNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employee/$regNumber'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get employee details');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  // Update employee details
  Future<Map<String, dynamic>> updateEmployeeDetails({
    required String regNumber,
    required String name,
    required String email,
    String? contactNumber,
    String? address,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/employee/$regNumber'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'contact_number': contactNumber,
          'address': address,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to update employee details');
      }
    } catch (e) {
      throw Exception('Error updating employee details: $e');
    }
  }
}
