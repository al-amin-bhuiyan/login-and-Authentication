import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/supabase_config.dart';

class SupabaseDebugPage extends StatefulWidget {
  const SupabaseDebugPage({super.key});

  @override
  State<SupabaseDebugPage> createState() => _SupabaseDebugPageState();
}

class _SupabaseDebugPageState extends State<SupabaseDebugPage> {
  final supabase = Supabase.instance.client;
  String status = 'Not tested yet';
  List<String> logs = [];
  bool isLoading = false;

  void addLog(String message) {
    setState(() {
      logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
    print(message);
  }

  Future<void> runTests() async {
    setState(() {
      isLoading = true;
      logs.clear();
      status = 'Running tests...';
    });

    addLog('🔍 Starting Supabase tests...');
    addLog('📡 URL: ${SupabaseConfig.supabaseUrl}');
    addLog('🔑 API Key configured: ${SupabaseConfig.supabaseAnonKey.isNotEmpty}');

    // Test 1: Check authentication status
    addLog('\n✅ Test 1: Authentication Status');
    final user = supabase.auth.currentUser;
    if (user != null) {
      addLog('   ✓ User is logged in: ${user.email ?? user.id}');
    } else {
      addLog('   ⚠️ No user logged in (will use anonymous access)');
    }

    // Test 2: Check if conversations table exists
    addLog('\n✅ Test 2: Check conversations table');
    try {
      final conversationsResponse = await supabase
          .from('conversations')
          .select()
          .limit(1);

      addLog('   ✓ Conversations table exists');
      addLog('   ℹ️ Sample data count: ${(conversationsResponse as List).length}');
    } catch (e) {
      addLog('   ❌ Conversations table error: $e');
      addLog('   💡 Solution: Run supabase_schema.sql in Supabase Dashboard');
    }

    // Test 3: Check if messages table exists
    addLog('\n✅ Test 3: Check messages table');
    try {
      final messagesResponse = await supabase
          .from('messages')
          .select()
          .limit(1);

      addLog('   ✓ Messages table exists');
      addLog('   ℹ️ Sample data count: ${(messagesResponse as List).length}');
    } catch (e) {
      addLog('   ❌ Messages table error: $e');
      addLog('   💡 Solution: Run supabase_schema.sql in Supabase Dashboard');
    }

    // Test 4: Try to create a test conversation
    addLog('\n✅ Test 4: Test creating conversation');
    try {
      final testConvResponse = await supabase
          .from('conversations')
          .insert({
            'name': 'Debug Test ${DateTime.now().millisecondsSinceEpoch}',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      addLog('   ✓ Created test conversation successfully!');
      addLog('   ℹ️ Conversation ID: ${testConvResponse['id']}');

      // Clean up - delete the test conversation
      await supabase
          .from('conversations')
          .delete()
          .eq('id', testConvResponse['id']);

      addLog('   ✓ Cleanup successful');
    } catch (e) {
      addLog('   ❌ Failed to create conversation: $e');
      if (e.toString().contains('JWT')) {
        addLog('   💡 Solution: Check your API key in supabase_config.dart');
      } else if (e.toString().contains('permission') || e.toString().contains('policy')) {
        addLog('   💡 Solution: Check RLS policies or enable auth');
      } else if (e.toString().contains('relation') || e.toString().contains('does not exist')) {
        addLog('   💡 Solution: Run supabase_schema.sql to create tables');
      }
    }

    // Test 5: Check realtime capabilities
    addLog('\n✅ Test 5: Test realtime subscription');
    try {
      final channel = supabase.channel('debug-test-${DateTime.now().millisecondsSinceEpoch}');

      await channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'messages',
            callback: (payload) {
              addLog('   ✓ Realtime event received: ${payload.eventType}');
            },
          )
          .subscribe();

      addLog('   ✓ Realtime subscription successful');

      // Wait a bit then unsubscribe
      await Future.delayed(const Duration(seconds: 1));
      await channel.unsubscribe();
      addLog('   ✓ Unsubscribed from realtime');
    } catch (e) {
      addLog('   ❌ Realtime subscription failed: $e');
      addLog('   💡 Solution: Enable Realtime in Supabase Dashboard → Database → Replication');
    }

    addLog('\n🎉 All tests completed!');

    setState(() {
      isLoading = false;
      status = 'Tests completed - Check logs above';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Debug'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Supabase Connection Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : runTests,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(isLoading ? 'Running Tests...' : 'Run Tests'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Logs
          Expanded(
            child: logs.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bug_report, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Press "Run Tests" to check Supabase connection',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      Color textColor = Colors.black87;
                      IconData? icon;

                      if (log.contains('✓')) {
                        textColor = Colors.green[700]!;
                        icon = Icons.check_circle;
                      } else if (log.contains('❌')) {
                        textColor = Colors.red[700]!;
                        icon = Icons.error;
                      } else if (log.contains('⚠️')) {
                        textColor = Colors.orange[700]!;
                        icon = Icons.warning;
                      } else if (log.contains('💡')) {
                        textColor = Colors.blue[700]!;
                        icon = Icons.lightbulb;
                      } else if (log.contains('ℹ️')) {
                        textColor = Colors.grey[700]!;
                        icon = Icons.info;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (icon != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8, top: 2),
                                child: Icon(icon, size: 16, color: textColor),
                              ),
                            Expanded(
                              child: Text(
                                log,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Setup Checklist:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildChecklistItem('1. Run supabase_schema.sql in Supabase SQL Editor'),
                _buildChecklistItem('2. Enable Realtime for messages & conversations tables'),
                _buildChecklistItem('3. (Optional) Set up authentication for production'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.arrow_right, size: 16),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

