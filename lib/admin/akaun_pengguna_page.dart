import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../profile_screen/profile.dart';
import '../common/henshin_theme.dart';

class AkaunPenggunaPage extends StatefulWidget {
  const AkaunPenggunaPage({Key? key}) : super(key: key);

  @override
  State<AkaunPenggunaPage> createState() => _AkaunPenggunaPageState();
}

class _AkaunPenggunaPageState extends State<AkaunPenggunaPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _searchQuery = '';

  Future<void> _showDeleteConfirmationDialog(String userId) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Padam Akaun'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sila masukkan kata laluan admin untuk mengesahkan:'),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Kata laluan admin',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Verify admin password here
              // For now, we'll just delete the account
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .delete();
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Akaun telah dipadam')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ralat telah berlaku')),
                  );
                }
              }
            },
            child: const Text('Padam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akaun Pengguna'),
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
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Ralat telah berlaku'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final query = _searchQuery.toLowerCase();

                  final users = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>?;

                    if (data == null) return false;
                    if (data['role'] != 'user') return false;
                    if (data['isSuspended'] == true) return false;

                    final name = data['name'];
                    if (name is! String) return false;

                    return name.toLowerCase().contains(query);
                  }).toList();




                  if (users.isEmpty) {
                    return const Center(child: Text('Tiada pengguna dijumpai'));
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                    print('DEBUG user data: ${users[index].data()}');

                    final raw = users[index].data();
                    if (raw == null || raw is! Map<String, dynamic>) {
                      return const SizedBox.shrink();
                    }
                    final userData = Map<String, dynamic>.from(raw);

                    // Defensive reading of potentially-null fields
                    final userName = userData['name']?.toString() ?? 'Nama tidak tersedia';
                    final userEmail = userData['email']?.toString() ?? '';
                    

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: ListTile(
                        title: Text(userName),
                        subtitle: Text(userEmail),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Profile(userId: users[index].id),
                                    ),
                                  );
                                },
                                tooltip: 'Lihat Profil',
                              ),
                              IconButton(
                                icon: const Icon(Icons.block),
                                onPressed: () async {
                                  final docRef = FirebaseFirestore.instance.collection('users').doc(users[index].id);
                                  final docSnap = await docRef.get();
                                  final data = docSnap.data();
                                  if (docSnap.exists && data != null && data['role'] == 'user' && data['name'] is String) {
                                    try {
                                      await docRef.update({'isSuspended': true});
                                      if (mounted) {
                                        setState(() {}); // Force rebuild
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Akaun telah digantung'),
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
                                  }
                                },
                                tooltip: 'Gantung',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _showDeleteConfirmationDialog(users[index].id),
                                tooltip: 'Padam',
                              ),
                            ],
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
    _passwordController.dispose();
    super.dispose();
  }
} 