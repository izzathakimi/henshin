import 'package:flutter/material.dart';
import '../common/Henshin_theme.dart';
// import '../common/Henshin_widgets.dart';
import '../home_page.dart'; // Import homepage widget

class RequestSummaryWidget extends StatelessWidget {
  final double price;
  final List<String> requirements;
  final String description; 
  final String imageUrl;
  final DateTime? dateTime;  // Make it nullable and optional
  final String requestId;
  const RequestSummaryWidget({
    super.key,  // Changed from Key? key to super.key
    required this.price,
    required this.requirements,
    required this.description,
    required this.imageUrl,
    this.dateTime,  // Made optional
    this.requestId = '#REQ123456',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // title: const Text('Request Summary'),
        backgroundColor: HenshinTheme.primaryColor,
      ),
      // Add gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: HenshinTheme.primaryGradient,
            stops: [0.0, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              color: HenshinTheme.tertiaryColor, // White card background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Ringkasan Permintaan', style: HenshinTheme.title3),
                    const SizedBox(height: 20),
                    _buildInfoRow('ID Permintaan:', requestId),
                    _buildInfoRow('Jumlah:', 'RM ${price.toStringAsFixed(2)}'),
                    _buildInfoRow('Status Permintaan:', 'Selesai'),
                    const SizedBox(height: 16),
                    Text('Penerangan:', style: HenshinTheme.bodyText1.copyWith(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(description, style: HenshinTheme.bodyText1),
                    const SizedBox(height: 16),
                    Text('Keperluan:', style: HenshinTheme.bodyText1.copyWith(color: Colors.grey)),
                    const SizedBox(height: 8),
                    ...requirements.map((req) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(req, style: HenshinTheme.bodyText1),
                          ),
                        ],
                      ),
                    )).toList(),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {/* Handle download */},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Muat Turun Ringkasan', style: HenshinTheme.subtitle2),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const HomePage()),
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Color(0xFF4A90E2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Kembali ke Skrin Utama',
                        style: HenshinTheme.subtitle2.copyWith(
                          color: const Color(0xFF4A90E2),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: HenshinTheme.bodyText1.copyWith(color: Colors.grey)),
          Text(value, style: HenshinTheme.bodyText1),
        ],
      ),
    );
  }
}
