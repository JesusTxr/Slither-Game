-- ============================================================
-- PASO 1: ELIMINAR TODO LO VIEJO (si existe)
-- ============================================================
DROP TRIGGER IF EXISTS set_updated_at ON public.pagos_tienda;
DROP FUNCTION IF EXISTS public.handle_updated_at CASCADE;
DROP TABLE IF EXISTS public.pagos_tienda CASCADE;
DROP VIEW IF EXISTS public.stats_compras CASCADE;

-- ============================================================
-- PASO 2: CREAR LA TABLA
-- ============================================================
CREATE TABLE public.pagos_tienda (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    email TEXT NOT NULL,
    skin_id TEXT NOT NULL,
    skin_name TEXT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    ultimos_4_digitos TEXT NOT NULL,
    tipo_tarjeta TEXT NOT NULL,
    nombre_titular TEXT NOT NULL,
    estado TEXT DEFAULT 'completado' CHECK (estado IN ('completado', 'pendiente', 'fallido')),
    numero_comprobante TEXT UNIQUE NOT NULL DEFAULT 'COMP-' || to_char(NOW(), 'YYYYMMDD') || '-' || substring(md5(random()::text) from 1 for 8),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- PASO 3: CREAR ÍNDICES
-- ============================================================
CREATE INDEX idx_pagos_user_id ON public.pagos_tienda(user_id);
CREATE INDEX idx_pagos_created_at ON public.pagos_tienda(created_at DESC);
CREATE INDEX idx_pagos_comprobante ON public.pagos_tienda(numero_comprobante);
CREATE INDEX idx_pagos_skin_id ON public.pagos_tienda(skin_id);

-- ============================================================
-- PASO 4: HABILITAR ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE public.pagos_tienda ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- PASO 5: CREAR POLÍTICAS DE SEGURIDAD
-- ============================================================
CREATE POLICY "Los usuarios pueden ver sus propias compras"
    ON public.pagos_tienda
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Los usuarios pueden crear sus propias compras"
    ON public.pagos_tienda
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- PASO 6: CREAR FUNCIÓN PARA UPDATED_AT
-- ============================================================
CREATE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- PASO 7: CREAR TRIGGER
-- ============================================================
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.pagos_tienda
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================
-- PASO 8: CREAR VISTA DE ESTADÍSTICAS
-- ============================================================
CREATE VIEW public.stats_compras AS
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
-- ✅ COMPLETADO
-- ============================================================
-- Verifica que la tabla se creó correctamente:
SELECT 'Tabla creada exitosamente!' as mensaje,
       COUNT(*) as total_columnas
FROM information_schema.columns 
WHERE table_name = 'pagos_tienda';

