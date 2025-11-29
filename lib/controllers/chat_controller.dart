import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/chat_model.dart';

class ChatController extends GetxController {
  final supabase = Supabase.instance.client;

  // Observable lists
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxList<Conversation> conversations = <Conversation>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString currentConversationId = ''.obs;

  RealtimeChannel? _messagesSubscription;

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  @override
  void onClose() {
    _messagesSubscription?.unsubscribe();
    super.onClose();
  }

  // Load all conversations for current user
  Future<void> loadConversations() async {
    try {
      isLoading.value = true;
      print('Loading conversations...');

      final response = await supabase
          .from('conversations')
          .select()
          .order('last_message_at', ascending: false);

      print('Loaded ${(response as List).length} conversations');

      conversations.value = (response as List)
          .map((json) => Conversation.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading conversations: $e');
      Get.snackbar(
        'Error',
        'Failed to load conversations: $e',
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load messages for a specific conversation
  Future<void> loadMessages(String conversationId) async {
    try {
      isLoading.value = true;
      currentConversationId.value = conversationId;

      final response = await supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      messages.value = (response as List)
          .map((json) => ChatMessage.fromJson(json))
          .toList();

      // Subscribe to real-time updates
      subscribeToMessages(conversationId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Subscribe to real-time message updates
  void subscribeToMessages(String conversationId) {
    // Unsubscribe from previous channel
    _messagesSubscription?.unsubscribe();

    // Subscribe to new messages in this conversation
    _messagesSubscription = supabase
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            final newMessage = ChatMessage.fromJson(payload.newRecord);
            messages.add(newMessage);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            final updatedMessage = ChatMessage.fromJson(payload.newRecord);
            final index = messages.indexWhere((m) => m.id == updatedMessage.id);
            if (index != -1) {
              messages[index] = updatedMessage;
            }
          },
        )
        .subscribe();
  }

  // Send a new message
  Future<void> sendMessage({
    required String conversationId,
    required String messageText,
    String? replyToId,
  }) async {
    if (messageText.trim().isEmpty) return;

    try {
      isSending.value = true;
      print('Sending message: $messageText to conversation: $conversationId');

      // Get user info (or use anonymous if not logged in)
      final user = supabase.auth.currentUser;
      final senderId = user?.id ?? 'anonymous-${DateTime.now().millisecondsSinceEpoch}';
      final senderName = user?.email?.split('@')[0] ?? 'Anonymous User';

      print('Sender: $senderName (ID: $senderId)');

      final messageData = {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_name': senderName,
        'message_text': messageText.trim(),
        'reply_to_id': replyToId,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('Inserting message: $messageData');

      await supabase.from('messages').insert(messageData);

      print('Message inserted successfully');

      // Update conversation's last message
      await supabase.from('conversations').update({
        'last_message_at': DateTime.now().toIso8601String(),
        'last_message_text': messageText.trim(),
      }).eq('id', conversationId);

      print('Conversation updated with last message');

    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message: $e',
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending.value = false;
    }
  }

  // Create a new conversation
  Future<String?> createConversation(String name) async {
    try {
      print('Creating conversation: $name');

      // Get current user info
      final user = supabase.auth.currentUser;
      final userId = user?.id ?? 'anonymous-${DateTime.now().millisecondsSinceEpoch}';
      final userName = user?.email?.split('@')[0] ?? 'Anonymous User';
      final userEmail = user?.email;

      print('Creator: $userName (ID: $userId)');

      final response = await supabase
          .from('conversations')
          .insert({
            'name': name,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final conversationId = response['id'].toString();
      print('Conversation created successfully: $conversationId');

      // Add creator as participant
      try {
        await supabase.from('conversation_participants').insert({
          'conversation_id': conversationId,
          'user_id': userId,
          'user_name': userName,
          'user_email': userEmail,
          'joined_at': DateTime.now().toIso8601String(),
        });
        print('Added creator as participant');
      } catch (e) {
        print('Warning: Could not add participant: $e');
      }

      await loadConversations();
      return conversationId;
    } catch (e) {
      print('Error creating conversation: $e');
      Get.snackbar(
        'Error',
        'Failed to create conversation: $e',
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String conversationId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', user.id);
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  // Get participants in a conversation
  Future<List<Map<String, dynamic>>> getConversationParticipants(String conversationId) async {
    try {
      final response = await supabase
          .from('conversation_participants')
          .select()
          .eq('conversation_id', conversationId);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error getting participants: $e');
      return [];
    }
  }

  // Add participant to conversation
  Future<bool> addParticipant(String conversationId, String userId, String userName, {String? userEmail}) async {
    try {
      await supabase.from('conversation_participants').insert({
        'conversation_id': conversationId,
        'user_id': userId,
        'user_name': userName,
        'user_email': userEmail,
        'joined_at': DateTime.now().toIso8601String(),
      });
      print('Added participant: $userName to conversation: $conversationId');
      return true;
    } catch (e) {
      print('Error adding participant: $e');
      return false;
    }
  }
}

