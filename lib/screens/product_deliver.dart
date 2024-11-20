import 'package:flutter/material.dart';

class ProductDeliveryPage extends StatefulWidget {
  const ProductDeliveryPage({Key? key}) : super(key: key);

  @override
  _ProductDeliveryPageState createState() => _ProductDeliveryPageState();
}

class _ProductDeliveryPageState extends State<ProductDeliveryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<bool> _isHovered = List.generate(6, (_) => false);

  // HomePage color scheme
  static const Color primaryColor = Color(0xFF2C3E50);
  static const Color accentColor = Color(0xFF3498DB);
  static const Color backgroundColor = Color(0xFF34495E);
  static const Color cardColor = Color(0xFF2980B9);
  static const Color highlightColor = Color(0xFF1ABC9C);

  final List<Map<String, dynamic>> deliveryItems = List.generate(
    6,
    (index) => {
      'userId': 'E-001',
      'status': 'GO',
      'isSelected': false,
    },
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildListItem(int index) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered[index] = true),
      onExit: (_) => setState(() => _isHovered[index] = false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_controller.value * 0.02),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cardColor,
                      cardColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered[index]
                          ? highlightColor.withOpacity(0.3)
                          : Colors.black.withOpacity(0.2),
                      spreadRadius: _isHovered[index] ? 2 : 1,
                      blurRadius: _isHovered[index] ? 8 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: _isHovered[index]
                        ? highlightColor
                        : highlightColor.withOpacity(0.2),
                    width: _isHovered[index] ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  leading: Text(
                    deliveryItems[index]['userId'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _isHovered[index] ? 17 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  title: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            highlightColor,
                            highlightColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: highlightColor.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'GO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  trailing: SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: deliveryItems[index]['isSelected'],
                      onChanged: (bool? value) {
                        setState(() {
                          deliveryItems[index]['isSelected'] = value;
                        });
                      },
                      side: const BorderSide(color: Colors.white),
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(
                        (states) =>
                            states.contains(MaterialStateProperty.all(true))
                                ? highlightColor
                                : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                leading: IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.white, highlightColor],
                  ).createShader(bounds),
                  child: const Text(
                    'Product Delivery',
                    style: TextStyle(
                      fontFamily: 'Audiowide',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: highlightColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'User Id',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'Status',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(width: 24),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: deliveryItems.length,
                  itemBuilder: (context, index) => _buildListItem(index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
