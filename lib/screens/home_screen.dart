import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_call_app/screens/call_user_screen.dart';
// import 'package:video_call_app/services/call_service.dart';
import 'package:video_call_app/services/fcm_service.dart';
import 'package:video_call_app/services/call_log_service.dart';
import '../services/agora_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String? loggedInUserId;
  List<Map<String, dynamic>> users = [];
  String? selectedCallUserId;
  List<Map<String, dynamic>> callLogs = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeUserAndFCM();
    _fetchUsers();
    _fetchCallLogs();
  }

  Future<void> _initializeUserAndFCM() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      await FCMService.initFCM(userId);
      // await CallService().initialize(userId);
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

  Future<void> _fetchCallLogs() async {
    final logs = await CallLogService.getLogs();
    setState(() {
      callLogs = logs.reversed.toList(); // most recent first
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

    // Log the call
    await AgoraService.initiateCall(
      callerId: loggedInUserId!,
      receiverId: selectedCallUserId!,
      isVideoCall: true,
    );

    // Refresh call logs after the call initiation
    await _fetchCallLogs();

    // Initiate the call
    await AgoraService.initiateCall(
      callerId: loggedInUserId!,
      receiverId: selectedCallUserId!,
      isVideoCall: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "One-to-One Video Call",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "Users"), Tab(text: "Call History")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 0: Users
          loggedInUserId == null
              ? (users.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _buildUserSelection())
              : _buildLoggedInUserView(),

          // Tab 1: Call History
          loggedInUserId == null
              ? Center(
                child: Text(
                  textAlign: TextAlign.center,
                  "Please login to check \ncall history",
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
              : _buildCallHistoryView(loggedInUserId!),
        ],
      ),
    );
  }

  Widget _buildUserSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 20),
          child: Text(
            'Select a user to login:',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  child: Text(user['userName'][0].toUpperCase()),
                ),
                title: Text(
                  user['userName'],
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onTap: () => _selectUser(user['userId']),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedInUserView() {
    final filteredUsers =
        users.where((u) => u['userId'] != loggedInUserId).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            'Logged in as: $loggedInUserId',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Padding(
        //   padding: const EdgeInsets.only(left: 20.0),
        //   child: Text(
        //     'Select a user to call:',
        //     style: GoogleFonts.montserrat(
        //       fontSize: 18,
        //       fontWeight: FontWeight.w500,
        //     ),
        //   ),
        // ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              final isSelected = selectedCallUserId == user['userId'];

              return ListTile(
                leading: CircleAvatar(
                  child: Text(user['userName'][0].toUpperCase()),
                ),
                title: Text(
                  user['userName'],
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                trailing:
                    isSelected
                        ? const Icon(
                          Icons.video_call,
                          color: Colors.green,
                          size: 24,
                        )
                        : const Icon(
                          Icons.video_call,
                          color: Colors.grey,
                          size: 24,
                        ),
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
        // ElevatedButton(onPressed: _startCall, child: const Text("Start Call")),
        const SizedBox(height: 20),
        // Center(
        //   child: ElevatedButton(
        //     onPressed: () async {
        //       SharedPreferences prefs = await SharedPreferences.getInstance();
        //       await prefs.remove('userId');
        //       setState(() {
        //         loggedInUserId = null;
        //         selectedCallUserId = null;
        //       });
        //     },
        //     child: const Icon(Icons.logout),
        //   ),
        // ),
        Center(
          child: GestureDetector(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('userId');
              setState(() {
                loggedInUserId = null;
                selectedCallUserId = null;
              });
            },
            child: Container(
              width: 70,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                border: Border.all(width: 0.5, color: Colors.grey),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCallHistoryView(String? currentUserId) {
    if (currentUserId == null) {
      return Center(
        child: Text(
          "Please login to check call history.",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (callLogs.isEmpty) {
      return const Center(
        child: Text(
          "No call history available.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Sort call logs by timestamp descending (recent at top)
    callLogs.sort((a, b) {
      DateTime timeA =
          a['timestamp'] is Timestamp
              ? (a['timestamp'] as Timestamp).toDate()
              : DateTime.parse(a['timestamp']);
      DateTime timeB =
          b['timestamp'] is Timestamp
              ? (b['timestamp'] as Timestamp).toDate()
              : DateTime.parse(b['timestamp']);
      return timeB.compareTo(timeA);
    });

    return RefreshIndicator(
      onRefresh: _fetchCallLogs,
      child: ListView.builder(
        itemCount: callLogs.length,
        itemBuilder: (context, index) {
          final log = callLogs[index];

          DateTime timestamp =
              log['timestamp'] is Timestamp
                  ? (log['timestamp'] as Timestamp).toDate()
                  : DateTime.parse(log['timestamp']);

          String formattedTime = DateFormat(
            'dd MMM yyyy, hh:mm a',
          ).format(timestamp);

          bool isCaller = log['callerId'] == currentUserId;
          bool isReceiver = log['receiverId'] == currentUserId;

          IconData iconData;
          Color iconColor;

          if (isCaller) {
            iconData = Icons.call_made;
            iconColor = Colors.green;
          } else if (isReceiver) {
            iconData = Icons.call_received;
            iconColor = Colors.blue;
          } else {
            iconData = Icons.call;
            iconColor = Colors.grey;
          }

          return ListTile(
            leading: Icon(iconData, color: iconColor),
            title: Text(
              "Caller: ${log['callerId'] ?? 'Unknown'}  →  Receiver: ${log['receiverId'] ?? 'Unknown'}",
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              "$formattedTime",
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}
