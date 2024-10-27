import 'package:flutter/material.dart';

class CommunityForum extends StatelessWidget {
  const CommunityForum({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Color(0xFF50E3C2)),
                      hintText: 'Search',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Color(0xFF4A90E2).withOpacity(0.1),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.filter_list, color: Color(0xFF50E3C2)),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Popular',
                      child: Text('Popular'),
                    ),
                    const PopupMenuItem(
                      value: 'By upvotes',
                      child: Text('By upvotes'),
                    ),
                    const PopupMenuItem(
                      value: 'By comments',
                      child: Text('By comments'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Divider(color: Colors.grey),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // Array of region names
              final regions = [
                'Selangor',
                'Johor',
                'Kelantan',
                'Pahang',
                'Terengganu'
              ];
              return Card(
                color: Color(
                  0xFF4A90E2, // Change card background color to 0xFF4A90E2
                ),
                margin: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 8,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white, // Logo background color to white
                            child: const Icon(Icons.work, color: Colors.black), // Change icon color to black for visibility
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              regions[index], // Display region name
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            'Sep 23',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Forum Image
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFF50E3C2).withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.business_center,
                          size: 50,
                          color: Colors.white, // Change icon color to white
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'A dedicated space for job seekers to connect, share opportunities, exchange career advice, and support each other in their professional journeys. Join our community to access job listings, resume tips, interview strategies, and networking opportunities.',
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.thumb_up, color: Colors.white), // Change to white
                            onPressed: () {},
                          ),
                          const Text('551',
                              style: TextStyle(color: Colors.black)),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: Icon(Icons.comment, color: Colors.white), // Change to white
                            onPressed: () {},
                          ),
                          const Text('46',
                              style: TextStyle(color: Colors.black)),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: Icon(Icons.bookmark_border, color: Colors.white), // Change to white
                            onPressed: () {},
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: Icon(Icons.location_on, color: Colors.white), // Location symbol in white
                            onPressed: () {},
                          ),
                          const SizedBox(
                            width: 10, // Spacing for location icon
                          ),
                          IconButton(
                            icon: Icon(Icons.link, color: Colors.white), // Change to white
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.share, color: Colors.white), // Change to white
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: 5, // Adjust this based on your actual item count
          ),
        ),
      ],
    );
  }
}
