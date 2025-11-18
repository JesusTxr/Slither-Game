-- ============================================
-- SCRIPT PARA MEJORAR EL TRIGGER DE PROFILES
-- Más seguro y compatible con el estándar de Supabase
-- ============================================

-- 1. ELIMINAR TRIGGER Y FUNCIÓN ANTIGUOS
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- ============================================

-- 2. CREAR FUNCIÓN MEJORADA
-- Esta versión es más segura y usa metadata del usuario
CREATE FUNCTION public.handle_new_user()
RETURNS trigger
SET search_path = ''
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.profiles (id, nickname, avatar, created_at, updated_at)
  VALUES (
    new.id,
    COALESCE(
      new.raw_user_meta_data->>'nickname',
      new.raw_user_meta_data->>'full_name',
      split_part(new.email, '@', 1),
      'Player_' || substr(new.id::text, 1, 8)
    ),
    COALESCE(
      new.raw_user_meta_data->>'avatar',
      '🐍'
    ),
    now(),
    now()
  );
  RETURN new;
END;
$$;

-- ============================================

-- 3. CREAR TRIGGER
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================

-- 4. VERIFICAR QUE FUNCIONA
-- Test rápido (ejecuta todo junto)
DO $$
DECLARE
    test_id uuid := gen_random_uuid();
    test_email text := 'test_trigger_' || floor(random() * 1000) || '@test.com';
BEGIN
    -- Crear usuario de prueba
    INSERT INTO auth.users (
        instance_id, id, aud, role, email,
        encrypted_password, email_confirmed_at,
        confirmed_at, created_at, updated_at,
        raw_app_meta_data, raw_user_meta_data
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        test_id, 'authenticated', 'authenticated', test_email,
        crypt('123456', gen_salt('bf')), now(),
        now(), now(), now(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        '{"nickname":"TestUser","avatar":"🎮"}'::jsonb
    );
    
    -- Esperar un momento
    PERFORM pg_sleep(0.1);
    
    -- Verificar resultado
    IF EXISTS (SELECT 1 FROM profiles WHERE id = test_id) THEN
        RAISE NOTICE '✅ TRIGGER FUNCIONA CORRECTAMENTE';
        RAISE NOTICE '   Email: %', test_email;
        RAISE NOTICE '   Nickname: %', (SELECT nickname FROM profiles WHERE id = test_id);
    ELSE
        RAISE NOTICE '❌ TRIGGER NO FUNCIONA';
    END IF;
    
    -- Limpiar
    DELETE FROM auth.users WHERE id = test_id;
END $$;

-- ============================================
-- ✅ COMPLETADO
-- ============================================

-- VERIFICACIÓN FINAL
SELECT 
    trigger_name,
    event_object_table,
    action_timing,
    action_statement
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- Si ves 1 fila = ✅ Trigger existe





