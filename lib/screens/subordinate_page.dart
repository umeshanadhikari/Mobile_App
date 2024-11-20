import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_subordinate_page.dart';

class SubordinateScreen extends StatefulWidget {
  const SubordinateScreen({Key? key}) : super(key: key);

  @override
  _SubordinateScreenState createState() => _SubordinateScreenState();
}

class _SubordinateScreenState extends State<SubordinateScreen> {
  // Theme Colors
  static const Color primaryColor = Color(0xFF2C3E50);
  static const Color accentColor = Color(0xFF3498DB);
  static const Color backgroundColor = Color(0xFF34495E);
  static const Color cardColor = Color(0xFF2980B9);
  static const Color highlightColor = Color(0xFF1ABC9C);

  List<dynamic> subordinates = [];
  List<dynamic> filteredSubordinates = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSubordinates();
  }

  Future<void> _fetchSubordinates() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.getAll();
      if (response['success'] == true && response['subordinates'] != null) {
        setState(() {
          subordinates = List.from(response['subordinates']);
          filteredSubordinates = List.from(subordinates);
          isLoading = false;
        });
      } else {
        setState(() {
          subordinates = [];
          filteredSubordinates = [];
          isLoading = false;
        });
        _showErrorDialog(response['message'] ?? 'Failed to load subordinates');
      }
    } catch (error) {
      setState(() {
        subordinates = [];
        filteredSubordinates = [];
        isLoading = false;
      });
      _showErrorDialog('Error loading subordinates: $error');
    }
  }

  void _filterSubordinates(String query) {
    setState(() {
      filteredSubordinates = subordinates.where((subordinate) {
        final name = subordinate['name']?.toString().toLowerCase() ?? '';
        final contact =
            subordinate['contactNumber']?.toString().toLowerCase() ?? '';
        final address = subordinate['address']?.toString().toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) ||
            contact.contains(searchLower) ||
            address.contains(searchLower);
      }).toList();
    });
  }

  Future<void> _deleteSubordinate(String id) async {
    try {
      final response = await ApiService.delete(id);
      if (response['success']) {
        _showSuccessMessage('Subordinate deleted successfully');
        _fetchSubordinates();
      } else {
        _showErrorDialog(response['message'] ?? 'Failed to delete subordinate');
      }
    } catch (error) {
      _showErrorDialog('Error deleting subordinate: $error');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: highlightColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: const Text(
            'Error',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: highlightColor)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(String id) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: const Text('Confirm Delete',
              style: TextStyle(color: Colors.white)),
          content: const Text(
              'Are you sure you want to delete this subordinate?',
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: highlightColor)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteSubordinate(id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, backgroundColor, cardColor],
          stops: const [0.2, 0.6, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Subordinates',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _fetchSubordinates,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddSubordinateForm(),
              ),
            );
            if (result == true) {
              _fetchSubordinates();
            }
          },
          backgroundColor: highlightColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(highlightColor),
                      ),
                    )
                  : _buildSubordinatesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.3), // Changed background color
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: highlightColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            // Explicitly set text style
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          onChanged: (value) {
            print('Search query: $value'); // Debug print
            setState(() {
              // Added setState to trigger rebuild
              _filterSubordinates(value);
            });
          },
          decoration: InputDecoration(
            hintText: 'Search subordinates...',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.search,
                    color: highlightColor.withOpacity(0.9),
                    size: 26,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: highlightColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                        _filterSubordinates('');
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              // Added enabledBorder
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: highlightColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: highlightColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            fillColor: cardColor.withOpacity(0.3), // Added fillColor
            filled: true, // Enable filling
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          cursorColor: highlightColor,
          cursorWidth: 2,
          cursorRadius: const Radius.circular(1),
        ),
      ),
    );
  }

  Widget _buildSubordinatesList() {
    if (filteredSubordinates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No subordinates found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredSubordinates.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final subordinate = filteredSubordinates[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor.withOpacity(0.95),
                highlightColor.withOpacity(0.95),
              ],
              stops: const [0.3, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(
                subordinate['gender']?.toString().toLowerCase() == 'male'
                    ? Icons.male
                    : Icons.female,
                color: Colors.white,
              ),
            ),
            title: Text(
              subordinate['name'] ?? 'N/A',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone,
                        size: 16, color: Colors.white.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(
                      subordinate['contactNumber'] ?? 'N/A',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: Colors.white.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        subordinate['address'] ?? 'N/A',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddSubordinateForm(
                          existingSubordinate: subordinate,
                        ),
                      ),
                    );
                    if (result == true) {
                      _fetchSubordinates();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () => _confirmDelete(subordinate['id'].toString()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
