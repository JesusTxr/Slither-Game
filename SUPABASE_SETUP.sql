-- ============================================
-- SCRIPTS SQL PARA SUPABASE
-- Copia y pega estos scripts en el SQL Editor de Supabase
-- ============================================

-- 1️⃣ TABLA DE PERFILES DE USUARIO
-- Guarda nickname, avatar, estadísticas
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  nickname TEXT NOT NULL DEFAULT 'Player',
  avatar TEXT NOT NULL DEFAULT '🐍',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Estadísticas opcionales
  total_games INTEGER DEFAULT 0,
  total_wins INTEGER DEFAULT 0,
  highest_score INTEGER DEFAULT 0
);

-- Habilitar Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Políticas de seguridad
-- Los usuarios pueden ver todos los perfiles
CREATE POLICY "Perfiles públicos" 
  ON profiles FOR SELECT 
  USING (true);

-- Los usuarios solo pueden actualizar su propio perfil
CREATE POLICY "Usuarios pueden actualizar su perfil" 
  ON profiles FOR UPDATE 
  USING (auth.uid() = id);

-- Crear perfil automáticamente cuando se registra un usuario
CREATE OR REPLACE FUNCTION public.handle_new_user()
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

-- Trigger para crear perfil automáticamente
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================

-- 2️⃣ TABLA DE SALAS (OPCIONAL - Para persistencia)
-- Si quieres guardar historial de partidas
CREATE TABLE IF NOT EXISTS rooms (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  host_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'waiting', -- waiting, playing, finished
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

-- 3️⃣ TABLA DE PARTICIPANTES EN SALAS (OPCIONAL)
CREATE TABLE IF NOT EXISTS room_players (
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

-- 4️⃣ ÍNDICES PARA MEJORAR RENDIMIENTO
CREATE INDEX IF NOT EXISTS idx_profiles_nickname ON profiles(nickname);
CREATE INDEX IF NOT EXISTS idx_rooms_code ON rooms(code);
CREATE INDEX IF NOT EXISTS idx_rooms_status ON rooms(status);
CREATE INDEX IF NOT EXISTS idx_room_players_room ON room_players(room_id);

-- ============================================
-- ✅ SCRIPTS COMPLETADOS
-- ============================================

-- Para verificar que todo se creó correctamente, ejecuta:
-- SELECT * FROM profiles;
-- SELECT * FROM rooms;
-- SELECT * FROM room_players;

