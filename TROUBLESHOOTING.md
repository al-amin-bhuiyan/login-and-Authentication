# 🔧 Troubleshooting: "Start New Conversation" Not Working

## 🎯 Quick Diagnosis

The "Start New Conversation" button not working is usually caused by one of these issues:

### 1. **Database Tables Not Created** ❌ (Most Common)
**Symptoms:**
- Error message: "relation does not exist" or "table does not exist"
- Button clicks but nothing happens
- Error in console about missing tables

**Solution:**
1. Open Supabase Dashboard: https://supabase.com/dashboard/project/rfmqnbutrutltrsdfgrj/sql
2. Click "New Query"
3. Copy ALL content from `supabase_schema.sql` file
4. Paste and click "Run"
5. You should see: "Success. No rows returned"

---

### 2. **Row Level Security (RLS) Blocking Access** ⚠️
**Symptoms:**
- Error message: "permission denied" or "new row violates row-level security policy"
- Tables exist but can't insert data

**Solution A - Quick Fix (For Testing):**
1. Go to: https://supabase.com/dashboard/project/rfmqnbutrutltrsdfgrj/auth/policies
2. Click on "conversations" table
3. Temporarily disable RLS or add policy:
   ```sql
   -- Allow all for testing (temporary)
   CREATE POLICY "Allow all on conversations"
   ON public.conversations
   FOR ALL
   TO anon, authenticated
   USING (true)
   WITH CHECK (true);
   ```

**Solution B - Proper Fix (For Production):**
The SQL schema already includes proper RLS policies. Make sure:
- User is authenticated (logged in)
- Policies allow authenticated users to insert

---

### 3. **Invalid API Credentials** 🔑
**Symptoms:**
- Error: "Invalid API key" or "JWT expired"
- Can't connect to Supabase at all

**Solution:**
1. Check `lib/auth/supabase_config.dart`
2. Verify URL: `https://rfmqnbutrutltrsdfgrj.supabase.co`
3. Verify API key starts with: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
4. Make sure you're using the **anon public** key, NOT the service_role key

---

### 4. **Network/Connection Issues** 🌐
**Symptoms:**
- Timeout errors
- "Network request failed"
- Works sometimes, not others

**Solution:**
- Check internet connection
- Try from different network
- Check Supabase project status: https://status.supabase.com/

---

## 🧪 How to Diagnose

### Use the Built-in Debug Tool:

1. Run your app
2. Go to Chat page
3. Click the **🐛 Bug icon** in the top right
4. Click **"Run Tests"**
5. Read the logs to see exactly what's failing

The debug tool will tell you:
- ✅ If tables exist
- ✅ If you can create conversations
- ✅ If realtime is working
- ✅ If authentication is set up
- ❌ What specific error is happening

---

## 📋 Step-by-Step Fix Guide

### Step 1: Verify Supabase Setup
```bash
# Check if you've completed these:
[ ] Created Supabase project
[ ] Got API credentials
[ ] Updated supabase_config.dart
[ ] Ran supabase_schema.sql
[ ] Enabled Realtime
```

### Step 2: Run the SQL Schema
```sql
-- Go to: https://supabase.com/dashboard/project/rfmqnbutrutltrsdfgrj/sql
-- Run this to verify tables exist:
SELECT tablename FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('conversations', 'messages');

-- Should return:
-- conversations
-- messages
```

### Step 3: Test Insert Manually
```sql
-- Try inserting a test conversation in SQL Editor:
INSERT INTO public.conversations (name, created_at) 
VALUES ('Test Conversation', NOW())
RETURNING *;

-- If this works, your database is fine
-- If this fails, check RLS policies
```

### Step 4: Check RLS Policies
```sql
-- View all policies:
SELECT schemaname, tablename, policyname, cmd, roles
FROM pg_policies 
WHERE tablename IN ('conversations', 'messages');

-- You should see policies for INSERT, SELECT, UPDATE, DELETE
```

