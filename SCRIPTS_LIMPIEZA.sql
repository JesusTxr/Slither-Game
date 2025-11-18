-- ============================================
-- SCRIPTS DE LIMPIEZA PARA SUPABASE
-- ============================================

-- 📊 VER ESTADO ACTUAL
-- ============================================

-- 1. Ver todos los usuarios
SELECT 
    email,
    email_confirmed_at,
    created_at,
    CASE 
        WHEN email_confirmed_at IS NULL THEN '❌ No confirmado'
        ELSE '✅ Confirmado'
    END as estado
FROM auth.users
ORDER BY created_at DESC;

-- 2. Ver todos los perfiles
SELECT * FROM profiles ORDER BY created_at DESC;

-- 3. Ver usuarios SIN perfil
SELECT 
    u.email,
    u.created_at,
    CASE 
        WHEN p.id IS NULL THEN '❌ SIN PERFIL'
        ELSE '✅ CON PERFIL'
    END as estado_perfil
FROM auth.users u
LEFT JOIN profiles p ON u.id = p.id
ORDER BY u.created_at DESC;

-- ============================================

-- 🗑️ LIMPIAR DATOS
-- ============================================

-- OPCIÓN A: Borrar solo usuarios no confirmados
DELETE FROM auth.users WHERE email_confirmed_at IS NULL;

-- OPCIÓN B: Borrar un usuario específico
-- DELETE FROM auth.users WHERE email = 'tu_email@gmail.com';

-- OPCIÓN C: Borrar TODOS los usuarios (para empezar desde cero)
-- DELETE FROM auth.users;

-- NOTA: Los perfiles se borran automáticamente por "ON DELETE CASCADE"

-- ============================================

-- ✅ VERIFICAR LIMPIEZA
-- ============================================

-- Ver cuántos usuarios quedan
SELECT 
    'Usuarios totales' as info,
    COUNT(*) as cantidad
FROM auth.users;

-- Ver cuántos perfiles quedan
SELECT 
    'Perfiles totales' as info,
    COUNT(*) as cantidad
FROM profiles;

-- Deberían ser iguales o cero

-- ============================================
-- ✅ LISTO PARA EMPEZAR DE NUEVO
-- ============================================





