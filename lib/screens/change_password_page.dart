import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChangePasswordPage extends StatefulWidget {
  final String regNumber;
  const ChangePasswordPage({
    super.key,
    required this.regNumber,
  });

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _regNumberController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  double _passwordStrength = 0;
  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  static const Color primaryColor = Color(0xFF2C3E50);
  static const Color accentColor = Color(0xFF3498DB);
  static const Color backgroundColor = Color(0xFF34495E);
  static const Color cardColor = Color(0xFF2980B9);
  static const Color highlightColor = Color(0xFF1ABC9C);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _regNumberController.text = widget.regNumber;
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordStrength < 1.0) {
      _showErrorDialog(
          'Please ensure your new password meets all requirements');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorDialog('New passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.changePassword(
        regNumber: _regNumberController.text.trim(),
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (response['success']) {
        await _showSuccessDialog();
      } else {
        _showErrorDialog(response['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('An error occurred. Please try again later.');
    }
  }

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength += 0.25;
    setState(() => _passwordStrength = strength);
  }

  Color _getStrengthColor(double strength) {
    if (strength == 0) return highlightColor.withOpacity(0.5);
    if (strength <= 0.25) return Colors.red;
    if (strength <= 0.50) return Colors.orange;
    if (strength <= 0.75) return Colors.yellow;
    return highlightColor;
  }

  String _getStrengthText() {
    if (_passwordStrength == 0) return 'Enter Password';
    if (_passwordStrength <= 0.25) return 'Weak';
    if (_passwordStrength <= 0.5) return 'Medium';
    if (_passwordStrength <= 0.75) return 'Strong';
    return 'Very Strong';
  }

  Future<void> _showSuccessDialog() async {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
        ),
        elevation: 8,
        backgroundColor: backgroundColor,
        child: Container(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, backgroundColor, cardColor],
              stops: const [0.2, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: highlightColor,
                size: isTablet ? 80 : 64,
              ),
              SizedBox(height: isTablet ? 24 : 16),
              Text(
                'Success',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 28 : 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: isTablet ? 16 : 8),
              Text(
                'Password changed successfully',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isTablet ? 18 : 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 32 : 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: highlightColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 40 : 32,
                    vertical: isTablet ? 20 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
        ),
        title: Text(
          'Error',
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isTablet ? 18 : 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: highlightColor,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
          ),
        ],
      ),
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
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: isTablet ? 28 : 24,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Change Password',
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 28 : 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          fontFamily: 'Poppins',
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final maxWidth = isTablet ? 600.0 : size.width;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRequirementsCard(isTablet),
                SizedBox(height: isTablet ? 30 : 20),
                _buildRegNumberCard(isTablet),
                SizedBox(height: isTablet ? 30 : 20),
                _buildPasswordCard(isTablet),
                SizedBox(height: isTablet ? 36 : 24),
                _buildButtons(isTablet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementsCard(bool isTablet) {
    return Card(
      elevation: 8,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white.withOpacity(0.7),
                  size: isTablet ? 28 : 24,
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Text(
                  'Password Requirements',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 24 : 16),
            _buildRequirement('At least 8 characters', isTablet),
            _buildRequirement('One uppercase letter', isTablet),
            _buildRequirement('One number', isTablet),
            _buildRequirement('One special character (!@#\$&*~)', isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildRegNumberCard(bool isTablet) {
    return Card(
      elevation: 8,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          children: [
            TextFormField(
              controller: _regNumberController,
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 18 : 16,
              ),
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Registration Number',
                labelStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isTablet ? 18 : 16,
                ),
                hintText: 'Enter Registration Number',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: isTablet ? 18 : 16,
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: Colors.white.withOpacity(0.7),
                  size: isTablet ? 28 : 24,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
                  borderSide: BorderSide(
                      color: highlightColor, width: isTablet ? 2.5 : 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20,
                  vertical: isTablet ? 20 : 16,
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Registration Number is required';
                }
                if (value!.length < 3) {
                  return 'Please enter a valid registration number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordCard(bool isTablet) {
    return Card(
      elevation: 8,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          children: [
            _buildPasswordField(
              controller: _currentPasswordController,
              label: 'Current Password',
              showPassword: _showCurrentPassword,
              onToggle: () =>
                  setState(() => _showCurrentPassword = !_showCurrentPassword),
              isTablet: isTablet,
            ),
            SizedBox(height: isTablet ? 24 : 16),
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'New Password',
              showPassword: _showNewPassword,
              onToggle: () =>
                  setState(() => _showNewPassword = !_showNewPassword),
              onChanged: _checkPasswordStrength,
              isTablet: isTablet,
            ),
            const SizedBox(height: 8),
            _buildStrengthIndicator(isTablet),
            SizedBox(height: isTablet ? 24 : 16),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              showPassword: _showConfirmPassword,
              onToggle: () =>
                  setState(() => _showConfirmPassword = !_showConfirmPassword),
              isTablet: isTablet,
              validator: (value) {
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool showPassword,
    required VoidCallback onToggle,
    required bool isTablet,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !showPassword,
      onChanged: onChanged,
      style: TextStyle(
        color: Colors.white,
        fontSize: isTablet ? 18 : 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: isTablet ? 18 : 16,
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Colors.white.withOpacity(0.7),
          size: isTablet ? 28 : 24,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white.withOpacity(0.7),
            size: isTablet ? 28 : 24,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
          borderSide:
              BorderSide(color: highlightColor, width: isTablet ? 2.5 : 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 20,
          vertical: isTablet ? 20 : 16,
        ),
      ),
      validator:
          validator ?? (value) => value?.isEmpty ?? true ? 'Required' : null,
    );
  }

  Widget _buildStrengthIndicator(bool isTablet) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
          child: LinearProgressIndicator(
            value: _passwordStrength,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
                _getStrengthColor(_passwordStrength)),
            minHeight: isTablet ? 10 : 8,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Text(
          _getStrengthText(),
          style: TextStyle(
            color: _getStrengthColor(_passwordStrength),
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(bool isTablet) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 20 : 16,
              ),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
              ),
            ),
          ),
        ),
        SizedBox(width: isTablet ? 24 : 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: highlightColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 20 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
              ),
              elevation: 5,
            ),
            child: _isLoading
                ? SizedBox(
                    height: isTablet ? 28 : 24,
                    width: isTablet ? 28 : 24,
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirement(String text, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 6 : 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: highlightColor,
            size: isTablet ? 20 : 16,
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: isTablet ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _regNumberController.dispose();
    _animationController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
