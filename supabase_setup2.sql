CREATE TABLE IF NOT EXISTS "Prueba_n8n".conversaciones (
    id SERIAL PRIMARY KEY,                     -- ID autoincremental
    user_id VARCHAR(50) NOT NULL,              -- ID del usuario de Telegram  
    user_name VARCHAR(100),                    -- Nombre del usuario
    paso_actual VARCHAR(50) DEFAULT 'inicio',  -- Paso actual del proceso
    datos_recopilados JSONB DEFAULT '{}'::jsonb, -- Datos acumulados
    ultimo_mensaje TEXT,                       -- Último mensaje del usuario
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS usuarios_seguros (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(50) NOT NULL,              -- Referencia al usuario de Telegram
    numero_poliza VARCHAR(50),                 -- Número único de póliza (nullable)
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    edad INTEGER,
    telefono VARCHAR(20),
    direccion TEXT,
    email VARCHAR(255),
    condiciones_medicas TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Validaciones opcionales
    CONSTRAINT valid_email CHECK (email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT valid_edad CHECK (edad IS NULL OR (edad >= 18 AND edad <= 80))
);

CREATE INDEX IF NOT EXISTS idx_usuarios_seguros_user_id ON usuarios_seguros(user_id);
CREATE INDEX IF NOT EXISTS idx_usuarios_seguros_numero_poliza ON usuarios_seguros(numero_poliza) WHERE numero_poliza IS NOT NULL;

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_usuarios_seguros_updated_at ON usuarios_seguros;
CREATE TRIGGER update_usuarios_seguros_updated_at 
    BEFORE UPDATE ON usuarios_seguros 
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at();

    ALTER TABLE usuarios_seguros ENABLE ROW LEVEL SECURITY;



commit;