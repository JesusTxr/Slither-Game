-- ============================================
-- SCRIPT PARA CORREGIR EL PROBLEMA DEL NICKNAME
-- Este script actualiza el trigger para usar el nickname correcto
-- ============================================

-- 🧹 PASO 1: Eliminar el trigger y función antiguos
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- ============================================

-- ⚙️ PASO 2: NUEVA FUNCIÓN que respeta el nickname del metadata
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, nickname, avatar)
  VALUES (
    new.id,
    -- Prioridad:
    -- 1. Nickname de raw_user_meta_data (lo que envía la app)
    -- 2. Si no hay, usar el email sin dominio
    -- 3. Si todo falla, usar 'Player_XXXX'
    COALESCE(
      new.raw_user_meta_data->>'nickname',
      split_part(new.email, '@', 1),
      'Player_' || substr(new.id::text, 1, 8)
    ),
    '🐍'
  )
  ON CONFLICT (id) 
  DO UPDATE SET 
    nickname = COALESCE(
      EXCLUDED.nickname,
      profiles.nickname
    ),
    updated_at = NOW();
  
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================

-- 🎯 PASO 3: Recrear el trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================

-- 🔄 PASO 4: Agregar política para INSERT (por si no existe)
DROP POLICY IF EXISTS "Usuarios pueden crear su perfil" ON profiles;
CREATE POLICY "Usuarios pueden crear su perfil" 
  ON profiles FOR INSERT 
  WITH CHECK (auth.uid() = id);

-- ============================================
-- ✅ ¡COMPLETADO!
-- 
-- Ahora el trigger:
-- 1. Lee el nickname de raw_user_meta_data->>'nickname'
-- 2. Si ya existe un perfil, lo actualiza (ON CONFLICT)
-- 3. Respeta el nickname que envías desde la app
-- ============================================




