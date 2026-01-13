import 'package:flutter/material.dart';
import 'package:parkquest/data/user_manager.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final UserManager user = UserManager();
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
  }

  Future<void> _loadUserData() async {
    await user.load();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("ParkQuest"),
          backgroundColor: const Color(0xFF00AEEF),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ParkQuest"),
          backgroundColor: const Color(0xFF00AEEF),
          foregroundColor:  Colors.white,
        ),
        body: Column(
          children:  [
            Container(
              padding:  const EdgeInsets. all(20),
              color: const Color(0xFF00AEEF),
              width: double.infinity,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Color(0xFF00AEEF)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.isLoggedIn ? user.username : "Guest",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text("Level 3", style: TextStyle(color: Colors.white, fontSize: 20)),
                  Text(
                    "${user.points} Points",
                    style: const TextStyle(
                      fontSize:  18,
                      color: Colors. amberAccent,
                      fontWeight:  FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const TabBar(
              labelColor: Color(0xFF00AEEF),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF00AEEF),
              tabs: [
                Tab(text: "History"),
                Tab(text: "Rewards"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // History Tab
                  user.history.isEmpty
                      ? const Center(
                          child: Text(
                            "No history yet.",
                            style:  TextStyle(fontSize: 16, color: Colors. grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: user.history.length,
                          itemBuilder: (ctx, i) {
                            final item = user. history[i];
                            return ListTile(
                              leading: const Icon(Icons.history, color: Colors.grey),
                              title: Text(item.action),
                              subtitle: Text(
                                "${item.location} - ${item.date. toString().substring(0, 10)}",
                              ),
                              trailing: Text(
                                "+${item.points}",
                                style: const TextStyle(
                                  color:  Colors.green,
                                  fontWeight: FontWeight. bold,
                                ),
                              ),
                            );
                          },
                        ),
                  // Rewards Tab
                  user.rewards.isEmpty
                      ? const Center(
                          child: Text(
                            "No rewards available.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: user.rewards.length,
                          itemBuilder: (ctx, i) {
                            final reward = user.rewards[i];
                            return Card(
                              elevation: 4,
                              child: ListTile(
                                title:  Text(reward.title),
                                subtitle: Text(reward.description),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                    backgroundColor: 
                                        reward.isUnlocked ? Colors.grey : const Color(0xFF00AEEF),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed:  reward.isUnlocked
                                      ? null
                                      :  () async {
                                          final success = await user.unlockReward(reward.id);
                                          String message = success ? "Reward unlocked!" : "Not enough points. ";
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text(message)),
                                            );
                                            setState(() {}); // Ανανέωση UI
                                          }
                                        },
                                  child: Text(
                                    reward.isUnlocked ? "Unlocked" : "${reward.cost} pts",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}