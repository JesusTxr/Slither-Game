-- ============================================
-- SCRIPT LIMPIO PARA SUPABASE
-- Este script limpia todo primero y luego crea las tablas
-- ============================================

-- 🧹 PASO 1: LIMPIAR TODO (Eliminar tablas antiguas si existen)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP TABLE IF EXISTS room_players CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- ============================================

-- ✨ PASO 2: CREAR TABLA DE PERFILES
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  nickname TEXT NOT NULL DEFAULT 'Player',
  avatar TEXT NOT NULL DEFAULT '🐍',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  total_games INTEGER DEFAULT 0,
  total_wins INTEGER DEFAULT 0,
  highest_score INTEGER DEFAULT 0
);

-- ============================================

-- 🔒 PASO 3: CONFIGURAR SEGURIDAD
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Perfiles públicos" 
  ON profiles FOR SELECT 
  USING (true);

CREATE POLICY "Usuarios pueden actualizar su perfil" 
  ON profiles FOR UPDATE 
  USING (auth.uid() = id);

-- ============================================

-- ⚙️ PASO 4: FUNCIÓN PARA CREAR PERFIL AUTOMÁTICAMENTE
CREATE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, nickname, avatar)
  VALUES (
    new.id, 
    COALESCE(
      split_part(new.email, '@', 1),
      'Player_' || substr(new.id::text, 1, 8)
    ), 
    '🐍'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================

-- 🎯 PASO 5: TRIGGER PARA NUEVOS USUARIOS
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================

-- 🏠 PASO 6: TABLA DE SALAS (OPCIONAL)
CREATE TABLE rooms (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  host_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'waiting',
  max_players INTEGER DEFAULT 10,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  started_at TIMESTAMP WITH TIME ZONE,
  finished_at TIMESTAMP WITH TIME ZONE
);

ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Salas públicas" 
  ON rooms FOR SELECT 
  USING (true);

CREATE POLICY "Host puede actualizar sala" 
  ON rooms FOR UPDATE 
  USING (auth.uid() = host_id);

-- ============================================

-- 👥 PASO 7: TABLA DE JUGADORES EN SALAS
CREATE TABLE room_players (
  room_id UUID REFERENCES rooms(id) ON DELETE CASCADE,
  player_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_ready BOOLEAN DEFAULT FALSE,
  final_score INTEGER,
  PRIMARY KEY (room_id, player_id)
);

ALTER TABLE room_players ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Participantes visibles" 
  ON room_players FOR SELECT 
  USING (true);

-- ============================================

-- 🚀 PASO 8: ÍNDICES PARA RENDIMIENTO
CREATE INDEX idx_profiles_nickname ON profiles(nickname);
CREATE INDEX idx_rooms_code ON rooms(code);
CREATE INDEX idx_rooms_status ON rooms(status);
CREATE INDEX idx_room_players_room ON room_players(room_id);

-- ============================================
-- ✅ ¡COMPLETADO!
-- ============================================





