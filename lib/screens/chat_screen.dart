import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';

import '../models/chat_user.dart';
import '../services/chat_service.dart';
import '../widgets/custom_text.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    final user = firebase.FirebaseAuth.instance.currentUser;
    if (user != null) {
      ChatService.instance.syncUser(user);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = firebase.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const _ChatNotice(
        icon: Icons.lock_outline,
        title: 'Use a Firebase account for chat',
        message: 'Sign in with the Firebase option to see registered users and send messages.',
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search by name or email',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ChatUser>>(
            stream: ChatService.instance.users(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const _ChatNotice(
                  icon: Icons.cloud_off_outlined,
                  title: 'Chat could not load',
                  message: 'Check your internet connection and Firestore rules.',
                );
              }

              final users = (snapshot.data ?? [])
                  .where((user) => user.uid != currentUser.uid)
                  .where(
                    (user) =>
                        _query.isEmpty ||
                        user.name.toLowerCase().contains(_query) ||
                        user.email.toLowerCase().contains(_query),
                  )
                  .toList();
              if (users.isEmpty) {
                return _ChatNotice(
                  icon: _query.isEmpty
                      ? Icons.forum_outlined
                      : Icons.search_off_outlined,
                  title: _query.isEmpty ? 'No people to message yet' : 'No matches found',
                  message: _query.isEmpty
                      ? 'New Firebase accounts appear here after their first sign-in.'
                      : 'Try another name or email address.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
                itemCount: users.length,
                separatorBuilder: (_, _) => const Divider(height: 1, indent: 76),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _UserRow(
                    user: user,
                    onTap: () => Navigator.of(context).push(
                      ChatDetailScreen.route(
                        currentUserId: currentUser.uid,
                        currentUserEmail: currentUser.email ?? '',
                        recipient: user,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, required this.onTap});

  final ChatUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = user.name.isEmpty ? '?' : user.name[0].toUpperCase();
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      onTap: onTap,
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: const Color(0xFF31A24C),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
      title: CustomText(
        text: user.name,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: CustomText(
        text: user.email,
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _ChatNotice extends StatelessWidget {
  const _ChatNotice({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 14),
            CustomText(
              text: title,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            CustomText(
              text: message,
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
