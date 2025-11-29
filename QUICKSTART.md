# 🚀 Quick Start Guide - Supabase Real-Time Chat

This guide will get your chat app up and running in **under 10 minutes**.

---

## ✅ What's Already Done

✓ **Supabase Flutter SDK** installed  
✓ **Chat UI** pages created (Chat List + Chat Room)  
✓ **Chat Controller** with GetX for state management  
✓ **Real-time subscriptions** configured  
✓ **Routes** set up with GoRouter  
✓ **Database models** created  

---

## 🎯 What You Need to Do

### 1️⃣ Create Supabase Project (5 minutes)

1. Go to **https://supabase.com** and sign up/login
2. Click **"New Project"**
3. Fill in:
   - Project name: `flutter-chat-app`
   - Database password: (Save this!)
   - Region: Select closest to you
4. Click **"Create new project"** and wait ~2 minutes

---

### 2️⃣ Get Your API Keys (1 minute)

1. In Supabase Dashboard → **Settings** → **API**
2. Copy:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon public** key (long JWT token)

---

### 3️⃣ Update Your Flutter App (30 seconds)

Open: `lib/auth/supabase_config.dart`

Replace:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

With your actual values:
```dart
static const String supabaseUrl = 'https://xxxxx.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJI...your-key...';
```

---

### 4️⃣ Create Database Tables (2 minutes)

1. In Supabase Dashboard → **SQL Editor**
2. Click **"New Query"**
3. Copy all SQL from `supabase_schema.sql` file (in your project root)
4. Paste and click **"Run"**
5. ✅ You should see "Success. No rows returned"

---

### 5️⃣ Enable Realtime (1 minute)

1. Go to **Database** → **Replication**
2. Find `messages` table → Toggle **"Enable Realtime"** ON
3. Find `conversations` table → Toggle **"Enable Realtime"** ON
4. Done!

---

### 6️⃣ Test Your App (30 seconds)

```bash
flutter run
```

#### Test Flow:
1. Login/Signup
2. Go to **Home** → Click **"Chat"** button
3. Click **"+"** floating button
4. Create a conversation (e.g., "Test Chat")
5. Open it and send messages
6. **Real-time test**: Open another device/emulator, login, and see messages appear live!

---

## 🧪 Advanced Testing

### Test Real-Time from Supabase Dashboard:

1. In Supabase → **Table Editor** → `messages`
2. Click **"Insert row"**
3. Fill in:
   - `conversation_id`: Copy from your conversations table
   - `sender_id`: `test-user`
   - `sender_name`: `Test Bot`
   - `message_text`: `Hello from Supabase!`
4. Click **"Save"**
5. 🎉 Message should appear instantly in your app!

---

## 📱 Features Included

✅ **Chat List** - View all conversations  
✅ **Real-time messaging** - Instant message delivery  
✅ **Message timestamps** - Smart time formatting  
✅ **Create conversations** - Start new chats  
✅ **Typing indicator area** - Ready for typing status  
✅ **Read status** - Mark messages as read  
✅ **Message bubbles** - Clean chat UI  
✅ **Auto-scroll** - Automatically scroll to new messages  
✅ **Loading states** - Smooth UX with loading indicators  

---

## 🔧 Troubleshooting

### Problem: "Invalid API key"
**Fix**: Double-check you copied the **anon public** key (not the service_role key)

### Problem: No messages appearing
**Fix**: Make sure Realtime is enabled for both tables

### Problem: Cannot send messages
**Fix**: Check if Row Level Security policies allow inserts (see `supabase_schema.sql`)

### Problem: Build errors
**Fix**: Run `flutter clean && flutter pub get`

---

## 🎨 Customization Ideas

Want to make it yours? Try:

- 🎨 Change chat bubble colors in `chat_page.dart`
- 📷 Add user avatars
- 🔔 Add push notifications
- 📎 Support image/file uploads
- 👥 Add group chats
- 🔍 Add search functionality
- ✏️ Add message editing/deletion
- 😊 Add emoji support

---

## 📚 File Structure

```
lib/
├── auth/
│   └── supabase_config.dart         ← YOUR API KEYS HERE
├── controllers/
│   └── chat_controller.dart         ← Chat logic & real-time
├── model/
│   └── chat_model.dart              ← Data models
├── pages/
│   └── chat_page.dart               ← UI: Chat List + Room
└── route/
    ├── routes.dart                  ← Route constants
    └── route_path.dart              ← GoRouter setup

supabase_schema.sql                  ← Database setup SQL
SUPABASE_SETUP.md                    ← Detailed setup guide
```

---

## 🚀 Next Steps

1. ✅ **Complete steps 1-6 above**
2. 📖 Read `SUPABASE_SETUP.md` for detailed explanations
3. 🎨 Customize the UI to match your brand
4. 🔐 Implement proper authentication
5. 🚢 Deploy to production!

---

## 💬 Need Help?

- 📖 **Detailed Guide**: See `SUPABASE_SETUP.md`
- 🔍 **Supabase Docs**: https://supabase.com/docs
- 💬 **Community**: https://github.com/supabase/supabase/discussions

---

**Happy Chatting! 💬✨**

