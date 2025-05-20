import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../common/henshin_theme.dart';

class SuspendedAccountsPage extends StatefulWidget {
  const SuspendedAccountsPage({Key? key}) : super(key: key);

  @override
  State<SuspendedAccountsPage> createState() => _SuspendedAccountsPageState();
}

class _SuspendedAccountsPageState extends State<SuspendedAccountsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akaun Digantung'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: HenshinTheme.primaryGradient.map((color) => color.withOpacity(0.5)).toList(),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari pengguna...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('isSuspended', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Ralat telah berlaku'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var users = snapshot.data!.docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    var name = data['name']?.toString().toLowerCase() ?? '';
                    return name.contains(_searchQuery.toLowerCase());
                  }).toList();

                  if (users.isEmpty) {
                    return const Center(child: Text('Tiada akaun digantung'));
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var userData = users[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: ListTile(
                          title: Text(userData['name'] ?? 'Nama tidak tersedia'),
                          subtitle: Text(userData['email'] ?? ''),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(users[index].id)
                                    .update({'isSuspended': false});
                                
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Akaun telah diaktifkan semula'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ralat telah berlaku'),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Aktifkan Semula'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 