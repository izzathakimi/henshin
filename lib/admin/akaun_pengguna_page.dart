import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../profile_screen/profile_screen.dart';
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
                    .where('isSuspended', isEqualTo: false)
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
                    return const Center(child: Text('Tiada pengguna dijumpai'));
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ProfileScreen(),
                                    ),
                                  );
                                },
                                tooltip: 'Lihat Profil',
                              ),
                              IconButton(
                                icon: const Icon(Icons.block),
                                onPressed: () async {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(users[index].id)
                                        .update({'isSuspended': true});
                                    
                                    if (mounted) {
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