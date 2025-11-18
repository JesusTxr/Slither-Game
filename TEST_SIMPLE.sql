-- ============================================
-- TEST SIMPLE DE SUPABASE
-- Ejecuta este script línea por línea
-- ============================================

-- 1️⃣ VER ESTADO ACTUAL
SELECT 'Usuarios en auth.users' as tabla, COUNT(*) as cantidad FROM auth.users
UNION ALL
SELECT 'Perfiles en profiles' as tabla, COUNT(*) as cantidad FROM profiles;

-- ============================================

-- 2️⃣ VER SI EL TRIGGER EXISTE
SELECT 
    trigger_name,
    event_object_table,
    action_timing
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- RESULTADO ESPERADO: Debe aparecer 1 fila con "on_auth_user_created"
-- SI NO APARECE: El trigger no existe, ejecuta SUPABASE_SETUP_CLEAN.sql

-- ============================================

-- 3️⃣ TEST MANUAL: Crear usuario y ver si se crea perfil
-- Ejecuta SOLO este bloque completo

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
    raw_user_meta_data
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'test@test.com',
    crypt('123456', gen_salt('bf')),
    now(),
    now(),
    now(),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb
);

-- ============================================

-- 4️⃣ VER SI SE CREÓ EL PERFIL
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
WHERE u.email = 'test@test.com';

-- RESULTADO ESPERADO: Debe decir "✅ TRIGGER FUNCIONA"

-- ============================================

-- 5️⃣ LIMPIAR TEST
DELETE FROM auth.users WHERE email = 'test@test.com';

-- ============================================
-- ✅ FIN DEL TEST
-- ============================================

-- INTERPRETACIÓN:
-- Si el paso 4 dice "✅ TRIGGER FUNCIONA" = El problema NO es el trigger
-- Si el paso 4 dice "❌ TRIGGER NO FUNCIONA" = Hay que arreglar el trigger





