-- ============================================
-- SCRIPT PARA LIMPIAR Y EMPEZAR DE NUEVO
-- ============================================

-- 1️⃣ VER ESTADO ACTUAL
SELECT 
    '=== USUARIOS ===' as info,
    email,
    email_confirmed_at,
    raw_user_meta_data->>'nickname' as metadata_nickname,
    created_at
FROM auth.users
ORDER BY created_at DESC;

SELECT 
    '=== PERFILES ===' as info,
    p.nickname,
    p.avatar,
    u.email,
    p.created_at
FROM profiles p
JOIN auth.users u ON u.id = p.id
ORDER BY p.created_at DESC;

-- ============================================

-- 2️⃣ LIMPIAR TODO (descomenta para ejecutar)
-- DELETE FROM auth.users;

-- O borrar un usuario específico:
-- DELETE FROM auth.users WHERE email = 'chuchito27tm@gmail.com';

-- ============================================

-- 3️⃣ DESPUÉS DE REGISTRARTE, EJECUTA ESTO:

-- Ver tu usuario
SELECT 
    email,
    email_confirmed_at,
    raw_user_meta_data->>'nickname' as metadata_nickname,
    created_at
FROM auth.users
WHERE email = 'chuchito27tm@gmail.com';

-- Ver tu perfil
SELECT 
    p.nickname,
    p.avatar,
    p.created_at,
    p.updated_at,
    u.email
FROM profiles p
JOIN auth.users u ON u.id = p.id
WHERE u.email = 'chuchito27tm@gmail.com';

-- RESULTADO ESPERADO:
-- metadata_nickname: 'JesusTxr'
-- profiles.nickname: 'JesusTxr'
-- email_confirmed_at: [fecha] (no NULL)

-- ============================================
-- ✅ SI TODO SE VE BIEN, ¡FUNCIONA!
-- ============================================