### Step 5: Test from App
1. Open the debug page (bug icon)
2. Run all tests
3. Look for the specific error in Test 4 (creating conversation)
4. Follow the suggested solutions

---

## 🔍 Common Error Messages & Fixes

### Error: "relation 'public.conversations' does not exist"
**Fix:** You haven't run the SQL schema yet.
→ Run `supabase_schema.sql` in Supabase Dashboard

---

### Error: "new row violates row-level security policy"
**Fix:** RLS is blocking unauthenticated access.
→ Either:
  - Set up authentication and log in
  - Temporarily disable RLS for testing
  - Use the policies from `supabase_schema.sql`

---

### Error: "Invalid API key"
**Fix:** Wrong credentials in config.
→ Check `lib/auth/supabase_config.dart` matches your Supabase project

---

### Error: "Failed to create conversation: null"
**Fix:** Generic error, need more info.
→ Check console logs for detailed error
→ Use debug page to see exact error

---

### No Error, But Nothing Happens
**Fix:** Silent failure, likely RLS or auth issue.
→ Check console logs
→ Use debug page
→ Verify user is authenticated if RLS is enabled

---

## 🎯 Testing Checklist

Run through these tests:

### ✅ Test 1: Supabase Connection
```dart
// Should succeed
final supabase = Supabase.instance.client;
```

### ✅ Test 2: Table Access
```dart
// Should return data (or empty array)
await supabase.from('conversations').select();
```

### ✅ Test 3: Insert Permission
```dart
// Should create a conversation
await supabase.from('conversations').insert({
  'name': 'Test',
  'created_at': DateTime.now().toIso8601String(),
}).select().single();
```

### ✅ Test 4: Real-time
```dart
// Should subscribe without error
final channel = supabase.channel('test')
  .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'messages',
    callback: (payload) {},
  )
  .subscribe();
```

---

## 💡 Pro Tips

1. **Always check console logs first** - They show the exact error
2. **Use the debug page** - It automates all the checks
3. **Start with manual SQL inserts** - Proves the database works
4. **Test incrementally** - Fix one issue at a time
5. **For testing, you can disable RLS** - But re-enable for production

---

## 🆘 Still Not Working?

If you've tried everything above:

1. **Copy the exact error message** from:
   - Flutter console logs
   - Debug page logs
   - Supabase Dashboard logs

2. **Check what you have:**
   - ✅ Tables created? (Check Table Editor)
   - ✅ RLS configured? (Check Policies page)
   - ✅ API keys correct? (Check Settings → API)
   - ✅ Realtime enabled? (Check Database → Replication)

3. **Try the nuclear option:**
   ```sql
   -- Delete everything and start over
   DROP TABLE IF EXISTS public.messages CASCADE;
   DROP TABLE IF EXISTS public.conversations CASCADE;
   
   -- Then re-run supabase_schema.sql
   ```

---

## 📞 Quick Help Commands

### In Flutter App:
1. Open chat page
2. Click 🐛 bug icon
3. Click "Run Tests"
4. Read the output

### In Supabase Dashboard:
```sql
-- Check if tables exist
\dt public.*;

-- Count conversations
SELECT COUNT(*) FROM public.conversations;

-- View policies
SELECT * FROM pg_policies WHERE tablename = 'conversations';

-- Test insert
INSERT INTO public.conversations (name) VALUES ('Test') RETURNING *;
```

---

## ✅ Success Indicators

You know it's working when:
- ✅ Debug page shows all green checkmarks
- ✅ You can manually insert in SQL Editor
- ✅ "Create" button in app creates a conversation
- ✅ New conversation appears in the list
- ✅ No errors in console

---

**Need More Help?**
- Check `SUPABASE_SETUP.md` for detailed setup
- Check `SETUP_CHECKLIST.md` for step-by-step guide
- Use the debug page to identify the exact issue

---

**Most likely fix:** Run `supabase_schema.sql` in your Supabase Dashboard!

