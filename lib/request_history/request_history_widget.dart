import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../common/Henshin_theme.dart';
import '../request_summary/request_summary_widget.dart';

class RequestHistoryWidget extends StatelessWidget {
  const RequestHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: HenshinTheme.primaryGradient.map((color) => color.withOpacity(0.5)).toList(),          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('service_requests')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: HenshinTheme.bodyText1.copyWith(color: Colors.white),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'Tiada permintaan sebelumnya',
                  style: HenshinTheme.bodyText1.copyWith(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.9),
                        ],
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        data['description'] ?? 'No description',
                        style: HenshinTheme.subtitle1,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'RM ${(data['price'] ?? 0.0).toStringAsFixed(2)}',
                            style: HenshinTheme.bodyText1.copyWith(
                              color: HenshinTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (timestamp != null)
                            Text(
                              '${timestamp.day}/${timestamp.month}/${timestamp.year}',
                              style: HenshinTheme.bodyText2.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestSummaryWidget(
                              price: data['price'] ?? 0.0,
                              requirements: List<String>.from(data['requirements'] ?? []),
                              description: data['description'] ?? '',
                              imageUrl: data['imageUrl'] ?? '',
                              paymentRate: data['paymentRate'] ?? '',
                              dateTime: timestamp,
                              requestId: doc.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
