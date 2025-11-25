-- ============================================================
-- SCRIPT: SISTEMA DE PAGOS PARA TIENDA DE SKINS
-- ============================================================
-- Este script crea la tabla para registrar las compras de skins
-- en la tienda del juego Slither
-- ============================================================

-- 1. Crear tabla de pagos_tienda
CREATE TABLE IF NOT EXISTS public.pagos_tienda (
    -- Identificador único del pago
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Usuario que realizó la compra (referencia a auth.users)
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    
    -- Email del usuario (para comprobantes)
    email TEXT NOT NULL,
    
    -- Skin comprada
    skin_id TEXT NOT NULL,
    skin_name TEXT NOT NULL,
    
    -- Precio de la compra
    precio DECIMAL(10, 2) NOT NULL,
    
    -- Información de la tarjeta (últimos 4 dígitos para comprobante)
    ultimos_4_digitos TEXT NOT NULL,
    tipo_tarjeta TEXT NOT NULL, -- visa, mastercard, amex
    
    -- Información del titular
    nombre_titular TEXT NOT NULL,
    
    -- Estado del pago
    estado TEXT DEFAULT 'completado' CHECK (estado IN ('completado', 'pendiente', 'fallido')),
    
    -- Número de comprobante único
    numero_comprobante TEXT UNIQUE NOT NULL DEFAULT 'COMP-' || to_char(NOW(), 'YYYYMMDD') || '-' || substring(md5(random()::text) from 1 for 8),
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Crear índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_pagos_user_id ON public.pagos_tienda(user_id);
CREATE INDEX IF NOT EXISTS idx_pagos_created_at ON public.pagos_tienda(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_pagos_comprobante ON public.pagos_tienda(numero_comprobante);
CREATE INDEX IF NOT EXISTS idx_pagos_skin_id ON public.pagos_tienda(skin_id);

-- 3. Habilitar Row Level Security (RLS)
ALTER TABLE public.pagos_tienda ENABLE ROW LEVEL SECURITY;

-- 4. Política: Los usuarios solo pueden ver sus propias compras
DROP POLICY IF EXISTS "Los usuarios pueden ver sus propias compras" ON public.pagos_tienda;
CREATE POLICY "Los usuarios pueden ver sus propias compras"
    ON public.pagos_tienda
    FOR SELECT
    USING (auth.uid() = user_id);

-- 5. Política: Los usuarios pueden insertar sus propias compras
DROP POLICY IF EXISTS "Los usuarios pueden crear sus propias compras" ON public.pagos_tienda;
CREATE POLICY "Los usuarios pueden crear sus propias compras"
    ON public.pagos_tienda
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 6. Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. Trigger para actualizar updated_at
DROP TRIGGER IF EXISTS set_updated_at ON public.pagos_tienda;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.pagos_tienda
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 8. Crear vista para estadísticas de compras (opcional)
CREATE OR REPLACE VIEW public.stats_compras AS
SELECT 
    skin_id,
    skin_name,
    COUNT(*) as total_compras,
    SUM(precio) as ingresos_totales,
    AVG(precio) as precio_promedio
FROM public.pagos_tienda
WHERE estado = 'completado'
GROUP BY skin_id, skin_name
ORDER BY total_compras DESC;

-- ============================================================
-- DATOS DE EJEMPLO (opcional, para testing)
-- ============================================================
-- Descomenta las siguientes líneas si quieres datos de prueba:
/*
INSERT INTO public.pagos_tienda (
    user_id, 
    email, 
    skin_id, 
    skin_name, 
    precio, 
    ultimos_4_digitos, 
    tipo_tarjeta, 
    nombre_titular
) VALUES (
    auth.uid(), -- Reemplaza con tu user_id real
    'test@ejemplo.com',
    'fire',
    'Fuego',
    4.99,
    '1234',
    'visa',
    'Usuario Prueba'
);
*/

-- ============================================================
-- CONSULTAS ÚTILES
-- ============================================================

-- Ver todas las compras de un usuario:
-- SELECT * FROM pagos_tienda WHERE user_id = auth.uid() ORDER BY created_at DESC;

-- Ver comprobante específico:
-- SELECT * FROM pagos_tienda WHERE numero_comprobante = 'COMP-20250101-abcd1234';

-- Ver estadísticas de ventas:
-- SELECT * FROM stats_compras;

-- Ver skins compradas por un usuario:
-- SELECT DISTINCT skin_id, skin_name FROM pagos_tienda WHERE user_id = auth.uid() AND estado = 'completado';

-- ============================================================
-- ✅ SCRIPT COMPLETADO
-- ============================================================
-- Copia y pega TODO este script en:
-- Supabase > SQL Editor > New Query
-- 
-- Luego presiona "RUN" para ejecutarlo.
-- ============================================================

