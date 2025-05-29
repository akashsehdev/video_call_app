// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:video_call_app/screens/call_user_screen.dart';
// import 'package:video_call_app/services/fcm_service.dart';
// import '../services/agora_service.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String? selectedUserId;
//   List<Map<String, dynamic>> users = [];
//   String? selectedCallUserId; // The user selected to call

//   @override
//   void initState() {
//     super.initState();
//     _loadUser();
//     _fetchUsers();
//   }

//   // Load logged-in user from shared preferences
//   Future<void> _loadUser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getString('userId');
//     if (userId != null) {
//       await FCMService.initFCM(userId);
//     }
//     setState(() {
//       selectedUserId = userId;
//       selectedCallUserId = null; // Clear previous call selection on load
//     });
//   }

//   // Fetch all users from Firestore
//   Future<void> _fetchUsers() async {
//     final snapshot = await FirebaseFirestore.instance.collection('users').get();
//     final allUsers =
//         snapshot.docs
//             .map(
//               (doc) => {
//                 'userId': doc['userId'] as String,
//                 'userName': doc['userName'] as String,
//               },
//             )
//             .toList();

//     print("Fetched users: $allUsers");

//     setState(() {
//       users = allUsers;
//     });
//   }

//   // Select a user to log in as
//   Future<void> _selectUser(String userId) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('userId', userId);
//     await FCMService.initFCM(userId);
//     setState(() {
//       selectedUserId = userId;
//       selectedCallUserId = null; // Clear any previously selected call user
//     });
//   }

//   // Start a call to the selected user
//   Future<void> _startCall() async {
//     if (selectedCallUserId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a user to call')),
//       );
//       return;
//     }
//     if (selectedUserId == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('No user is logged in')));
//       return;
//     }
//     await AgoraService.initiateCall(
//       callerId: selectedUserId!,
//       receiverId: selectedCallUserId!,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("One-to-One Video Call")),
//       body: Center(
//         child:
//             selectedUserId == null
//                 ? users.isEmpty
//                     ? const CircularProgressIndicator()
//                     : Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text('Select a user to login:'),
//                         const SizedBox(height: 20),
//                         Expanded(
//                           child: ListView.builder(
//                             itemCount: users.length,
//                             itemBuilder: (context, index) {
//                               final user = users[index];
//                               return ListTile(
//                                 leading: CircleAvatar(
//                                   child: Text(
//                                     user['userName']![0].toUpperCase(),
//                                   ),
//                                 ),
//                                 title: Text(user['userName']!),
//                                 onTap: () => _selectUser(user['userId']!),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     )
//                 : users.isEmpty
//                 ? const CircularProgressIndicator()
//                 : Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('Logged in as: $selectedUserId'),
//                     const SizedBox(height: 20),
//                     const Text('Select a user to call:'),
//                     const SizedBox(height: 10),
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount:
//                             users
//                                 .where((u) => u['userId'] != selectedUserId)
//                                 .length,
//                         itemBuilder: (context, index) {
//                           final filteredUsers =
//                               users
//                                   .where((u) => u['userId'] != selectedUserId)
//                                   .toList();
//                           final user = filteredUsers[index];

//                           final isSelected =
//                               selectedCallUserId == user['userId'];

//                           return ListTile(
//                             leading: CircleAvatar(
//                               child: Text(user['userName']![0].toUpperCase()),
//                             ),
//                             title: Text(user['userName']!),
//                             trailing:
//                                 isSelected
//                                     ? const Icon(
//                                       Icons.call,
//                                       color: Colors.green,
//                                     )
//                                     : null,
//                             selected: isSelected,
//                             selectedTileColor: Colors.blue.shade100,
//                             onTap: () {
//                               setState(() {
//                                 selectedCallUserId = user['userId'];
//                               });
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder:
//                                       (context) => CallUserScreen(
//                                         callerId: selectedUserId!,
//                                         receiverId: user['userId']!,
//                                         receiverName: user['userName']!,
//                                       ),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _startCall,
//                       child: const Text("Start Call"),
//                     ),
//                   ],
//                 ),
//       ),
//     );
//   }
// }

// New Code
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_call_app/screens/call_user_screen.dart';
import 'package:video_call_app/services/fcm_service.dart';
import '../services/agora_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? loggedInUserId;
  List<Map<String, dynamic>> users = [];
  String? selectedCallUserId;

  @override
  void initState() {
    super.initState();
    _initializeUserAndFCM();
    _fetchUsers();
  }

  Future<void> _initializeUserAndFCM() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      await FCMService.initFCM(
        userId,
      ); // Setup FCM for this user (subscribe, listeners)
    }
    setState(() {
      loggedInUserId = userId;
      selectedCallUserId = null;
    });
  }

  Future<void> _fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final allUsers =
        snapshot.docs
            .map(
              (doc) => {
                'userId': doc['userId'] as String,
                'userName': doc['userName'] as String,
              },
            )
            .toList();

    setState(() {
      users = allUsers;
    });
  }

  Future<void> _selectUser(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await FCMService.initFCM(userId);
    setState(() {
      loggedInUserId = userId;
      selectedCallUserId = null;
    });
  }

  Future<void> _startCall() async {
    if (selectedCallUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a user to call')),
      );
      return;
    }
    if (loggedInUserId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No user is logged in')));
      return;
    }

    await AgoraService.initiateCall(
      context: context,
      callerId: loggedInUserId!,
      receiverId: selectedCallUserId!,
      isVideoCall:
          true, // default video call, user can choose in call_user_screen.dart
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("One-to-One Video Call")),
      body:
          loggedInUserId == null
              ? users.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Select a user to login:',
                        style: TextStyle(fontSize: 18),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(user['userName'][0].toUpperCase()),
                              ),
                              title: Text(user['userName']),
                              onTap: () => _selectUser(user['userId']),
                            );
                          },
                        ),
                      ),
                    ],
                  )
              : users.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Logged in as: $loggedInUserId',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Select a user to call:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          users
                              .where((u) => u['userId'] != loggedInUserId)
                              .length,
                      itemBuilder: (context, index) {
                        final filteredUsers =
                            users
                                .where((u) => u['userId'] != loggedInUserId)
                                .toList();
                        final user = filteredUsers[index];
                        final isSelected = selectedCallUserId == user['userId'];

                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(user['userName'][0].toUpperCase()),
                          ),
                          title: Text(user['userName']),
                          trailing:
                              isSelected
                                  ? const Icon(Icons.call, color: Colors.green)
                                  : null,
                          selected: isSelected,
                          selectedTileColor: Colors.blue.shade100,
                          onTap: () {
                            setState(() {
                              selectedCallUserId = user['userId'];
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => CallUserScreen(
                                      callerId: loggedInUserId!,
                                      receiverId: user['userId']!,
                                      receiverName: user['userName']!,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _startCall,
                    child: const Text("Start Call"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Logout user
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.remove('userId');
                      setState(() {
                        loggedInUserId = null;
                        selectedCallUserId = null;
                      });
                    },
                    child: const Text('Logout'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
    );
  }
}
