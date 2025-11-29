# Supabase Real-Time Chat Setup Guide

## 📋 Overview
This guide will help you set up Supabase backend for your Flutter real-time chatting app.

---

## 🚀 Step 1: Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up or log in
3. Click **"New Project"**
4. Enter project details:
   - **Name**: Your project name (e.g., "Flutter Chat App")
   - **Database Password**: Strong password (save this!)
   - **Region**: Choose closest to your users
5. Click **"Create new project"** and wait for setup (1-2 minutes)

---

## 🔑 Step 2: Get API Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy the following:
   - **Project URL** (e.g., `https://xyzcompany.supabase.co`)
   - **anon public** key (long JWT token)
3. Open `lib/auth/supabase_config.dart` in your project
4. Replace the placeholder values:
   ```dart
   static const String supabaseUrl = 'YOUR_PROJECT_URL_HERE';
   static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
   ```

---

## 🗄️ Step 3: Create Database Tables

1. In Supabase dashboard, go to **SQL Editor**
2. Click **"New Query"**
3. Copy and paste the SQL from `supabase_schema.sql` (in this folder)
4. Click **"Run"** to execute
5. Verify tables created: Go to **Table Editor** and you should see:
   - `conversations`
   - `messages`

---

## 🔒 Step 4: Set Up Authentication (Optional but Recommended)

### Enable Email/Password Auth:
1. Go to **Authentication** → **Providers**
2. Enable **"Email"** provider
3. Configure email templates if needed

### For Testing Without Real Auth:
You can use anonymous users or create test accounts directly in the Supabase dashboard under **Authentication** → **Users** → **Add user**.

---

## 🔐 Step 5: Configure Row Level Security (RLS)

The SQL schema already includes basic RLS policies. To review or modify:

1. Go to **Authentication** → **Policies**
2. Select a table (`conversations` or `messages`)
3. You'll see the policies:
   - **Allow read for authenticated users**
   - **Allow insert for authenticated users**
   - **Allow update for authenticated users**

### Important RLS Concepts:
- **RLS protects your data** at the database level
- Users can only access data they're authorized to see
- Policies use `auth.uid()` to identify the current user

---

## 📡 Step 6: Enable Realtime

1. Go to **Database** → **Replication**
2. Find the `messages` table
3. Toggle **"Enable Realtime"** ON
4. Do the same for `conversations` table
5. Click **"Save"** if prompted

---

## 🧪 Step 7: Test the Setup

### Install Dependencies:
```bash
flutter pub get
```

### Run the App:
```bash
flutter run
```

### Test Flow:
1. **Login/Sign up** (if using auth)
2. Go to **Home** → **Chat**
3. Click **"+"** to create a new conversation
4. Open the conversation and send messages
5. **Real-time test**: Open the same conversation in Supabase dashboard's Table Editor and insert a message directly—it should appear in your app instantly!

---

## 🛠️ Troubleshooting

### Issue: "Invalid API key" error
**Solution**: Double-check your `supabaseUrl` and `supabaseAnonKey` in `supabase_config.dart`

### Issue: Messages not appearing in real-time
**Solution**: 
- Verify Realtime is enabled for the `messages` table
- Check browser console or Flutter logs for connection errors
- Ensure you're subscribed to the correct conversation_id

### Issue: "Not authorized" or permission errors
**Solution**:
- Check RLS policies are correctly set up
- Ensure user is authenticated (`supabase.auth.currentUser` is not null)
- For testing, you can temporarily disable RLS (not recommended for production)

### Issue: Cannot insert messages
**Solution**:
- Verify the user is authenticated
- Check the `sender_id` matches `auth.uid()`
- Review the RLS policy for the `messages` table

---

## 📊 Database Schema Details

### `conversations` Table:
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key (auto-generated) |
| name | text | Conversation name |
| avatar_url | text | Optional avatar image URL |
| created_at | timestamp | Creation time |
| last_message_at | timestamp | Last message timestamp |
| last_message_text | text | Preview of last message |
| unread_count | int | Unread message count |

### `messages` Table:
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key (auto-generated) |
| conversation_id | uuid | Foreign key to conversations |
| sender_id | text | User ID who sent message |
| sender_name | text | Display name of sender |
| sender_avatar | text | Optional sender avatar URL |
| message_text | text | Message content |
| created_at | timestamp | Message timestamp |
| is_read | boolean | Read status |
| reply_to_id | uuid | Optional: ID of message being replied to |

---

## 🎯 Next Steps

### Add More Features:
1. **User presence**: Show online/offline status
2. **Typing indicators**: Show when someone is typing
3. **Message reactions**: Add emoji reactions
4. **File uploads**: Send images, videos, documents
5. **Push notifications**: Notify users of new messages
6. **Message search**: Search through conversation history
7. **Group chats**: Support for multiple users in one conversation

### Production Checklist:
- [ ] Secure your API keys (use environment variables)
- [ ] Implement proper authentication
- [ ] Review and tighten RLS policies
- [ ] Set up backup policies
- [ ] Monitor database usage
- [ ] Implement rate limiting
- [ ] Add error logging/monitoring

---

## 📚 Useful Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [Realtime Subscriptions](https://supabase.com/docs/guides/realtime)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

---

## 💡 Tips

1. **Use Supabase Dashboard**: Great for debugging—view real-time data, test queries
2. **Monitor Logs**: Check Supabase logs under **Logs** → **Postgres Logs**
3. **Use Indexes**: For better performance with large datasets, add indexes on frequently queried columns
4. **Batch Operations**: For multiple inserts/updates, use batch operations instead of individual calls
5. **Handle Offline**: Implement local caching for better offline experience

---

## 🤝 Support

If you encounter issues:
1. Check the [Supabase Community](https://github.com/supabase/supabase/discussions)
2. Review Flutter logs: `flutter logs`
3. Check Supabase dashboard logs
4. Verify your SQL schema matches the expected structure

---

**Happy Coding! 🚀**

