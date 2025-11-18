-- ============================================
-- SCRIPT PARA CORREGIR TU CUENTA EXISTENTE
-- ============================================

-- Buscar tu usuario por email y actualizar el nickname
UPDATE profiles
SET 
  nickname = 'JesusTxr',
  updated_at = NOW()
WHERE id = (
  SELECT id 
  FROM auth.users 
  WHERE email = 'chuchito27tm@gmail.com'
);

-- Verificar que se actualizó correctamente
SELECT 
  p.nickname,
  p.avatar,
  u.email,
  p.updated_at
FROM profiles p
JOIN auth.users u ON u.id = p.id
WHERE u.email = 'chuchito27tm@gmail.com';

-- ============================================
-- ✅ Después de ejecutar esto, tu cuenta
--    debería mostrar "JesusTxr" como nickname
-- ============================================




