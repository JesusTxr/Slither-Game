-- ============================================
-- TEST RÁPIDO DE SUPABASE
-- Ejecuta este script completo para diagnosticar el problema
-- ============================================

-- 1️⃣ VER CONFIGURACIÓN ACTUAL
SELECT 
    'Usuarios registrados' as info,
    COUNT(*) as cantidad
FROM auth.users;

SELECT 
    'Perfiles creados' as info,
    COUNT(*) as cantidad
FROM profiles;

SELECT 
    'Trigger activo' as info,
    COUNT(*) as cantidad
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- ============================================

-- 2️⃣ VER SI HAY USUARIOS SIN PERFIL
SELECT 
    u.email,
    u.created_at,
    CASE 
        WHEN p.id IS NULL THEN '❌ SIN PERFIL'
        ELSE '✅ CON PERFIL'
    END as estado
FROM auth.users u
LEFT JOIN profiles p ON u.id = p.id
ORDER BY u.created_at DESC
LIMIT 5;

-- ============================================

-- 3️⃣ LIMPIAR USUARIOS SIN PERFIL (si hay)
-- Descomenta estas líneas si quieres limpiar:
-- DELETE FROM auth.users WHERE id NOT IN (SELECT id FROM profiles);

-- ============================================

-- 4️⃣ TEST: Crear usuario manualmente para verificar trigger
-- IMPORTANTE: Ejecuta SOLO la parte entre BEGIN y COMMIT

DO $$
DECLARE
    new_user_id uuid := gen_random_uuid();
    test_email text := 'test_' || floor(random() * 1000) || '@test.com';
BEGIN
    -- Insertar usuario de prueba
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        confirmed_at,
        created_at,
        updated_at,
        raw_app_meta_data,
        raw_user_meta_data,
        is_super_admin
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        new_user_id,
        'authenticated',
        'authenticated',
        test_email,
        crypt('123456', gen_salt('bf')),
        now(), -- Email ya confirmado
        now(),
        now(),
        now(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        '{}'::jsonb,
        false
    );
    
    -- Verificar si se creó el perfil
    RAISE NOTICE 'Usuario creado: %', test_email;
    RAISE NOTICE 'ID: %', new_user_id;
    
    -- Esperar un momento para que el trigger se ejecute
    PERFORM pg_sleep(0.1);
    
    -- Verificar perfil
    IF EXISTS (SELECT 1 FROM profiles WHERE id = new_user_id) THEN
        RAISE NOTICE '✅ PERFIL CREADO AUTOMÁTICAMENTE';
    ELSE
        RAISE NOTICE '❌ PERFIL NO SE CREÓ - EL TRIGGER NO FUNCIONA';
    END IF;
END $$;

-- ============================================

-- 5️⃣ VER RESULTADO DEL TEST
SELECT 
    u.email,
    p.nickname,
    p.avatar,
    CASE 
        WHEN p.id IS NULL THEN '❌ TRIGGER NO FUNCIONA'
        ELSE '✅ TRIGGER FUNCIONA'
    END as resultado
FROM auth.users u
LEFT JOIN profiles p ON u.id = p.id
WHERE u.email LIKE 'test_%@test.com'
ORDER BY u.created_at DESC
LIMIT 1;

-- ============================================

-- 6️⃣ LIMPIAR TESTS
DELETE FROM auth.users WHERE email LIKE 'test_%@test.com';

-- ============================================
-- ✅ FIN DEL TEST
-- ============================================

-- RESUMEN:
-- Si el trigger funciona, deberías ver "✅ TRIGGER FUNCIONA"
-- Si no funciona, necesitamos recrear el trigger





