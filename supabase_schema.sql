-- ============================================
-- Supabase Real-Time Chat Database Schema
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- Table: conversations
-- Stores chat conversations/rooms
-- ============================================
CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_message_at TIMESTAMP WITH TIME ZONE,
    last_message_text TEXT,
    unread_count INTEGER DEFAULT 0
);

-- ============================================
-- Table: messages
-- Stores individual chat messages
-- ============================================
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    sender_id TEXT NOT NULL,
    sender_name TEXT NOT NULL,
    sender_avatar TEXT,
    message_text TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_read BOOLEAN DEFAULT FALSE,
    reply_to_id UUID REFERENCES public.messages(id) ON DELETE SET NULL
);

-- ============================================
-- Indexes for better query performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON public.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_conversations_last_message_at ON public.conversations(last_message_at DESC);

-- ============================================
-- Row Level Security (RLS) Policies
-- ============================================

-- Enable RLS
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Conversations Policies
-- Allow all authenticated users to read conversations
CREATE POLICY "Allow read conversations for authenticated users"
ON public.conversations
FOR SELECT
TO authenticated
USING (true);

-- Allow authenticated users to create conversations
CREATE POLICY "Allow insert conversations for authenticated users"
ON public.conversations
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow authenticated users to update conversations
CREATE POLICY "Allow update conversations for authenticated users"
ON public.conversations
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Messages Policies
-- Allow all authenticated users to read messages
CREATE POLICY "Allow read messages for authenticated users"
ON public.messages
FOR SELECT
TO authenticated
USING (true);

-- Allow authenticated users to insert their own messages
CREATE POLICY "Allow insert messages for authenticated users"
ON public.messages
FOR INSERT
TO authenticated
WITH CHECK (auth.uid()::text = sender_id);

-- Allow users to update their own messages (e.g., mark as read)
CREATE POLICY "Allow update messages for authenticated users"
ON public.messages
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Allow users to delete their own messages
CREATE POLICY "Allow delete own messages"
ON public.messages
FOR DELETE
TO authenticated
USING (auth.uid()::text = sender_id);

-- ============================================
-- Optional: For testing without authentication
-- Comment out the above RLS policies and use these instead
-- WARNING: This allows anyone to access data - FOR TESTING ONLY!
-- ============================================

/*
-- Allow all access to conversations (testing only)
CREATE POLICY "Allow all on conversations"
ON public.conversations
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- Allow all access to messages (testing only)
CREATE POLICY "Allow all on messages"
ON public.messages
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);
*/

-- ============================================
-- Functions and Triggers (Optional but useful)
-- ============================================

-- Function to update conversation's last_message_at
CREATE OR REPLACE FUNCTION update_conversation_last_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.conversations
    SET
        last_message_at = NEW.created_at,
        last_message_text = NEW.message_text
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update last message when new message inserted
CREATE TRIGGER trigger_update_conversation_last_message
AFTER INSERT ON public.messages
FOR EACH ROW
EXECUTE FUNCTION update_conversation_last_message();

-- ============================================
-- Sample Data (Optional - for testing)
-- ============================================

-- Insert sample conversation
INSERT INTO public.conversations (name, created_at)
VALUES
    ('General Chat', NOW()),
    ('Project Discussion', NOW()),
    ('Random', NOW());

-- Insert sample messages (replace 'user-123' with actual user ID or test ID)
INSERT INTO public.messages (conversation_id, sender_id, sender_name, message_text, created_at)
SELECT
    (SELECT id FROM public.conversations LIMIT 1),
    'user-123',
    'Test User',
    'Hello! This is a test message.',
    NOW();

-- ============================================
-- Realtime Setup
-- ============================================
-- To enable realtime, go to Supabase Dashboard:
-- 1. Navigate to Database → Replication
-- 2. Find 'messages' and 'conversations' tables
-- 3. Toggle "Enable Realtime" to ON
-- 4. Save changes

-- ============================================
-- Verification Queries
-- ============================================

-- Check if tables exist
SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename IN ('conversations', 'messages');

-- Check RLS is enabled
SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public' AND tablename IN ('conversations', 'messages');

-- View all policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename IN ('conversations', 'messages');

-- Count records
SELECT 'conversations' as table_name, COUNT(*) as count FROM public.conversations
UNION ALL
SELECT 'messages' as table_name, COUNT(*) as count FROM public.messages;

-- ============================================
-- Cleanup (Run if you need to start over)
-- ============================================

/*
DROP TRIGGER IF EXISTS trigger_update_conversation_last_message ON public.messages;
DROP FUNCTION IF EXISTS update_conversation_last_message();
DROP TABLE IF EXISTS public.messages CASCADE;
DROP TABLE IF EXISTS public.conversations CASCADE;
*/

