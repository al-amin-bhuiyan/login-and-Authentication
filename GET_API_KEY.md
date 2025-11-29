# 🔑 How to Get Your Correct Supabase API Key

## ❌ The Problem

You're getting this error:
```
Invalid API key, code: 401, details: Unauthorized
```

**Why?** The API key in your config is incorrect. You provided a "publishable" key, but Supabase needs the **anon public** key (a JWT token).

---

## ✅ How to Fix (2 Minutes)

### Step 1: Open Your Supabase Project Settings

Go to this exact URL:
👉 **https://supabase.com/dashboard/project/rfmqnbutrutltrsdfgrj/settings/api**

*(This takes you directly to the API settings page for your project)*

---

### Step 2: Find the Correct Key

On that page, you'll see a section called **"Project API keys"**. Look for:

```
┌─────────────────────────────────────────┐
│ Project API keys                         │
├─────────────────────────────────────────┤
│                                          │
│ anon public                              │
│ eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... │ ← COPY THIS ONE!
│ [Copy] [Show/Hide]                       │
│                                          │
│ service_role secret                      │
│ eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... │ ← NOT THIS ONE!
│ [Copy] [Show/Hide]                       │
│                                          │
└─────────────────────────────────────────┘
```

**You need the `anon` `public` key** (the first one, NOT the service_role key).

---

### Step 3: Copy the Anon Key

1. Click the **"Copy"** button next to the **"anon public"** key
2. The key will be copied to your clipboard
3. It should be a LONG string starting with: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
4. It will be around 200-300 characters long

---

### Step 4: Update Your Config File

1. Open: `lib/auth/supabase_config.dart`
2. Find this line:
   ```dart
   static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
   ```
3. Replace `YOUR_ANON_KEY_HERE` with your actual key:
   ```dart
   static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3M...YOUR_ACTUAL_KEY...';
   ```
4. Save the file

---

### Step 5: Hot Reload Your App

```bash
# In your terminal where the app is running, press 'r'
r

# Or restart the app
flutter run
```

---

### Step 6: Test Again

1. Go to Chat page
2. Click the 🐛 debug icon
3. Click "Run Tests"
4. All tests should now pass! ✅

---

## 🎯 What the Keys Look Like

### ❌ WRONG Key (Publishable Key):
```
sb_publishable_F-Ul2qMAozpcH2WW1xIfsA_Pe99y0iF
```
- Starts with `sb_publishable_`
- Short (about 50 characters)
- **This will NOT work!**

### ✅ CORRECT Key (Anon JWT Key):
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJmbXFuYnV0cnV0bHRyc2RmZ3JqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMwMTczMDEsImV4cCI6MjA0ODU5MzMwMX0.aB1cD2eF3gH4iJ5kL6mN7oP8qR9sT0uV1wX2yZ3aB4cD5
```
- Starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9`
- Long (200-300+ characters)
- Has three parts separated by dots (.)
- **This is what you need!**

---

## 📸 Visual Guide

When you open the API settings page, it looks like this:

```
╔═══════════════════════════════════════════════════╗
║ Settings > API                                     ║
╠═══════════════════════════════════════════════════╣
║                                                    ║
║ Configuration                                      ║
║ ┌────────────────────────────────────────────┐   ║
║ │ Project URL                                 │   ║
║ │ https://rfmqnbutrutltrsdfgrj.supabase.co   │   ║
║ │ [Copy]                                      │   ║
║ └────────────────────────────────────────────┘   ║
║                                                    ║
║ Project API keys                                   ║
║ ┌────────────────────────────────────────────┐   ║
║ │ anon                                  public│   ║  ← THIS ONE!
║ │ eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...    │   ║
║ │ [Copy] [👁 Show/Hide]                       │   ║
║ └────────────────────────────────────────────┘   ║
║                                                    ║
║ ┌────────────────────────────────────────────┐   ║
║ │ service_role                          secret│   ║  ← NOT THIS ONE!
║ │ eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...    │   ║
║ │ [Copy] [👁 Show/Hide]                       │   ║
║ │ ⚠️ Never expose this key in client code    │   ║
║ └────────────────────────────────────────────┘   ║
║                                                    ║
╚═══════════════════════════════════════════════════╝
```

**Click "Copy" next to the "anon" key (the first one).**

---

## 🔍 Why Did This Happen?

Supabase has different types of keys:

| Key Type | Format | Usage | Safe for Frontend? |
|----------|--------|-------|-------------------|
| **anon (public)** | `eyJhbGciOi...` (JWT) | Client apps | ✅ YES |
| **service_role** | `eyJhbGciOi...` (JWT) | Backend only | ❌ NO |
| **publishable** | `sb_publishable_...` | Old format | ⚠️ Deprecated |

You accidentally used a publishable key or an incorrect format. The Flutter SDK needs the **anon JWT key**.

---

## ✅ After You Fix It

Once you update the key, the debug test should show:

```
✅ Test 1: Authentication Status
   ⚠️ No user logged in (will use anonymous access)

✅ Test 2: Check conversations table
   ✓ Conversations table exists (0 rows)

✅ Test 3: Check messages table
   ✓ Messages table exists (0 rows)

✅ Test 4: Test creating conversation
   ✓ Created test conversation successfully!
   ℹ️ Conversation ID: 12345-67890-...
   ✓ Cleanup successful

✅ Test 5: Test realtime subscription
   ✓ Realtime subscription successful
   ✓ Unsubscribed from realtime

🎉 All tests completed!
```

If you still see errors about missing tables, then run `supabase_schema.sql` in your Supabase Dashboard.

---

## 🆘 Still Having Issues?

### If the key still doesn't work:

1. **Make sure you copied the ENTIRE key** - Don't cut it off
2. **Check for extra spaces** - No spaces before or after the key
3. **Verify it's the anon key** - Not the service_role key
4. **Try regenerating the key** - In Supabase Dashboard, you can regenerate keys

### Where to verify:
- In Supabase Dashboard → Settings → API
- Look for the badge that says "public" next to the key
- The key should be visible (or hidden) with an eye icon

---

## 📋 Quick Checklist

- [ ] Opened https://supabase.com/dashboard/project/rfmqnbutrutltrsdfgrj/settings/api
- [ ] Found "Project API keys" section
- [ ] Clicked "Copy" next to "anon public" key
- [ ] Key starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9`
- [ ] Key is 200+ characters long
- [ ] Pasted into `supabase_config.dart`
- [ ] Saved the file
- [ ] Restarted/hot-reloaded the app
- [ ] Ran debug tests again

---

**Direct Link to Get Your Key:**
👉 https://supabase.com/dashboard/project/rfmqnbutrutltrsdfgrj/settings/api

**Just copy the "anon public" key and paste it into `supabase_config.dart`!** 🔑

