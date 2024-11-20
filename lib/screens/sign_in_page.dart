import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/employeehomepage.dart';
import '../screens/driverhomepage.dart';
import '../screens/forgot_password_screen.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isHoveredLogin = false;
  bool _isHoveredForgot = false;
  bool _rememberMe = false;

  late AnimationController _backgroundAnimationController;
  late Animation<Color?> _backgroundColorAnimation;

  final FocusNode _idFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  static const Color primaryColor = Color(0xFF2C3E50);
  static const Color accentColor = Color(0xFF3498DB);
  static const Color backgroundColor = Color(0xFF34495E);
  static const Color cardColor = Color(0xFF2980B9);
  static const Color highlightColor = Color(0xFF1ABC9C);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupFocusListeners();
  }

  // All existing setup methods remain the same
  void _setupAnimations() {
    // Existing animation setup code
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundColorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: primaryColor,
          end: backgroundColor,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: backgroundColor,
          end: cardColor,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: cardColor,
          end: primaryColor,
        ),
      ),
    ]).animate(_backgroundAnimationController);
  }

  void _setupFocusListeners() {
    _idFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _idFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // All existing login-related methods remain the same
  Future<void> _login() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(
        _idController.text,
        _passwordController.text,
      );

      if (result['success']) {
        _handleSuccessfulLogin(result['role']);
      } else {
        _showError(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateInputs() {
    if (_idController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return false;
    }
    return true;
  }

  void _handleSuccessfulLogin(String role) {
    Widget nextPage;
    if (role == 'employee') {
      nextPage = const Employeehomepage();
    } else if (role == 'driver') {
      nextPage = const DriverHomePage();
    } else {
      _showError('Invalid role');
      return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
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
        child: SafeArea(
          child: _buildResponsiveLayout(),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final contentWidth = isSmallScreen
            ? constraints.maxWidth
            : constraints.maxWidth > 1200
                ? 600.0
                : constraints.maxWidth * 0.5;

        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 24.0 : 40.0,
                vertical: 20.0,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: contentWidth,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildResponsiveLogo(isSmallScreen),
                    SizedBox(height: isSmallScreen ? 30 : 40),
                    _buildLoginForm(),
                    const SizedBox(height: 20),
                    _buildForgotPasswordButton(),
                    const SizedBox(height: 30),
                    _buildResponsiveLoginButton(isSmallScreen),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveLogo(bool isSmallScreen) {
    final logoSize = isSmallScreen ? 100.0 : 120.0;
    return Hero(
      tag: 'logo',
      child: TweenAnimationBuilder(
        duration: const Duration(seconds: 1),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo1.jpg',
                  height: logoSize,
                  width: logoSize,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginForm() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColor.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(
              controller: _idController,
              focusNode: _idFocusNode,
              label: 'ID',
              icon: Icons.person_outline,
              onSubmitted: (_) => _passwordFocusNode.requestFocus(),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 15),
            _buildRememberMeCheckbox(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    bool isPassword = false,
    Function(String)? onSubmitted,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: focusNode.hasFocus
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.1),
        border: Border.all(
          color: focusNode.hasFocus
              ? highlightColor
              : Colors.white.withOpacity(0.3),
          width: focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword && !_isPasswordVisible,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: focusNode.hasFocus
                ? highlightColor
                : Colors.white.withOpacity(0.7),
          ),
          prefixIcon: Icon(
            icon,
            color: focusNode.hasFocus
                ? highlightColor
                : Colors.white.withOpacity(0.7),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        Theme(
          data: ThemeData(
            unselectedWidgetColor: Colors.white.withOpacity(0.7),
          ),
          child: Checkbox(
            value: _rememberMe,
            onChanged: (value) => setState(() => _rememberMe = value ?? false),
            activeColor: highlightColor,
            checkColor: Colors.white,
          ),
        ),
        const Text(
          'Remember me',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHoveredForgot = true),
      onExit: (_) => setState(() => _isHoveredForgot = false),
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgotPasswordScreen(),
            ),
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: highlightColor,
        ),
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: _isHoveredForgot ? TextDecoration.underline : null,
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveLoginButton(bool isSmallScreen) {
    final buttonWidth = isSmallScreen
        ? MediaQuery.of(context).size.width * 0.7
        : MediaQuery.of(context).size.width * 0.3;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHoveredLogin = true),
      onExit: (_) => setState(() => _isHoveredLogin = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: buttonWidth,
        height: isSmallScreen ? 45 : 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [
              highlightColor,
              highlightColor.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: highlightColor.withOpacity(0.3),
              spreadRadius: _isHoveredLogin ? 2 : 0,
              blurRadius: _isHoveredLogin ? 15 : 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  height: isSmallScreen ? 20 : 24,
                  width: isSmallScreen ? 20 : 24,
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'LOGIN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
        ),
      ),
    );
  }
}