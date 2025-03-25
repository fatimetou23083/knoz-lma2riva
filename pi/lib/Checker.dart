import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'constants.dart';

class ConnectionCheckerPage extends StatefulWidget {
  const ConnectionCheckerPage({super.key});

  @override
  _ConnectionCheckerPageState createState() => _ConnectionCheckerPageState();
}

class _ConnectionCheckerPageState extends State<ConnectionCheckerPage> {
  bool isChecking = false;
  bool? isConnected;
  String? errorMessage;
  Map<String, String> apiInfo = {};

  @override
  void initState() {
    super.initState();
    _populateApiInfo();
  }

  void _populateApiInfo() {
    apiInfo = {
      'Base URL': AppConstants.apiBaseUrl,
      'Status Endpoint': AppConstants.statusEndpoint,
      'Scholars Endpoint': AppConstants.scholarsEndpoint,
      'Favorites Endpoint': AppConstants.favoritesEndpoint,
      'Update Favorite Endpoint': AppConstants.updateFavoriteEndpoint,
    };
  }

  Future<void> checkConnection() async {
    setState(() {
      isChecking = true;
      isConnected = null;
      errorMessage = null;
    });

    try {
      final connected = await ApiService.testConnection();
      setState(() {
        isConnected = connected;
        isChecking = false;
      });
    } catch (e) {
      setState(() {
        isConnected = false;
        errorMessage = e.toString();
        isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فحص الاتصال بالخادم'),
        backgroundColor: Color(0xFF336B87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'معلومات الاتصال بالخادم',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...apiInfo.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.key}: ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontFamily: 'Cairo'),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isChecking ? null : checkConnection,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Color(0xFF336B87),
              ),
              child: Text(
                isChecking ? 'جاري الفحص...' : 'فحص الاتصال بالخادم',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isChecking)
              const Center(child: CircularProgressIndicator())
            else if (isConnected != null)
              Card(
                elevation: 3,
                color: isConnected! ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        isConnected! ? Icons.check_circle : Icons.error,
                        color: isConnected! ? Colors.green : Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isConnected! 
                            ? 'تم الاتصال بالخادم بنجاح'
                            : 'فشل الاتصال بالخادم',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isConnected! ? Colors.green.shade800 : Colors.red.shade800,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'الخطأ: $errorMessage',
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}