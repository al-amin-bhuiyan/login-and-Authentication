-- ============================================
-- Supabase Real-Time Chat Database Schema
-- SAFE VERSION - Handles existing objects
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- DROP EXISTING POLICIES (Clean slate)
-- ============================================
DROP POLICY IF EXISTS "Allow read conversations for authenticated users" ON public.conversations;
DROP POLICY IF EXISTS "Allow insert conversations for authenticated users" ON public.conversations;
DROP POLICY IF EXISTS "Allow update conversations for authenticated users" ON public.conversations;
DROP POLICY IF EXISTS "Allow read messages for authenticated users" ON public.messages;
DROP POLICY IF EXISTS "Allow insert messages for authenticated users" ON public.messages;
DROP POLICY IF EXISTS "Allow update messages for authenticated users" ON public.messages;
DROP POLICY IF EXISTS "Allow delete own messages" ON public.messages;
DROP POLICY IF EXISTS "Allow all on conversations" ON public.conversations;
DROP POLICY IF EXISTS "Allow all on messages" ON public.messages;

-- ============================================
-- DROP EXISTING TRIGGERS (if any)
-- ============================================
DROP TRIGGER IF EXISTS trigger_update_conversation_last_message ON public.messages;
DROP FUNCTION IF EXISTS update_conversation_last_message();

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
-- Table: conversation_participants
-- Tracks which users are in each conversation
-- ============================================
CREATE TABLE IF NOT EXISTS public.conversation_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    user_name TEXT NOT NULL,
    user_email TEXT,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(conversation_id, user_id)
);

-- ============================================
-- Indexes for better query performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON public.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_conversations_last_message_at ON public.conversations(last_message_at DESC);
CREATE INDEX IF NOT EXISTS idx_conversation_participants_user_id ON public.conversation_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_conversation_participants_conversation_id ON public.conversation_participants(conversation_id);

-- ============================================
-- Row Level Security (RLS) Policies
-- ============================================

-- Enable RLS
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversation_participants ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PERMISSIVE POLICIES FOR TESTING
-- These allow all operations for anon and authenticated users
-- For production, you should tighten these policies
-- ============================================

-- Allow all operations on conversations
CREATE POLICY "Allow all on conversations"
ON public.conversations
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- Allow all operations on messages
CREATE POLICY "Allow all on messages"
ON public.messages
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- Allow all operations on conversation_participants
CREATE POLICY "Allow all on conversation_participants"
ON public.conversation_participants
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- Functions and Triggers
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
-- Verification: Check what was created
-- ============================================
DO $$
BEGIN
    RAISE NOTICE '✅ Setup Complete!';
    RAISE NOTICE '📊 Tables created: conversations, messages, conversation_participants';
    RAISE NOTICE '🔒 RLS enabled on all tables';
    RAISE NOTICE '🔑 Policies created: Allow all access for testing';
    RAISE NOTICE '⚡ Trigger created: Auto-update last message';
    RAISE NOTICE '';
    RAISE NOTICE '🎯 Next Steps:';
    RAISE NOTICE '1. Enable Realtime for all tables in Database → Replication';
    RAISE NOTICE '2. Run your Flutter app and test the chat!';
END $$;

