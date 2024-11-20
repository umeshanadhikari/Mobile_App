import 'dart:ui';
import 'package:flutter/material.dart';
import '../screens/sign_in_page.dart';
import '../screens/subordinate_page.dart';
import '../screens/apply_leave_page.dart';
import '../screens/order_page.dart';
import '../screens/settings_page.dart';
import '../screens/salary_page.dart';
import '../screens/status.dart';

class Employeehomepage extends StatefulWidget {
  const Employeehomepage({Key? key}) : super(key: key);

  @override
  _EmployeehomepageState createState() => _EmployeehomepageState();
}

class _EmployeehomepageState extends State<Employeehomepage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<bool> _isHovered = List.generate(5, (_) => false);
  bool _isSettingsHovered = false;
  bool _isLogoutHovered = false;

  // Updated color scheme
  static const Color primaryColor = Color(0xFF1E2B3C);
  static const Color backgroundColor = Color(0xFF2C3E50);
  static const Color accentColor = Color(0xFF3498DB);
  static const Color cardBorderColor = Color(0xFF3498DB);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        appBar: _buildAppBar(),
        body: SafeArea(
          child: _buildBody(MediaQuery.of(context).size),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'OUR SERVICES',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
      actions: [
        _buildIconButton(
          Icons.settings,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsPage(name: ''),
              ),
            );
          },
        ),
        _buildIconButton(
          Icons.logout,
          () => _showLogoutConfirmation(context),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 24),
          onPressed: onPressed,
          splashRadius: 24,
        ),
      ),
    );
  }

  Widget _buildBody(Size screenSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top Row
          _buildServiceRow([
            ServiceItem('Subordinate', Icons.group),
            ServiceItem('Order', Icons.shopping_cart),
          ]),

          const SizedBox(height: 24),

          // Middle Item
          Center(
            child: _buildServiceCard(
              ServiceItem('Salary', Icons.money),
              isCenter: true,
            ),
          ),

          const SizedBox(height: 24),

          // Bottom Row
          _buildServiceRow([
            ServiceItem('Leave', Icons.calendar_today),
            ServiceItem('Status', Icons.info),
          ]),
        ],
      ),
    );
  }

  Widget _buildServiceRow(List<ServiceItem> services) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: services.map((service) => _buildServiceCard(service)).toList(),
    );
  }

  Widget _buildServiceCard(ServiceItem service, {bool isCenter = false}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _handleNavigation(service.title, context),
          child: Container(
            width: isCenter ? 160 : 140,
            height: isCenter ? 160 : 140,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cardBorderColor.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    service.icon,
                    size: isCenter ? 45 : 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  service.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCenter ? 18 : 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Confirm Logout',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignInPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleNavigation(String title, BuildContext context) {
    final Map<String, Widget> routes = {
      'Subordinate': const SubordinateScreen(),
      'Order': const OrderStatusPage(),
      'Leave': const ApplyLeavePage(),
      'Status': const OrderPage(),
      'Salary': SalaryPage(),
    };

    final Widget? nextPage = routes[title];
    if (nextPage != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }
}

class ServiceItem {
  final String title;
  final IconData icon;

  ServiceItem(this.title, this.icon);
}
