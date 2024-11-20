import 'package:flutter/material.dart';
import '../screens/landing_page.dart';
import '../screens/history_page.dart';
import '../screens/product_deliver.dart';
import '../screens/raw_material_page.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<bool> _isHovered = List.generate(3, (_) => false);

  // HomePage color scheme
  static const Color primaryColor = Color(0xFF2C3E50);
  static const Color accentColor = Color(0xFF3498DB);
  static const Color backgroundColor = Color(0xFF34495E);
  static const Color cardColor = Color(0xFF2980B9);
  static const Color highlightColor = Color(0xFF1ABC9C);

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

  Widget _buildInteractiveBox(
      String title, IconData icon, Function onTap, int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_controller.value * 0.05),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered[index] = true),
            onExit: (_) => setState(() => _isHovered[index] = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()
                ..scale(_isHovered[index] ? 1.05 : 1.0),
              child: GestureDetector(
                onTap: () => onTap(),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  margin:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cardColor,
                        cardColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: _isHovered[index]
                            ? highlightColor.withOpacity(0.3)
                            : Colors.black.withOpacity(0.2),
                        spreadRadius: _isHovered[index] ? 4 : 2,
                        blurRadius: _isHovered[index] ? 12 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: _isHovered[index]
                          ? highlightColor
                          : highlightColor.withOpacity(0.3),
                      width: _isHovered[index] ? 2.5 : 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: Colors.white,
                        size: _isHovered[index] ? 28 : 24,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _isHovered[index] ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor.withOpacity(0.9),
        title: Text(
          'Exit Services',
          style: TextStyle(color: highlightColor),
        ),
        content: const Text(
          'Do you want to return to the landing page?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No', style: TextStyle(color: highlightColor)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  highlightColor,
                  highlightColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LandingPage()),
                );
              },
              child: const Text('Yes'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  title: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.white, highlightColor],
                    ).createShader(bounds),
                    child: const Text(
                      'OUR SERVICES',
                      style: TextStyle(
                        fontFamily: 'Audiowide',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () async {
                        final shouldLogout = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: backgroundColor.withOpacity(0.9),
                            title: Text(
                              'Logout',
                              style: TextStyle(color: highlightColor),
                            ),
                            content: const Text(
                              'Are you sure you want to logout?',
                              style: TextStyle(color: Colors.white),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('No',
                                    style: TextStyle(color: highlightColor)),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      highlightColor,
                                      highlightColor.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LandingPage()),
                                    );
                                  },
                                  child: const Text('Yes'),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout == true) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LandingPage()),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInteractiveBox(
                            'Product Order Delivery',
                            Icons.local_shipping,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProductDeliveryPage(),
                                ),
                              );
                            },
                            0,
                          ),
                          _buildInteractiveBox(
                            'Raw Material Delivery',
                            Icons.inventory,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RawMaterialDeliveryPage(),
                                ),
                              );
                            },
                            1,
                          ),
                          _buildInteractiveBox(
                            'History',
                            Icons.history,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HistoryPage(),
                                ),
                              );
                            },
                            2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
