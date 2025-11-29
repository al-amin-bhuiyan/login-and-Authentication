import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Test Supabase Connection
///
/// This is a simple test file to verify your Supabase connection works.
/// You can run this to check if everything is configured correctly.
///
/// Usage:
/// 1. Make sure supabase_config.dart has your credentials
/// 2. Make sure you've run the SQL schema in Supabase
/// 3. Run this test from your main app or create a test button

class SupabaseConnectionTest {
  static Future<void> testConnection() async {
    try {
      final supabase = Supabase.instance.client;

      print('🔍 Testing Supabase Connection...');
      print('📡 Connected to Supabase');

      // Test 1: Check if tables exist
      print('\n✅ Test 1: Checking tables...');
      try {
        final conversationsCount = await supabase
            .from('conversations')
            .select()
            .count();
        print('   ✓ Conversations table exists (${conversationsCount.count} rows)');
      } catch (e) {
        print('   ✗ Conversations table error: $e');
        print('   💡 Run the SQL schema first!');
      }

      try {
        final messagesCount = await supabase
            .from('messages')
            .select()
            .count();
        print('   ✓ Messages table exists (${messagesCount.count} rows)');
      } catch (e) {
        print('   ✗ Messages table error: $e');
        print('   💡 Run the SQL schema first!');
      }

      // Test 2: Try to insert a test conversation
      print('\n✅ Test 2: Testing insert...');
      try {
        final response = await supabase
            .from('conversations')
            .insert({
              'name': 'Test Connection',
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

        print('   ✓ Insert successful! Conversation ID: ${response['id']}');

        // Clean up - delete the test conversation
        await supabase
            .from('conversations')
            .delete()
            .eq('id', response['id']);
        print('   ✓ Cleanup successful!');
      } catch (e) {
        print('   ✗ Insert failed: $e');
        print('   💡 Check RLS policies or authentication');
      }

      // Test 3: Test real-time connection
      print('\n✅ Test 3: Testing realtime...');
      try {
        final channel = supabase
            .channel('test-channel')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'messages',
              callback: (payload) {
                print('   ✓ Realtime working! Received: ${payload.eventType}');
              },
            );

        await channel.subscribe();
        print('   ✓ Realtime subscription successful!');

        // Clean up
        await channel.unsubscribe();
        print('   ✓ Unsubscribed successfully!');
      } catch (e) {
        print('   ✗ Realtime failed: $e');
        print('   💡 Enable Realtime for tables in Supabase Dashboard');
      }

      print('\n🎉 All tests completed!\n');

    } catch (e) {
      print('❌ Connection test failed: $e');
      print('💡 Check your supabase_config.dart credentials');
    }
  }

  /// Create a test UI button to run the connection test
  static Widget buildTestButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Testing Supabase Connection...'),
              ],
            ),
          ),
        );

        await testConnection();

        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connection test complete! Check console for results.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      icon: const Icon(Icons.wifi_tethering),
      label: const Text('Test Supabase Connection'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}

/// Quick standalone test function
/// Call this from anywhere to quickly test the connection
Future<bool> quickSupabaseTest() async {
  try {
    final supabase = Supabase.instance.client;
    await supabase.from('conversations').select().limit(1);
    print('✅ Supabase connection: OK');
    return true;
  } catch (e) {
    print('❌ Supabase connection: FAILED - $e');
    return false;
  }
}

