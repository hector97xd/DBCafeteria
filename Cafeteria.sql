CREATE DATABASE CAFETERIA;

-- Crear tipos personalizados
CREATE TYPE estado_pedido AS ENUM ('Recibido', 'Preparando', 'Listo', 'Entregado','Cancelado');
CREATE TYPE tipo_pago AS ENUM ('Efectivo', 'Tarjeta');

-- Crear tabla categoria
CREATE TABLE IF NOT EXISTS categoria (
  id_categoria UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT UNIQUE NOT NULL,
  es_activo BOOLEAN DEFAULT TRUE,
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ null,
  actualizado_por TEXT
);

-- Crear tabla producto
CREATE TABLE IF NOT EXISTS producto (
  id_producto UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
  url_modelo_3d TEXT,
  calorias INTEGER CHECK (calorias >= 0),
  es_activo BOOLEAN DEFAULT TRUE,
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ null,
  actualizado_por TEXT
);

CREATE TABLE IF NOT EXISTS descuento_producto (
  id_descuento UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_producto UUID REFERENCES producto(id_producto) ON DELETE CASCADE,
  tipo_descuento TEXT NOT NULL CHECK (tipo_descuento IN ('porcentaje', 'monto_fijo')),
  valor DECIMAL(10,2) NOT NULL CHECK (valor >= 0),
  fecha_inicio TIMESTAMPTZ NOT NULL,
  fecha_fin TIMESTAMPTZ NOT NULL,
  es_activo BOOLEAN DEFAULT TRUE,
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  CHECK (fecha_fin > fecha_inicio)
);

CREATE TABLE IF NOT EXISTS producto_categoria (
  id_producto UUID REFERENCES producto(id_producto) ON DELETE CASCADE,
  id_categoria UUID REFERENCES categoria(id_categoria) ON DELETE CASCADE,
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  PRIMARY KEY (id_producto, id_categoria)
);

CREATE TABLE IF NOT EXISTS producto_imagen (
  id_imagen UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_producto UUID REFERENCES producto(id_producto) ON DELETE CASCADE,
  url_imagen TEXT NOT NULL,
  orden SMALLINT NOT NULL CHECK (orden >= 1),
  es_principal BOOLEAN DEFAULT FALSE,
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT
);

-- Crear tabla alergeno
CREATE TABLE IF NOT EXISTS alergeno (
  id_alergeno UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT UNIQUE NOT NULL,
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ null,
  actualizado_por TEXT
);

-- Crear tabla preferencia_dietetica
CREATE TABLE IF NOT EXISTS preferencia_dietetica (
  id_preferencia UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT UNIQUE NOT NULL,
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ null,
  actualizado_por TEXT
);

-- Crear tabla ingrediente
CREATE TABLE IF NOT EXISTS ingrediente (
  id_ingrediente UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT UNIQUE NOT NULL,
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  es_activo BOOLEAN DEFAULT TRUE,
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ null,
  actualizado_por TEXT
);

-- Crear tabla de unión producto_ingrediente
CREATE TABLE IF NOT EXISTS producto_ingrediente (
  id_producto UUID REFERENCES producto(id_producto) ON DELETE CASCADE,
  id_ingrediente UUID REFERENCES ingrediente(id_ingrediente) ON DELETE CASCADE,
  PRIMARY KEY (id_producto, id_ingrediente),
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT
);

-- Crear tabla de unión producto_alergeno
CREATE TABLE IF NOT EXISTS producto_alergeno (
  id_producto UUID REFERENCES producto(id_producto) ON DELETE CASCADE,
  id_alergeno UUID REFERENCES alergeno(id_alergeno) ON DELETE CASCADE,
  PRIMARY KEY (id_producto, id_alergeno),
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT
);

-- Crear tabla de unión producto_preferencia_dietetica
CREATE TABLE IF NOT EXISTS producto_preferencia_dietetica (
  id_producto UUID REFERENCES producto(id_producto) ON DELETE CASCADE,
  id_preferencia UUID REFERENCES preferencia_dietetica(id_preferencia) ON DELETE CASCADE,
  PRIMARY KEY (id_producto, id_preferencia),
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT
);

-- Tabla intermedia para alergenos de usuario
CREATE TABLE IF NOT EXISTS usuario_alergeno (
  id_usuario UUID NOT NULL,
  id_alergeno UUID REFERENCES alergeno(id_alergeno) ON DELETE CASCADE,
  PRIMARY KEY (id_usuario, id_alergeno),
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT
);

-- Tabla intermedia para preferencias dietéticas de usuario
CREATE TABLE IF NOT EXISTS usuario_preferencia_dietetica (
  id_usuario UUID NOT NULL,
  id_preferencia UUID REFERENCES preferencia_dietetica(id_preferencia) ON DELETE CASCADE,
  PRIMARY KEY (id_usuario, id_preferencia),
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT
);


-- Crear tabla pedido
CREATE TABLE IF NOT EXISTS pedido (
  id_pedido UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_usuario UUID NOT NULL,
  metodo_pago tipo_pago NOT NULL,
  numero_pedido BIGINT NOT NULL,,
  total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
  total_con_descuento DECIMAL(10,2) CHECK (total_con_descuento >= 0),
  fecha_recibido TIMESTAMPTZ,
  tiempo_estimado_entrega TIMESTAMPTZ,
  fecha_entrega TIMESTAMPTZ,
  tiempo_real_preparacion_minutos numeric, 
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ null,
  actualizado_por TEXT
);

-- Crear tabla detalle_pedido
CREATE TABLE IF NOT EXISTS detalle_pedido (
  id_detalle UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_pedido UUID REFERENCES pedido(id_pedido) ON DELETE CASCADE NOT NULL,
  id_producto UUID REFERENCES producto(id_producto) ON DELETE SET NULL NOT NULL,
  cantidad INTEGER NOT NULL CHECK (cantidad > 0),
  precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario >= 0),
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ DEFAULT now(),
  actualizado_por TEXT
);

-- Crear tabla cupon
CREATE TABLE IF NOT EXISTS cupon (
  id_cupon UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo TEXT UNIQUE NOT NULL,
  descuento DECIMAL(10,2) NOT NULL CHECK (descuento >= 0),
  tipo_descuento TEXT CHECK (tipo_descuento IN ('fijo', 'porcentaje')) NOT NULL,
  fecha_expiracion TIMESTAMPTZ NOT NULL,
  limite_uso INTEGER CHECK (limite_uso >= 0),
  es_activo BOOLEAN DEFAULT TRUE,
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ null,
  actualizado_por TEXT
);

-- Crear tabla de unión pedido_cupon
CREATE TABLE IF NOT EXISTS pedido_cupon (
  id_pedido_cupon UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_pedido UUID REFERENCES pedido(id_pedido) ON DELETE CASCADE NOT NULL,
  id_cupon UUID REFERENCES cupon(id_cupon) ON DELETE CASCADE NOT NULL,
  tipo_descuento TEXT CHECK (tipo_descuento IN ('fijo', 'porcentaje')) NOT NULL,
  descuento_aplicado DECIMAL(10,2) NOT NULL CHECK (descuento_aplicado >= 0),
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT
);

-- Crear tabla historial_estado_pedido
CREATE TABLE IF NOT EXISTS historial_estado_pedido (
  id_historial UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_pedido UUID REFERENCES pedido(id_pedido) ON DELETE CASCADE NOT NULL,
  estado estado_pedido NOT NULL,
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT
);


-- Función para actualizar fecha_actualizacion
CREATE OR REPLACE FUNCTION actualizar_fecha_actualizacion()
RETURNS TRIGGER AS $$
BEGIN
  NEW.fecha_actualizacion = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para actualizar fecha_actualizacion
CREATE TRIGGER actualizar_producto
  BEFORE UPDATE ON producto
  FOR EACH ROW
  EXECUTE FUNCTION actualizar_fecha_actualizacion();

CREATE TRIGGER actualizar_pedido
  BEFORE UPDATE ON pedido
  FOR EACH ROW
  EXECUTE FUNCTION actualizar_fecha_actualizacion();

-- Creamos una secuencia para generar números de pedido únicos
CREATE SEQUENCE pedido_numero_seq START 1;

-- Actualizamos los pedidos existentes (opcional)
UPDATE pedido 
SET numero_pedido = nextval('pedido_numero_seq')
WHERE numero_pedido IS NULL;

-- Creamos un trigger para asignar automáticamente el número de pedido
CREATE OR REPLACE FUNCTION asignar_numero_pedido()
RETURNS TRIGGER AS $$
BEGIN
    NEW.numero_pedido := nextval('pedido_numero_seq');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_asignar_numero_pedido
BEFORE INSERT ON pedido
FOR EACH ROW
EXECUTE FUNCTION asignar_numero_pedido();


 -- Valores unicos
ALTER TABLE alergeno ADD CONSTRAINT alergeno_nombre_unique UNIQUE (nombre);
ALTER TABLE preferencia_dietetica ADD CONSTRAINT preferencia_nombre_unique UNIQUE (nombre);
ALTER TABLE categoria ADD CONSTRAINT categoria_nombre_unique UNIQUE (nombre);
ALTER TABLE ingrediente ADD CONSTRAINT ingrediente_nombre_unique UNIQUE (nombre);
ALTER TABLE producto ADD CONSTRAINT producto_nombre_unique UNIQUE (nombre);

CREATE INDEX idx_pedido_usuario ON pedido(id_usuario);
CREATE INDEX idx_detalle_pedido_pedido ON detalle_pedido(id_pedido);
CREATE INDEX idx_detalle_pedido_producto ON detalle_pedido(id_producto);
CREATE INDEX idx_historial_pedido ON historial_estado_pedido(id_pedido);
CREATE INDEX idx_prod_cat_categoria ON producto_categoria(id_categoria);
CREATE INDEX idx_producto_activo ON producto(es_activo) WHERE es_activo = TRUE;
CREATE INDEX idx_producto_nombre ON producto(nombre);
CREATE INDEX idx_producto_precio ON producto(precio);
CREATE INDEX idx_historial_estado ON historial_estado_pedido(estado);
CREATE INDEX idx_historial_fecha ON historial_estado_pedido(fecha_creacion);

CREATE INDEX idx_descuento_producto_completo ON descuento_producto(id_producto, fecha_inicio, fecha_fin) WHERE es_activo = TRUE;
CREATE INDEX idx_producto_categoria_producto ON producto_categoria(id_producto);
CREATE INDEX idx_producto_ingrediente_producto ON producto_ingrediente(id_producto);
CREATE INDEX idx_producto_alergeno_producto ON producto_alergeno(id_producto);
CREATE INDEX idx_producto_preferencia_producto ON producto_preferencia_dietetica(id_producto);
CREATE INDEX idx_producto_imagen_producto ON producto_imagen(id_producto);

-- INSERTS
-- Insertar alergenos (ajustado con campos de auditoría completos)
INSERT INTO alergeno (nombre, creado_por, fecha_creacion, fecha_actualizacion, actualizado_por) 
VALUES 
('Leche', 'hector.guevara', now(), null, null),
('Huevos', 'hector.guevara', now(), null, null),
('Pescado', 'hector.guevara', now(), null, null),
('Crustáceos', 'hector.guevara', now(), null, null),
('Frutos secos', 'hector.guevara', now(), null, null),
('Cacahuetes', 'hector.guevara', now(), null, null),
('Trigo', 'hector.guevara', now(), null, null),
('Soja', 'hector.guevara', now(), null, null),
('Sésamo', 'hector.guevara', now(), null, null),
('Mostaza', 'hector.guevara', now(), null, null),
('Apio', 'hector.guevara', now(), null, null),
('Dióxido de azufre y sulfitos', 'hector.guevara', now(), null, null),
('Altramuces', 'hector.guevara', now(), null, null),
('Moluscos', 'hector.guevara', now(), null, null),
('Gluten', 'hector.guevara', now(), null, null),
('Mariscos', 'hector.guevara', now(), null, null),
('Nueces de árbol', 'hector.guevara', now(), null, null),
('Anacardos', 'hector.guevara', now(), null, null),
('Avellanas', 'hector.guevara', now(), null, null),
('Nueces', 'hector.guevara', now(), null, null),
('Piñones', 'hector.guevara', now(), null, null),
('Pistachos', 'hector.guevara', now(), null, null),
('Almendras', 'hector.guevara', now(), null, null),
('Kiwi', 'hector.guevara', now(), null, null),
('Melocotón', 'hector.guevara', now(), null, null),
('Fresa', 'hector.guevara', now(), null, null),
('Tomate', 'hector.guevara', now(), null, null),
('Maíz', 'hector.guevara', now(), null, null),
('Ajo', 'hector.guevara', now(), null, null),
('Cacao', 'hector.guevara', now(), null, null),
('Canela', 'hector.guevara', now(), null, null),
('Colorantes artificiales', 'hector.guevara', now(), null, null),
('Conservantes alimentarios', 'hector.guevara', now(), null, null);

-- Insertar preferencias dietéticas (ajustado con campos de auditoría completos)
INSERT INTO preferencia_dietetica (nombre, creado_por, fecha_creacion, fecha_actualizacion, actualizado_por) 
VALUES 
('Alto en fibra', 'hector.guevara', now(), null, null),
('Alto en proteína', 'hector.guevara', now(), null, null),
('Bajo en carbohidratos', 'hector.guevara', now(), null, null),
('Sin gluten', 'hector.guevara', now(), null, null),
('Vegano', 'hector.guevara', now(), null, null),
('Vegetariano', 'hector.guevara', now(), null, null),
('Keto', 'hector.guevara', now(), null, null),
('Paleo', 'hector.guevara', now(), null, null),
('Bajo en grasas', 'hector.guevara', now(), null, null),
('Bajo en sodio', 'hector.guevara', now(), null, null),
('Sin lácteos', 'hector.guevara', now(), null, null),
('Sin azúcar', 'hector.guevara', now(), null, null),
('Sin nueces', 'hector.guevara', now(), null, null),
('Pescetariano', 'hector.guevara', now(), null, null),
('Crudivegano', 'hector.guevara', now(), null, null),
('Flexitariano', 'hector.guevara', now(), null, null),
('Halal', 'hector.guevara', now(), null, null),
('Kosher', 'hector.guevara', now(), null, null),
('Sin mariscos', 'hector.guevara', now(), null, null),
('Sin huevo', 'hector.guevara', now(), null, null),
('Sin soja', 'hector.guevara', now(), null, null),
('Mediterráneo', 'hector.guevara', now(), null, null),
('Whole30', 'hector.guevara', now(), null, null);

-- Insertar categorías (ajustado con campos de auditoría y es_activo)
INSERT INTO categoria (nombre, es_activo, creado_por, fecha_creacion, fecha_actualizacion, actualizado_por) 
VALUES 
('Café', true, 'hector.guevara', now(), null, null),
('Bebidas frías', true, 'hector.guevara', now(), null, null),
('Pasteles', true, 'hector.guevara', now(), null, null),
('Sándwiches', true, 'hector.guevara', now(), null, null),
('Ensaladas', true, 'hector.guevara', now(), null, null),
('Desayunos', true, 'hector.guevara', now(), null, null),
('Postres', true, 'hector.guevara', now(), null, null),
('Comidas rápidas', true, 'hector.guevara', now(), null, null),
('Promociones', true, 'hector.guevara', now(), null, null)
ON CONFLICT (nombre) DO NOTHING;

-- Insertar ingredientes (ajustado con campos completos)
INSERT INTO ingrediente (nombre, es_activo, creado_por, fecha_creacion, fecha_actualizacion, actualizado_por) 
VALUES 
('Café', true, 'hector.guevara', now(), null, null),
('Leche', true, 'hector.guevara', now(), null, null),
('Azúcar', true, 'hector.guevara', now(), null, null),
('Harina de trigo', true, 'hector.guevara', now(), null, null),
('Huevos', true, 'hector.guevara', now(), null, null),
('Mantequilla', true, 'hector.guevara', now(), null, null),
('Chocolate', true, 'hector.guevara', now(), null, null),
('Nata', true, 'hector.guevara', now(), null, null),
('Queso', true, 'hector.guevara', now(), null, null),
('Jamón', true, 'hector.guevara', now(), null, null),
('Lechuga', true, 'hector.guevara', now(), null, null),
('Tomate', true, 'hector.guevara', now(), null, null),
('Pan', true, 'hector.guevara', now(), null, null),
('Pollo', true, 'hector.guevara', now(), null, null),
('Fresas', true, 'hector.guevara', now(), null, null)
ON CONFLICT (nombre) DO NOTHING;

-- Insertar productos básicos
INSERT INTO producto (
  nombre, 
  descripcion, 
  precio, 
  url_modelo_3d, 
  calorias, 
  creado_por
) VALUES 
('Café Latte', 'Espresso con leche cremosa al vapor', 3.50, '', 120, 'hector.guevara'),
('Tarta de Chocolate', 'Deliciosa tarta con ganache de chocolate negro', 4.95, '', 350, 'hector.guevara')
ON CONFLICT (nombre) DO NOTHING;

-- Insertar productos adicionales (bebidas, comidas, etc.)
INSERT INTO producto (
  nombre, 
  descripcion, 
  precio, 
  url_modelo_3d, 
  calorias, 
  creado_por
) VALUES 
('Botella de Vino Tinto', 'Vino tinto reserva de la región de Rioja', 12.99, 'https://sketchfab.com/models/5d8f0b3e3b7d4a5d8b0b3e3b7d4a5d8', 625, 'hector.guevara'),
('Lata de Refresco', 'Refresco de cola en lata 330ml', 0.90, 'https://sketchfab.com/models/7d8f0b3e3b7d4a5d8b0b3e3b7d4a5d8', 139, 'hector.guevara'),
('Café Americano', 'Café negro preparado con granos arábica', 2.50, NULL, 5, 'hector.guevara'),
('Capuchino Clásico', 'Café espresso con leche vaporizada y espuma', 3.75, NULL, 120, 'hector.guevara'),
('Croissant de Mantequilla', 'Croissant artesanal con mantequilla francesa', 2.80, NULL, 310, 'hector.guevara'),
('Sándwich de Pollo', 'Pechuga de pollo a la parrilla con vegetales frescos', 5.99, NULL, 350, 'hector.guevara'),
('Bagel con Salmón', 'Bagel integral con salmón ahumado y queso crema', 6.25, NULL, 420, 'hector.guevara'),
('Ensalada César', 'Lechuga romana, croutons, parmesano y aderezo césar', 7.50, NULL, 320, 'hector.guevara'),
('Ensalada de Quinoa', 'Quinoa, aguacate, tomate cherry y aderezo de limón', 8.25, NULL, 280, 'hector.guevara'),
('Tostadas Francesas', 'Pan brioche con canela y jarabe de arce', 5.50, NULL, 380, 'hector.guevara'),
('Omelette Vegetariano', 'Huevos con espinacas, champiñones y queso de cabra', 6.75, NULL, 290, 'hector.guevara'),
('Cheesecake de Frutos Rojos', 'Cheesecake cremoso con coulis de frutos rojos', 4.95, NULL, 510, 'hector.guevara'),
('Mousse de Chocolate', 'Postre ligero de chocolate negro 70% cacao', 3.99, NULL, 320, 'hector.guevara'),
('Hamburguesa Clásica', 'Carne 100% res, queso cheddar y vegetales frescos', 7.99, NULL, 550, 'hector.guevara');

-- Insertar promociones (nota: las imágenes van en producto_imagen)
INSERT INTO producto (
  nombre, 
  descripcion, 
  precio, 
  calorias, 
  creado_por
) VALUES 
('Combo Desayuno Completo', 'Incluye café americano, tostadas francesas y jugo de naranja natural. Ahorra $2.50 con este combo especial.', 8.99, 650, 'hector.guevara'),
('Almuerzo Ejecutivo', 'Sándwich de pollo + ensalada César + refresco o café. Precio especial para horas de almuerzo (11am-3pm).', 10.50, 850, 'hector.guevara');

-- Relacionar productos con categorías
INSERT INTO producto_categoria (id_producto, id_categoria, creado_por)
SELECT 
    p.id_producto, 
    c.id_categoria, 
    'hector.guevara'
FROM producto p
CROSS JOIN categoria c
WHERE 
    -- Café y bebidas
    (p.nombre = 'Café Latte' AND c.nombre = 'Café') OR
    (p.nombre = 'Café Americano' AND c.nombre = 'Café') OR
    (p.nombre = 'Capuchino Clásico' AND c.nombre = 'Café') OR
    (p.nombre = 'Botella de Vino Tinto' AND c.nombre = 'Bebidas frías') OR
    (p.nombre = 'Lata de Refresco' AND c.nombre = 'Bebidas frías') OR
    
    -- Pasteles y postres
    (p.nombre = 'Tarta de Chocolate' AND c.nombre = 'Pasteles') OR
    (p.nombre = 'Croissant de Mantequilla' AND c.nombre = 'Pasteles') OR
    (p.nombre = 'Cheesecake de Frutos Rojos' AND c.nombre = 'Postres') OR
    (p.nombre = 'Mousse de Chocolate' AND c.nombre = 'Postres') OR
    
    -- Sándwiches y comidas rápidas
    (p.nombre = 'Sándwich de Pollo' AND c.nombre = 'Sándwiches') OR
    (p.nombre = 'Bagel con Salmón' AND c.nombre = 'Sándwiches') OR
    (p.nombre = 'Hamburguesa Clásica' AND c.nombre = 'Comidas rápidas') OR
    
    -- Ensaladas
    (p.nombre = 'Ensalada César' AND c.nombre = 'Ensaladas') OR
    (p.nombre = 'Ensalada de Quinoa' AND c.nombre = 'Ensaladas') OR
    
    -- Desayunos
    (p.nombre = 'Tostadas Francesas' AND c.nombre = 'Desayunos') OR
    (p.nombre = 'Omelette Vegetariano' AND c.nombre = 'Desayunos') OR
    
    -- Promociones
    (p.nombre = 'Combo Desayuno Completo' AND c.nombre = 'Promociones') OR
    (p.nombre = 'Almuerzo Ejecutivo' AND c.nombre = 'Promociones')
ON CONFLICT (id_producto, id_categoria) DO NOTHING;

-- Relacionar ingredientes con productos
INSERT INTO producto_ingrediente (id_producto, id_ingrediente, creado_por)
SELECT 
    p.id_producto, 
    i.id_ingrediente, 
    'hector.guevara'
FROM producto p
CROSS JOIN ingrediente i
WHERE 
    (p.nombre = 'Café Latte' AND i.nombre IN ('Café', 'Leche')) OR
    (p.nombre = 'Tarta de Chocolate' AND i.nombre IN ('Harina de trigo', 'Huevos', 'Mantequilla', 'Chocolate')) OR
    (p.nombre = 'Sándwich de Pollo' AND i.nombre IN ('Pan', 'Pollo', 'Lechuga', 'Tomate')) OR
    (p.nombre = 'Ensalada César' AND i.nombre IN ('Lechuga', 'Queso', 'Pan')) OR
    (p.nombre = 'Cheesecake de Frutos Rojos' AND i.nombre IN ('Queso', 'Fresas', 'Nata'))
ON CONFLICT (id_producto, id_ingrediente) DO NOTHING;

-- Relacionar alergenos con productos
INSERT INTO producto_alergeno (id_producto, id_alergeno, creado_por)
SELECT 
    p.id_producto, 
    a.id_alergeno, 
    'hector.guevara'
FROM producto p
CROSS JOIN alergeno a
WHERE 
    (p.nombre = 'Café Latte' AND a.nombre IN ('Leche')) OR
    (p.nombre = 'Tarta de Chocolate' AND a.nombre IN ('Huevos', 'Gluten', 'Leche')) OR
    (p.nombre = 'Sándwich de Pollo' AND a.nombre IN ('Gluten')) OR
    (p.nombre = 'Bagel con Salmón' AND a.nombre IN ('Gluten', 'Pescado')) OR
    (p.nombre = 'Cheesecake de Frutos Rojos' AND a.nombre IN ('Leche', 'Huevos'))
ON CONFLICT (id_producto, id_alergeno) DO NOTHING;

-- Relacionar preferencias dietéticas con productos
INSERT INTO producto_preferencia_dietetica (id_producto, id_preferencia, creado_por)
SELECT 
    p.id_producto, 
    pd.id_preferencia, 
    'hector.guevara'
FROM producto p
CROSS JOIN preferencia_dietetica pd
WHERE 
    (p.nombre = 'Ensalada de Quinoa' AND pd.nombre IN ('Vegano', 'Vegetariano', 'Sin gluten')) OR
    (p.nombre = 'Omelette Vegetariano' AND pd.nombre IN ('Vegetariano', 'Alto en proteína')) OR
    (p.nombre = 'Tarta de Chocolate' AND pd.nombre IN ('Vegetariano')) OR
    (p.nombre = 'Ensalada César' AND pd.nombre IN ('Bajo en carbohidratos'))
ON CONFLICT (id_producto, id_preferencia) DO NOTHING;

-- Imágenes para productos principales
INSERT INTO producto_imagen (
  id_producto, 
  url_imagen, 
  orden, 
  es_principal, 
  creado_por
)
SELECT 
  p.id_producto, 
  CASE 
    WHEN p.nombre = 'Café Latte' THEN 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5'
    WHEN p.nombre = 'Tarta de Chocolate' THEN 'https://images.unsplash.com/photo-1578985545062-69928b1d9587'
    WHEN p.nombre = 'Botella de Vino Tinto' THEN 'https://images.unsplash.com/photo-1558160074-4d7d8bdf4256'
    WHEN p.nombre = 'Lata de Refresco' THEN 'https://images.unsplash.com/photo-1554866585-cd94860890b7'
    WHEN p.nombre = 'Café Americano' THEN 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0'
    WHEN p.nombre = 'Capuchino Clásico' THEN 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5'
    WHEN p.nombre = 'Croissant de Mantequilla' THEN 'https://images.unsplash.com/photo-1567945716310-4745a0b56053'
    WHEN p.nombre = 'Sándwich de Pollo' THEN 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af'
    WHEN p.nombre = 'Bagel con Salmón' THEN 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b'
    WHEN p.nombre = 'Ensalada César' THEN 'https://images.unsplash.com/photo-1546793665-c74683f339c1'
    WHEN p.nombre = 'Ensalada de Quinoa' THEN 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd'
    WHEN p.nombre = 'Tostadas Francesas' THEN 'https://images.unsplash.com/photo-1484723091739-30a097e8f929'
    WHEN p.nombre = 'Omelette Vegetariano' THEN 'https://images.unsplash.com/photo-1551782450-a2132b4ba21d'
    WHEN p.nombre = 'Cheesecake de Frutos Rojos' THEN 'https://images.unsplash.com/photo-1578775887804-699de5079aef'
    WHEN p.nombre = 'Mousse de Chocolate' THEN 'https://images.unsplash.com/photo-1563805042-7684c019e1cb'
    WHEN p.nombre = 'Hamburguesa Clásica' THEN 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd'
  END,
  1, 
  TRUE, 
  'hector.guevara'
FROM producto p
WHERE p.nombre IN (
  'Café Latte', 'Tarta de Chocolate', 'Botella de Vino Tinto', 'Lata de Refresco',
  'Café Americano', 'Capuchino Clásico', 'Croissant de Mantequilla', 'Sándwich de Pollo',
  'Bagel con Salmón', 'Ensalada César', 'Ensalada de Quinoa', 'Tostadas Francesas',
  'Omelette Vegetariano', 'Cheesecake de Frutos Rojos', 'Mousse de Chocolate', 'Hamburguesa Clásica'
);

-- Imágenes secundarias (ejemplo para algunos productos)
INSERT INTO producto_imagen (
  id_producto, 
  url_imagen, 
  orden, 
  es_principal, 
  creado_por
)
SELECT 
  p.id_producto, 
  CASE 
    WHEN p.nombre = 'Café Latte' THEN 'https://images.unsplash.com/photo-1445116572660-236099ec97a0'
    WHEN p.nombre = 'Tarta de Chocolate' THEN 'https://images.unsplash.com/photo-1571115177098-24ec42ed204d'
    WHEN p.nombre = 'Hamburguesa Clásica' THEN 'https://images.unsplash.com/photo-1582196016295-f8c10f4320ba'
  END,
  2, 
  FALSE, 
  'hector.guevara'
FROM producto p
WHERE p.nombre IN ('Café Latte', 'Tarta de Chocolate', 'Hamburguesa Clásica');


-- Relacionar ingredientes con productos
INSERT INTO producto_ingrediente (id_producto, id_ingrediente, creado_por)
SELECT 
  p.id_producto, 
  i.id_ingrediente, 
  'hector.guevara'
FROM producto p
CROSS JOIN ingrediente i
WHERE (p.nombre = 'Café Latte' AND i.nombre IN ('Café', 'Leche'))
   OR (p.nombre = 'Tarta de Chocolate' AND i.nombre IN ('Harina de trigo', 'Huevos', 'Mantequilla', 'Chocolate'))
   OR (p.nombre = 'Sándwich de Pollo' AND i.nombre IN ('Pan', 'Pollo', 'Lechuga', 'Tomate'))
   OR (p.nombre = 'Ensalada César' AND i.nombre IN ('Lechuga', 'Queso', 'Pan'))
   OR (p.nombre = 'Cheesecake de Frutos Rojos' AND i.nombre IN ('Queso', 'Fresas', 'Nata'))
ON CONFLICT (id_producto, id_ingrediente) DO NOTHING;

-- Relacionar alergenos con productos
INSERT INTO producto_alergeno (id_producto, id_alergeno, creado_por)
SELECT 
  p.id_producto, 
  a.id_alergeno, 
  'hector.guevara'
FROM producto p
CROSS JOIN alergeno a
WHERE (p.nombre = 'Café Latte' AND a.nombre IN ('Leche'))
   OR (p.nombre = 'Tarta de Chocolate' AND a.nombre IN ('Huevos', 'Gluten', 'Leche'))
   OR (p.nombre = 'Sándwich de Pollo' AND a.nombre IN ('Gluten'))
   OR (p.nombre = 'Bagel con Salmón' AND a.nombre IN ('Gluten', 'Pescado'))
   OR (p.nombre = 'Cheesecake de Frutos Rojos' AND a.nombre IN ('Leche', 'Huevos'))
ON CONFLICT (id_producto, id_alergeno) DO NOTHING;

-- Relacionar preferencias dietéticas con productos
INSERT INTO producto_preferencia_dietetica (id_producto, id_preferencia, creado_por)
SELECT 
  p.id_producto, 
  pd.id_preferencia, 
  'hector.guevara'
FROM producto p
CROSS JOIN preferencia_dietetica pd
WHERE (p.nombre = 'Ensalada de Quinoa' AND pd.nombre IN ('Vegano', 'Vegetariano', 'Sin gluten'))
   OR (p.nombre = 'Omelette Vegetariano' AND pd.nombre IN ('Vegetariano', 'Alto en proteína'))
   OR (p.nombre = 'Tarta de Chocolate' AND pd.nombre IN ('Vegetariano'))
   OR (p.nombre = 'Ensalada César' AND pd.nombre IN ('Bajo en carbohidratos'))
ON CONFLICT (id_producto, id_preferencia) DO NOTHING;

-- Descuentos para productos específicos
INSERT INTO descuento_producto (
  id_producto,
  tipo_descuento,
  valor,
  fecha_inicio,
  fecha_fin,
  creado_por
)
SELECT 
  p.id_producto,
  CASE 
    WHEN p.nombre = 'Café Americano' THEN 'porcentaje'
    ELSE 'monto_fijo'
  END,
  CASE 
    WHEN p.nombre = 'Café Americano' THEN 15.00 -- 15% de descuento
    WHEN p.nombre = 'Tarta de Chocolate' THEN 1.00 -- $1 de descuento
    WHEN p.nombre = 'Sándwich de Pollo' THEN 0.75 -- $0.75 de descuento
  END,
  CURRENT_DATE,
  CURRENT_DATE + INTERVAL '30 days',
  'hector.guevara'
FROM producto p
WHERE p.nombre IN ('Café Americano', 'Tarta de Chocolate', 'Sándwich de Pollo');

-- Insertar cupones de descuento
INSERT INTO cupon (
  codigo,
  descuento,
  tipo_descuento,
  fecha_expiracion,
  limite_uso,
  creado_por
) VALUES 
('VERANO2023', 10.00, 'porcentaje', CURRENT_DATE + INTERVAL '60 days', 100, 'hector.guevara'),
('BIENVENIDA', 5.00, 'monto_fijo', CURRENT_DATE + INTERVAL '90 days', NULL, 'hector.guevara');

-- Aplicar cupón a un pedido
INSERT INTO pedido_cupon (
  id_pedido,
  id_cupon,
  tipo_descuento,
  descuento_aplicado,
  creado_por
)
SELECT 
  p.id_pedido,
  c.id_cupon,
  c.tipo_descuento,
  CASE 
    WHEN c.tipo_descuento = 'porcentaje' THEN (p.total * c.descuento / 100)
    ELSE c.descuento
  END,
  'hector.guevara'
FROM pedido p
CROSS JOIN cupon c
WHERE p.id_pedido = 'id-del-primer-pedido' AND c.codigo = 'VERANO2023';


-- Insertar historial de estados para pedidos
INSERT INTO historial_estado_pedido (
  id_pedido,
  estado,
  creado_por
)
SELECT 
  p.id_pedido,
  CASE 
    WHEN p.id_pedido = 'id-del-primer-pedido' THEN 'Completado'::estado_pedido
    ELSE 'Recibido'::estado_pedido
  END,
  'hector.guevara'
FROM pedido p
WHERE p.id_pedido IN ('id-del-primer-pedido', 'id-del-segundo-pedido');

-- Agregar cambio de estado adicional
INSERT INTO historial_estado_pedido (
  id_pedido,
  estado,
  creado_por
) VALUES 
('id-del-primer-pedido', 'Preparando', 'hector.guevara'),
('id-del-primer-pedido', 'Listo', 'hector.guevara');





drop FUNCTION obtener_productos_con_relaciones

CREATE OR REPLACE FUNCTION obtener_productos_con_relaciones(
    p_id_producto UUID DEFAULT NULL,
    p_nombre_producto TEXT DEFAULT NULL,
    p_activo BOOLEAN DEFAULT NULL,
    p_id_categoria UUID DEFAULT NULL
)
RETURNS TABLE (
    "IdProducto" UUID,
    "Nombre" TEXT,
    "Descripcion" TEXT,
    "Precio" DECIMAL(10,2),
    "PrecioConDescuento" DECIMAL(10,2),
    "UrlModelo3D" TEXT,
    "Calorias" INTEGER,
    "EsActivo" BOOLEAN,
    "FechaCreacion" TIMESTAMPTZ,
    "Categorias" TEXT,
    "Ingredientes" TEXT,
    "Alergenos" TEXT,
    "PreferenciasDieteticas" TEXT,
    "Descuentos" JSON,
    "Imagenes" JSON
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id_producto AS "IdProducto",
        p.nombre AS "Nombre",
        p.descripcion AS "Descripcion",
        p.precio AS "Precio",
        -- Calcular precio con descuento
        COALESCE(
            (SELECT 
                CASE 
                    WHEN dp.tipo_descuento = 'porcentaje' THEN 
                        p.precio * (1 - dp.valor/100)
                    WHEN dp.tipo_descuento = 'monto_fijo' THEN 
                        GREATEST(p.precio - dp.valor, 0)
                    ELSE p.precio
                END
            FROM descuento_producto dp
            WHERE dp.id_producto = p.id_producto
            AND dp.es_activo = TRUE
            AND CURRENT_TIMESTAMP BETWEEN dp.fecha_inicio AND dp.fecha_fin
            LIMIT 1),
            p.precio
        ) AS "PrecioConDescuento",
        
        p.url_modelo_3d AS "UrlModelo3D",
        p.calorias AS "Calorias",
        p.es_activo AS "EsActivo",
        p.fecha_creacion AS "FechaCreacion",
        
        -- Categorías
        (
            SELECT string_agg(c.nombre, ', ')
            FROM producto_categoria pc
            JOIN categoria c ON pc.id_categoria = c.id_categoria
            WHERE pc.id_producto = p.id_producto
        ) AS "Categorias",
        
        -- Ingredientes
        (
            SELECT string_agg(i.nombre, ', ')
            FROM producto_ingrediente pi
            JOIN ingrediente i ON pi.id_ingrediente = i.id_ingrediente
            WHERE pi.id_producto = p.id_producto
        ) AS "Ingredientes",
        
        -- Alérgenos
        (
            SELECT string_agg(a.nombre, ', ')
            FROM producto_alergeno pa
            JOIN alergeno a ON pa.id_alergeno = a.id_alergeno
            WHERE pa.id_producto = p.id_producto
        ) AS "Alergenos",
        
        -- Preferencias dietéticas
        (
            SELECT string_agg(pd.nombre, ', ')
            FROM producto_preferencia_dietetica ppd
            JOIN preferencia_dietetica pd ON ppd.id_preferencia = pd.id_preferencia
            WHERE ppd.id_producto = p.id_producto
        ) AS "PreferenciasDieteticas",
        
        -- Descuentos activos
        (
            SELECT json_agg(json_build_object(
                'tipo', dp.tipo_descuento,
                'valor', dp.valor,
                'fecha_inicio', dp.fecha_inicio,
                'fecha_fin', dp.fecha_fin
            ))
            FROM descuento_producto dp
            WHERE dp.id_producto = p.id_producto
            AND dp.es_activo = TRUE
            AND CURRENT_TIMESTAMP BETWEEN dp.fecha_inicio AND dp.fecha_fin
        )::JSON AS "Descuentos",
        
        -- Imágenes
        (
            SELECT json_agg(json_build_object(
                'url', pi.url_imagen,
                'orden', pi.orden,
                'es_principal', pi.es_principal
            ) ORDER BY pi.orden)
            FROM producto_imagen pi
            WHERE pi.id_producto = p.id_producto
        )::JSON AS "Imagenes"
        
    FROM producto p
    LEFT JOIN producto_categoria pc ON p.id_producto = pc.id_producto
    WHERE 
        (p_id_producto IS NULL OR p.id_producto = p_id_producto)
        AND (p_nombre_producto IS NULL OR p.nombre ILIKE '%' || p_nombre_producto || '%')
        AND (p_activo IS NULL OR p.es_activo = p_activo)
        AND (p_id_categoria IS NULL OR pc.id_categoria = p_id_categoria)
    GROUP BY p.id_producto, p.nombre, p.descripcion, p.precio, p.url_modelo_3d, p.calorias, p.es_activo, p.fecha_creacion
    ORDER BY p.nombre;
END;
$$ LANGUAGE plpgsql;

--V2
CREATE OR REPLACE FUNCTION obtener_productos_con_relaciones(
    p_id_producto UUID DEFAULT NULL,
    p_nombre_producto TEXT DEFAULT NULL,
    p_activo BOOLEAN DEFAULT NULL,
    p_id_categoria UUID DEFAULT NULL
)
RETURNS TABLE (
    "IdProducto" UUID,
    "Nombre" TEXT,
    "Descripcion" TEXT,
    "Precio" DECIMAL(10,2),
    "PrecioConDescuento" DECIMAL(10,2),
    "UrlModelo3D" TEXT,
    "Calorias" INTEGER,
    "EsActivo" BOOLEAN,
    "FechaCreacion" TIMESTAMPTZ,
    "Categorias" TEXT,
    "Ingredientes" TEXT,
    "Alergenos" TEXT,
    "PreferenciasDieteticas" TEXT,
    "Descuentos" JSON,
    "Imagenes" JSON
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id_producto AS "IdProducto",
        p.nombre AS "Nombre",
        p.descripcion AS "Descripcion",
        p.precio AS "Precio",

        -- Calcular precio con descuento
        COALESCE(
            (SELECT 
                CASE 
                    WHEN dp.tipo_descuento = 'porcentaje' THEN 
                        p.precio * (1 - dp.valor/100)
                    WHEN dp.tipo_descuento = 'monto_fijo' THEN 
                        GREATEST(p.precio - dp.valor, 0)
                    ELSE p.precio
                END
            FROM descuento_producto dp
            WHERE dp.id_producto = p.id_producto
              AND dp.es_activo = TRUE
              AND CURRENT_TIMESTAMP BETWEEN dp.fecha_inicio AND dp.fecha_fin
            LIMIT 1),
            p.precio
        ) AS "PrecioConDescuento",

        p.url_modelo_3d AS "UrlModelo3D",
        p.calorias AS "Calorias",
        p.es_activo AS "EsActivo",
        p.fecha_creacion AS "FechaCreacion",

        -- Categorías
        (
            SELECT string_agg(c.nombre, ', ')
            FROM producto_categoria pc
            JOIN categoria c ON pc.id_categoria = c.id_categoria
            WHERE pc.id_producto = p.id_producto
        ) AS "Categorias",

        -- Ingredientes
        (
            SELECT string_agg(i.nombre, ', ')
            FROM producto_ingrediente pi
            JOIN ingrediente i ON pi.id_ingrediente = i.id_ingrediente
            WHERE pi.id_producto = p.id_producto
        ) AS "Ingredientes",

        -- Alérgenos
        (
            SELECT string_agg(a.nombre, ', ')
            FROM producto_alergeno pa
            JOIN alergeno a ON pa.id_alergeno = a.id_alergeno
            WHERE pa.id_producto = p.id_producto
        ) AS "Alergenos",

        -- Preferencias dietéticas
        (
            SELECT string_agg(pd.nombre, ', ')
            FROM producto_preferencia_dietetica ppd
            JOIN preferencia_dietetica pd ON ppd.id_preferencia = pd.id_preferencia
            WHERE ppd.id_producto = p.id_producto
        ) AS "PreferenciasDieteticas",

        -- Descuentos activos
        (
            SELECT json_agg(json_build_object(
                'tipo', dp.tipo_descuento,
                'valor', dp.valor,
                'fecha_inicio', dp.fecha_inicio,
                'fecha_fin', dp.fecha_fin
            ))
            FROM descuento_producto dp
            WHERE dp.id_producto = p.id_producto
              AND dp.es_activo = TRUE
              AND CURRENT_TIMESTAMP BETWEEN dp.fecha_inicio AND dp.fecha_fin
        )::JSON AS "Descuentos",

        -- Imágenes
        (
            SELECT json_agg(json_build_object(
                'url', pi.url_imagen,
                'orden', pi.orden,
                'es_principal', pi.es_principal
            ) ORDER BY pi.orden)
            FROM producto_imagen pi
            WHERE pi.id_producto = p.id_producto
        )::JSON AS "Imagenes"

    FROM producto p
    LEFT JOIN producto_categoria pc ON p.id_producto = pc.id_producto
    WHERE 
        (p_id_producto IS NULL OR p.id_producto = p_id_producto)
        AND (p_nombre_producto IS NULL OR p.nombre ILIKE '%' || p_nombre_producto || '%')
        AND (p_activo IS NULL OR p.es_activo = p_activo)
        AND (p_id_categoria IS NULL OR pc.id_categoria = p_id_categoria)
    GROUP BY p.id_producto, p.nombre, p.descripcion, p.precio, p.url_modelo_3d, p.calorias, p.es_activo, p.fecha_creacion
    ORDER BY p.nombre;
END;
$$ LANGUAGE plpgsql;

--Registro de recepcion pedidos
DROP FUNCTION registrar_pedido_completo(
    p_id_usuario UUID,
    p_metodo_pago tipo_pago,
    p_total DECIMAL,
    p_total_con_descuento DECIMAL,
    p_creado_por TEXT,
    p_detalles JSON,
    p_cupones JSON
);
CREATE OR REPLACE FUNCTION registrar_pedido_completo(
    p_id_usuario UUID,
    p_metodo_pago tipo_pago,
    p_total DECIMAL,
    p_total_con_descuento DECIMAL,
    p_creado_por TEXT,
    p_detalles JSON,
    p_cupones JSON DEFAULT NULL
)
RETURNS TABLE (
    IdPedido UUID,
    Mensaje TEXT,
    Exito BOOLEAN
) AS $$
DECLARE
    v_id_pedido UUID := gen_random_uuid();
    v_detalle RECORD;
    v_cupon RECORD;
    v_error_context TEXT;
BEGIN
    -- Validación inicial
    IF p_total <= 0 THEN
        RETURN QUERY SELECT NULL::UUID, 'El total del pedido debe ser mayor que cero', FALSE;
        RETURN;
    END IF;

    -- Insertar pedido
    INSERT INTO pedido (
        id_pedido,
        id_usuario,
        metodo_pago,
        total,
        total_con_descuento,
        creado_por,
        fecha_creacion
    ) VALUES (
        v_id_pedido,
        p_id_usuario,
        p_metodo_pago,
        p_total,
        p_total_con_descuento,
        p_creado_por,
        NOW()
    );

    -- Insertar detalles
    FOR v_detalle IN SELECT * FROM json_to_recordset(p_detalles) AS (
        "IdProducto" UUID,
        "Cantidad" INTEGER,
        "PrecioUnitario" DECIMAL
    )
    LOOP
        IF v_detalle."Cantidad" <= 0 THEN
            RETURN QUERY SELECT NULL::UUID, 'La cantidad debe ser mayor que cero', FALSE;
            RETURN;
        END IF;

        IF v_detalle."PrecioUnitario" < 0 THEN
            RETURN QUERY SELECT NULL::UUID, 'El precio unitario no puede ser negativo', FALSE;
            RETURN;
        END IF;

        INSERT INTO detalle_pedido (
            id_pedido,
            id_producto,
            cantidad,
            precio_unitario,
            creado_por,
            fecha_creacion,
            actualizado_por,
            fecha_actualizacion
        ) VALUES (
            v_id_pedido,
            v_detalle."IdProducto",
            v_detalle."Cantidad",
            v_detalle."PrecioUnitario",
            p_creado_por,
            NOW(),
            p_creado_por,
            NOW()
        );
    END LOOP;

    -- Insertar cupones
    IF p_cupones IS NOT NULL THEN
        FOR v_cupon IN SELECT * FROM json_to_recordset(p_cupones) AS (
            "IdCupon" UUID,
            "TipoDescuento" TEXT,
            "DescuentoAplicado" DECIMAL
        )
        LOOP
            IF v_cupon."DescuentoAplicado" < 0 THEN
                RETURN QUERY SELECT NULL::UUID, 'El descuento aplicado no puede ser negativo', FALSE;
                RETURN;
            END IF;

            IF v_cupon."TipoDescuento" NOT IN ('fijo', 'porcentaje') THEN
                RETURN QUERY SELECT NULL::UUID, 'Tipo de descuento no válido. Debe ser "fijo" o "porcentaje"', FALSE;
                RETURN;
            END IF;

            INSERT INTO pedido_cupon (
                id_pedido,
                id_cupon,
                tipo_descuento,
                descuento_aplicado,
                creado_por,
                fecha_creacion
            ) VALUES (
                v_id_pedido,
                v_cupon."IdCupon",
                v_cupon."TipoDescuento",
                v_cupon."DescuentoAplicado",
                p_creado_por,
                NOW()
            );
        END LOOP;
    END IF;

	PERFORM * FROM actualizar_estado_pedido(v_id_pedido, 'Recibido', p_creado_por);

    RETURN QUERY SELECT v_id_pedido, 
        'Pedido registrado correctamente con ' || 
        json_array_length(p_detalles) || ' detalles y ' || 
        COALESCE(json_array_length(p_cupones), 0) || ' cupones',
        TRUE;

EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_context = PG_EXCEPTION_CONTEXT;
    RETURN QUERY SELECT NULL::UUID,
        'Error al registrar el pedido: ' || SQLERRM || 
        ' - Contexto: ' || v_error_context,
        FALSE;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM registrar_pedido_completo(
    -- ID de usuario (ejemplo)
    p_id_usuario := 'a1b2c3d4-e5f6-7890-1234-567890abcdef',
    
    -- Método de pago
    p_metodo_pago := 'Efectivo',
    
    -- Totales
    p_total := 150.00,
    p_total_con_descuento := 135.00,
    
    -- Creado por
    p_creado_por := 'usuario@ejemplo.com',
    
    -- Detalles del pedido en formato JSON
    p_detalles := '[
        {"id_producto": "41a196cd-47fc-42ed-964d-5eccf2eb15a2", "cantidad": 2, "precio_unitario": 25.00},
        {"id_producto": "5a6a9438-1dff-4b37-b48f-94447bab3169", "cantidad": 1, "precio_unitario": 50.00},
        {"id_producto": "bdff35d6-0e47-441e-b9c5-7596cde586fc", "cantidad": 3, "precio_unitario": 10.00}
    ]',
    
    -- Cupón (usando el ID proporcionado)
    p_id_cupon := '04f5318d-cb7f-4255-ab92-5721b3ca34d7',
    
    -- Tipo de descuento y monto aplicado
    p_tipo_descuento := 'porcentaje',
    p_descuento_aplicado := 10.00
);

SELECT * FROM registrar_pedido_completo(
    -- ID de usuario (debes reemplazarlo con uno válido de tu sistema)
    p_id_usuario := 'a1b2c3d4-e5f6-7890-1234-567890abcdef',
    
    -- Método de pago (usa uno de los valores de tu enum tipo_pago)
    p_metodo_pago := 'Efectivo',
    
    -- Totales (sin descuento)
    p_total := 120.50,
    p_total_con_descuento := 120.50,  -- Igual al total al no haber cupón
    
    -- Usuario que crea el pedido
    p_creado_por := 'cliente@email.com',
    
    -- Detalles del pedido en formato JSON (3 productos)
    p_detalles := '[
        {"id_producto": "41a196cd-47fc-42ed-964d-5eccf2eb15a2", "cantidad": 1, "precio_unitario": 45.00},
        {"id_producto": "bdff35d6-0e47-441e-b9c5-7596cde586fc", "cantidad": 2, "precio_unitario": 25.75},
        {"id_producto": "6d8da158-85af-4f99-8abe-e591427a4f22", "cantidad": 1, "precio_unitario": 24.00}
    ]',
    
    -- Parámetros de cupón como NULL (sin cupón)
    p_id_cupon := NULL,
    p_tipo_descuento := NULL,
    p_descuento_aplicado := NULL
);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM obtener_productos_con_relaciones();

-- Todos los productos
SELECT * FROM obtener_productos_con_relaciones();

-- Productos activos
SELECT * FROM obtener_productos_con_relaciones(p_activo => true);

-- Productos de una categoría específica
SELECT * FROM obtener_productos_con_relaciones(p_id_categoria => '3724269c-1686-4883-a8a4-368822cecd6e');

-- Búsqueda por nombre
SELECT * FROM obtener_productos_con_relaciones(p_nombre_producto => 'café');

-- Un producto específico
SELECT * FROM obtener_productos_con_relaciones(p_id_producto => 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');

select p.precio ,COALESCE(
            (SELECT 
                CASE 
                    WHEN dp.tipo_descuento = 'porcentaje' THEN 
                        p.precio * (1 - dp.valor/100)
                    WHEN dp.tipo_descuento = 'fijo' THEN 
                        GREATEST(p.precio - dp.valor, 0)
                    ELSE p.precio
                END
            FROM descuento_producto dp
            WHERE dp.id_producto = p.id_producto
            AND dp.es_activo = TRUE
            AND CURRENT_TIMESTAMP BETWEEN dp.fecha_inicio AND dp.fecha_fin
            LIMIT 1),
            p.precio
        ) AS "PrecioConDescuento" FROM producto p
        
        
drop FUNCTION actualizar_alergenos_usuario    
CREATE OR REPLACE FUNCTION actualizar_alergenos_usuario(
  p_id_usuario UUID,
  p_alergenos JSON,
  p_usuario_accion TEXT
) RETURNS BOOLEAN AS $$
BEGIN
  -- Eliminar todos los alérgenos actuales del usuario
  DELETE FROM usuario_alergeno 
  WHERE id_usuario = p_id_usuario;
  
  -- Insertar los nuevos alérgenos si el JSON no está vacío
  IF p_alergenos IS NOT NULL AND json_array_length(p_alergenos) > 0 THEN
    BEGIN
      INSERT INTO usuario_alergeno (id_usuario, id_alergeno, creado_por)
      SELECT p_id_usuario, (value->>'id_alergeno')::UUID, p_usuario_accion
      FROM json_array_elements(p_alergenos);
      
      RETURN true;
    EXCEPTION WHEN OTHERS THEN
      RETURN false;
    END;
  ELSE
    RETURN true; -- Operación exitosa (solo eliminación)
  END IF;
END;
$$ LANGUAGE plpgsql;    

drop FUNCTION actualizar_preferencias_dieteticas
CREATE OR REPLACE FUNCTION actualizar_preferencias_dieteticas(
  p_id_usuario UUID,
  p_preferencias JSON,
  p_usuario_accion TEXT
) RETURNS BOOLEAN AS $$
BEGIN
  -- Eliminar todas las preferencias actuales del usuario
  DELETE FROM usuario_preferencia_dietetica 
  WHERE id_usuario = p_id_usuario;
  
  -- Insertar las nuevas preferencias si el JSON no está vacío
  IF p_preferencias IS NOT NULL AND json_array_length(p_preferencias) > 0 THEN
    BEGIN
      INSERT INTO usuario_preferencia_dietetica (id_usuario, id_preferencia, creado_por)
      SELECT p_id_usuario, (value->>'id_preferencia')::UUID, p_usuario_accion
      FROM json_array_elements(p_preferencias);
      
      RETURN true;
    EXCEPTION WHEN OTHERS THEN
      RETURN false;
    END;
  ELSE
    RETURN true; -- Operación exitosa (solo eliminación)
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Para actualizar alérgenos
SELECT actualizar_alergenos_usuario(
  '1d2fda2e-2a9d-4e0a-a932-4a51748a3fd7', 
  '[{"id_alergeno": "6ddd82cd-5f81-45c4-ae86-86b36468814f"}, {"id_alergeno": "bbebf173-93b8-492f-8f2d-b36a5ec4a6e9"}]',
  'admin@example.com'
);

-- Para actualizar preferencias dietéticas
SELECT actualizar_preferencias_dieteticas(
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  '[{"id_preferencia": "d5eebc99-9c0b-4ef8-bb6d-6bb9bd380a44"}]',
  'admin@example.com'
);

 drop FUNCTION obtener_pedidos_usuario

CREATE OR REPLACE FUNCTION obtener_pedidos_usuario(
    p_id_usuario UUID
)
RETURNS TABLE (
    numero_pedido BIGINT,
    id_pedido UUID,
    estado_actual estado_pedido,
    productos JSON,
    total DECIMAL(10,2),
    total_con_descuento DECIMAL(10,2),
    fecha_creacion TIMESTAMPTZ,
    tiempo_transcurrido TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH ultimo_estado AS (
        SELECT 
            he.id_pedido, 
            he.estado,
            ROW_NUMBER() OVER (PARTITION BY he.id_pedido ORDER BY he.fecha_creacion DESC) AS rn
        FROM 
            historial_estado_pedido he
    ),
    tiempo_transcurrido AS (
        SELECT 
            p.id_pedido,
            CASE 
                WHEN EXTRACT(DAY FROM (now() - p.fecha_creacion)) > 0 THEN
                    'hace ' || EXTRACT(DAY FROM (now() - p.fecha_creacion)) || ' días • ' || 
                    to_char(p.fecha_creacion, 'DD Mon, HH12:MI a.m.')
                WHEN EXTRACT(HOUR FROM (now() - p.fecha_creacion)) > 0 THEN
                    'hace ' || EXTRACT(HOUR FROM (now() - p.fecha_creacion)) || ' horas • ' || 
                    to_char(p.fecha_creacion, 'DD Mon, HH12:MI a.m.')
                ELSE
                    'hace ' || EXTRACT(MINUTE FROM (now() - p.fecha_creacion)) || ' minutos • ' || 
                    to_char(p.fecha_creacion, 'DD Mon, HH12:MI a.m.')
            END AS tiempo_formateado
        FROM 
            pedido p
    ),
    productos_pedido AS (
        SELECT 
            dp.id_pedido,
            json_agg(json_build_object(
                'imagen', pi.url_imagen,
                'cantidad', dp.cantidad,
                'nombre', pr.nombre,
                'precio_unitario', dp.precio_unitario
            ) ORDER BY dp.id_detalle) AS productos_json
        FROM 
            detalle_pedido dp
        JOIN 
            producto pr ON dp.id_producto = pr.id_producto
        LEFT JOIN 
            producto_imagen pi ON dp.id_producto = pi.id_producto AND pi.es_principal = TRUE
        GROUP BY 
            dp.id_pedido
    )
    SELECT 
        p.numero_pedido,
        p.id_pedido,
        ue.estado AS estado_actual,
        COALESCE(pp.productos_json, '[]'::json) AS productos,
        p.total,
        p.total_con_descuento,
        p.fecha_creacion,
        tt.tiempo_formateado AS tiempo_transcurrido
    FROM 
        pedido p
    JOIN 
        ultimo_estado ue ON p.id_pedido = ue.id_pedido AND ue.rn = 1
    LEFT JOIN 
        productos_pedido pp ON p.id_pedido = pp.id_pedido
    LEFT JOIN 
        tiempo_transcurrido tt ON p.id_pedido = tt.id_pedido
    WHERE 
        p.id_usuario = p_id_usuario
    ORDER BY 
        p.fecha_creacion DESC;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM obtener_pedidos_usuario('3fa85f64-5717-4562-b3fc-2c963f66afa6');

SELECT 
    id_pedido as IdPedido,
    numero_pedido as NumeroPedido,
    estado_actual as EstadoActual,
    productos as Productos,
    total as Total,
    total_con_descuento as TotalConDescuento,
    fecha_creacion as FechaCreacion,
    tiempo_transcurrido as TiempoTranscurrido
FROM obtener_pedidos_usuario('60cda050-62ce-4786-8f72-16fb1fcc1af0');

drop FUNCTION obtener_detalle_pedido
--Obtener detalle de pedido
CREATE OR REPLACE FUNCTION obtener_detalle_pedido(
    p_id_pedido UUID
)
RETURNS TABLE (
    numero_pedido BIGINT,
    id_pedido UUID,
    estado_actual estado_pedido,
    estados JSON,
    productos JSON,
    cupones JSON,
    total DECIMAL(10,2),
    total_con_descuento DECIMAL(10,2),
    metodo_pago tipo_pago,
    fecha_creacion TIMESTAMPTZ,
    tiempo_transcurrido TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH estados_pedido AS (
        SELECT 
            he.estado,
            he.fecha_creacion,
            to_char(he.fecha_creacion, 'DD Mon, HH:MI a.m.') AS fecha_formateada
        FROM 
            historial_estado_pedido he
        WHERE 
            he.id_pedido = p_id_pedido
        ORDER BY 
            he.fecha_creacion
    ),
    tiempo_calculado AS (
        SELECT 
            CASE 
                WHEN EXTRACT(DAY FROM (now() - MIN(hep.fecha_creacion))) > 0 THEN
                    'hace ' || EXTRACT(DAY FROM (now() - MIN(hep.fecha_creacion))) || ' días • ' || 
                    to_char(MIN(hep.fecha_creacion), 'DD Mon, HH:MI a.m.')
                WHEN EXTRACT(HOUR FROM (now() - MIN(hep.fecha_creacion))) > 0 THEN
                    'hace ' || EXTRACT(HOUR FROM (now() - MIN(hep.fecha_creacion))) || ' horas • ' || 
                    to_char(MIN(hep.fecha_creacion), 'DD Mon, HH:MI a.m.')
                ELSE
                    'hace ' || EXTRACT(MINUTE FROM (now() - MIN(hep.fecha_creacion))) || ' minutos • ' || 
                    to_char(MIN(hep.fecha_creacion), 'DD Mon, HH:MI a.m.')
            END AS tiempo_formateado
        FROM 
            historial_estado_pedido hep 
        WHERE 
            hep.id_pedido = p_id_pedido
    ),
    productos_con_imagenes AS (
        SELECT
            dp.id_pedido,
            json_agg(
                json_build_object(
                    'id_producto', dp.id_producto,
                    'nombre', pr.nombre,
					'descripcion', pr.descripcion,
                    'cantidad', dp.cantidad,
                    'precio_unitario', dp.precio_unitario,
                    'subtotal', (dp.cantidad * dp.precio_unitario)::DECIMAL(10,2),
                    'imagenes', (
                        SELECT COALESCE(
                            json_agg(
                                json_build_object(
                                    'url', pi.url_imagen,
                                    'orden', pi.orden,
                                    'es_principal', pi.es_principal
                                ) ORDER BY pi.orden
                            ),
                            '[]'::json
                        )
                        FROM producto_imagen pi
                        WHERE pi.id_producto = dp.id_producto
                    ),
					'alergenos', (
	                    SELECT COALESCE(
	                        json_agg(a.nombre),
	                        '[]'::json
	                    )
	                    FROM producto_alergeno pa
	                    JOIN alergeno a ON pa.id_alergeno = a.id_alergeno
	                    WHERE pa.id_producto = dp.id_producto
	                )
                )
            ) AS productos_json
        FROM
            detalle_pedido dp
        JOIN
            producto pr ON dp.id_producto = pr.id_producto
        WHERE
            dp.id_pedido = p_id_pedido
        GROUP BY
            dp.id_pedido
    )
    SELECT 
        p.numero_pedido,
        p.id_pedido,
        (SELECT ep.estado FROM estados_pedido ep ORDER BY ep.fecha_creacion DESC LIMIT 1)::estado_pedido,
        (SELECT json_agg(json_build_object(
            'estado', ep.estado,
            'fecha', ep.fecha_formateada,
            'completado', true
        )) FROM estados_pedido ep)::JSON,
        COALESCE(pci.productos_json, '[]'::json),
        (SELECT json_agg(json_build_object(
            'codigo', c.codigo,
            'tipo_descuento', pc.tipo_descuento,
            'descuento_aplicado', pc.descuento_aplicado,
            'descripcion', CASE pc.tipo_descuento
                WHEN 'porcentaje' THEN pc.descuento_aplicado || '% de descuento'
                ELSE 'Descuento de $' || pc.descuento_aplicado
            END
        )) FROM pedido_cupon pc
        JOIN cupon c ON pc.id_cupon = c.id_cupon
        WHERE pc.id_pedido = p.id_pedido)::JSON,
        p.total,
        p.total_con_descuento,
        p.metodo_pago,
        p.fecha_creacion,
        tc.tiempo_formateado
    FROM 
        pedido p
    CROSS JOIN
        tiempo_calculado tc
    LEFT JOIN
        productos_con_imagenes pci ON p.id_pedido = pci.id_pedido
    WHERE 
        p.id_pedido = p_id_pedido;
END;
$$ LANGUAGE plpgsql;



SELECT 
    id_pedido as IdPedido,
    numero_pedido as NumeroPedido,
    estado_actual as EstadoActual,
    estados as Estados,
    productos as Productos,
    cupones as Cupones,
    total as Total,
    total_con_descuento as TotalConDescuento,
    metodo_pago as MetodoPago,
    fecha_creacion as FechaCreacion,
    tiempo_transcurrido as TiempoTranscurrido
FROM obtener_detalle_pedido('3b24b1f2-1a24-49dc-9014-ec85e7f671b3');

SELECT obtener_detalle_pedido(
  '3b24b1f2-1a24-49dc-9014-ec85e7f671b3'
);


CREATE OR REPLACE FUNCTION calcular_tiempo_estimado_restante(
    p_id_pedido UUID
) 
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_tiempo_estimado_total NUMERIC;
    v_tiempo_transcurrido NUMERIC;
    v_tiempo_restante INTEGER;
    v_estado_actual estado_pedido;
    v_fecha_creacion TIMESTAMPTZ;
    v_fecha_entrega_estimada TIMESTAMPTZ;
BEGIN
    -- Obtener estado actual, fecha creación y tiempo estimado
    SELECT 
        h.estado,
        p.fecha_creacion,
        EXTRACT(EPOCH FROM (p.tiempo_estimado_entrega - p.fecha_creacion))/60,
        p.tiempo_estimado_entrega
    INTO 
        v_estado_actual,
        v_fecha_creacion,
        v_tiempo_estimado_total,
        v_fecha_entrega_estimada
    FROM pedido p
    JOIN (
        SELECT id_pedido, estado
        FROM historial_estado_pedido
        WHERE (id_pedido, fecha_creacion) IN (
            SELECT id_pedido, MAX(fecha_creacion)
            FROM historial_estado_pedido
            GROUP BY id_pedido
        )
    ) h ON p.id_pedido = h.id_pedido
    WHERE p.id_pedido = p_id_pedido;
    
    -- Si ya está completado o cancelado, retornar 0
    IF v_estado_actual IN ('Listo', 'Cancelado') THEN
        RETURN 0;
    END IF;
    
    -- Si no hay tiempo estimado, retornar NULL
    IF v_fecha_entrega_estimada IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Calcular tiempo transcurrido en minutos
    v_tiempo_transcurrido := EXTRACT(EPOCH FROM (now() - v_fecha_creacion)) / 60;
    
    -- Calcular tiempo restante (no menos que 0)
    v_tiempo_restante := GREATEST(ROUND(v_tiempo_estimado_total - v_tiempo_transcurrido), 0);
    
    RETURN v_tiempo_restante;
END;
$$; 

CREATE OR REPLACE FUNCTION calcular_promedios_preparacion()
RETURNS TABLE (
    promedio_hoy NUMERIC,
    promedio_ayer NUMERIC,
    promedio_semana NUMERIC,
    total_pedidos_hoy BIGINT,
    desviacion_estandar NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
    -- Promedio del día actual (desde recibido hasta completado)
    SELECT 
        COALESCE(AVG(EXTRACT(EPOCH FROM (hep_completado.fecha_creacion - hep_recibido.fecha_creacion)) / 60), 15),
        COUNT(*),
        COALESCE(STDDEV(EXTRACT(EPOCH FROM (hep_completado.fecha_creacion - hep_recibido.fecha_creacion)) / 60), 0)
    INTO promedio_hoy, total_pedidos_hoy, desviacion_estandar
    FROM historial_estado_pedido hep_recibido
    JOIN historial_estado_pedido hep_completado 
        ON hep_recibido.id_pedido = hep_completado.id_pedido
    WHERE hep_recibido.estado = 'Recibido'
      AND hep_completado.estado = 'Listo'
      AND DATE(hep_recibido.fecha_creacion) = CURRENT_DATE;

    -- Promedio del día anterior
    SELECT 
        AVG(EXTRACT(EPOCH FROM (hep_completado.fecha_creacion - hep_recibido.fecha_creacion)) / 60)
    INTO promedio_ayer
    FROM historial_estado_pedido hep_recibido
    JOIN historial_estado_pedido hep_completado 
        ON hep_recibido.id_pedido = hep_completado.id_pedido
    WHERE hep_recibido.estado = 'Recibido'
      AND hep_completado.estado = 'Listo'
      AND DATE(hep_recibido.fecha_creacion) = CURRENT_DATE - INTERVAL '1 day';

    -- Promedio de los últimos 7 días
    SELECT 
        AVG(EXTRACT(EPOCH FROM (hep_completado.fecha_creacion - hep_recibido.fecha_creacion)) / 60)
    INTO promedio_semana
    FROM historial_estado_pedido hep_recibido
    JOIN historial_estado_pedido hep_completado 
        ON hep_recibido.id_pedido = hep_completado.id_pedido
    WHERE hep_recibido.estado = 'Recibido'
      AND hep_completado.estado = 'Listo'
      AND hep_recibido.fecha_creacion >= CURRENT_DATE - INTERVAL '7 days';

    RETURN NEXT;
END;
$$;


drop FUNCTION actualizar_estado_pedido
CREATE OR REPLACE FUNCTION actualizar_estado_pedido(
    p_id_pedido UUID,
    p_estado estado_pedido,
    p_usuario TEXT
) 
RETURNS TABLE (
    id_pedido UUID,
    estado TEXT,
    eta_minutos INT,
    tiempo_restante_minutos INT,
    tiempo_real_minutos NUMERIC,
    porcentaje_completado NUMERIC,
    mensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tiempo_estimado INTEGER := 15;
    v_promedio_actual NUMERIC;
    v_desviacion_estandar NUMERIC;
    v_total_pedidos_hoy INT;
    v_promedio_ayer NUMERIC;
    v_fecha_creacion TIMESTAMPTZ;
    v_tiempo_real NUMERIC := NULL;
    v_porcentaje NUMERIC := NULL;
BEGIN
    -- Insertar en historial
    INSERT INTO historial_estado_pedido(id_pedido, estado, creado_por)
    VALUES (p_id_pedido, p_estado, p_usuario);

    -- Obtener fecha de creación del pedido
    SELECT ped.fecha_creacion INTO v_fecha_creacion
    FROM pedido ped
    WHERE ped.id_pedido = p_id_pedido;

    -- Si estado = 'Recibido', calcular ETA basado en estadísticas
    IF p_estado = 'Recibido' THEN
        -- Obtener datos del día actual
        SELECT 
            AVG(EXTRACT(EPOCH FROM (h.fecha_creacion - ped.fecha_creacion)) / 60),
            STDDEV(EXTRACT(EPOCH FROM (h.fecha_creacion - ped.fecha_creacion)) / 60),
            COUNT(*)
        INTO v_promedio_actual, v_desviacion_estandar, v_total_pedidos_hoy
        FROM historial_estado_pedido h
        JOIN pedido ped ON h.id_pedido = ped.id_pedido
        WHERE h.estado = 'Listo'
          AND DATE(ped.fecha_creacion) = CURRENT_DATE;

        IF v_total_pedidos_hoy >= 3 AND v_promedio_actual IS NOT NULL THEN
            v_tiempo_estimado := ROUND(v_promedio_actual + COALESCE(v_desviacion_estandar, 0) * 0.5);
        ELSE
            -- Obtener promedio del día anterior si hoy no hay suficientes datos
            SELECT AVG(EXTRACT(EPOCH FROM (h.fecha_creacion - ped.fecha_creacion)) / 60)
            INTO v_promedio_ayer
            FROM historial_estado_pedido h
            JOIN pedido ped ON h.id_pedido = ped.id_pedido
            WHERE h.estado = 'Listo'
              AND DATE(ped.fecha_creacion) = CURRENT_DATE - INTERVAL '1 day';

            IF v_promedio_ayer IS NOT NULL THEN
                v_tiempo_estimado := ROUND(v_promedio_ayer * 1.2);
            END IF;
        END IF;

        -- Guardar ETA en tabla pedido
        UPDATE pedido
        SET tiempo_estimado_entrega = now() + (v_tiempo_estimado || ' minutes')::INTERVAL
        WHERE pedido.id_pedido = p_id_pedido;

    ELSIF p_estado = 'Listo' THEN
        -- Calcular tiempo real de preparación
        v_tiempo_real := EXTRACT(EPOCH FROM (now() - v_fecha_creacion)) / 60;
        UPDATE pedido
        SET 
            fecha_entrega = now(),
            tiempo_real_preparacion_minutos = v_tiempo_real
        WHERE pedido.id_pedido = p_id_pedido;
    END IF;

    -- Calcular porcentaje completado
    IF p_estado NOT IN ('Listo', 'Cancelado') THEN
        SELECT 
            ROUND(
                (EXTRACT(EPOCH FROM (now() - p.fecha_creacion)) / 
                NULLIF(EXTRACT(EPOCH FROM (p.tiempo_estimado_entrega - p.fecha_creacion)), 0)) * 100, 
                1
            )
        INTO v_porcentaje
        FROM pedido p
        WHERE p.id_pedido = p_id_pedido;
    ELSE
        v_porcentaje := 100;
    END IF;

    -- Retornar resumen sin ambigüedad
    RETURN QUERY
    SELECT * FROM (
        VALUES (
            p_id_pedido,
            p_estado::TEXT,
            v_tiempo_estimado,
            calcular_tiempo_estimado_restante(p_id_pedido),
            v_tiempo_real,
            v_porcentaje,
            'Estado actualizado correctamente.'::TEXT
        )
    ) AS result(
        id_pedido, 
        estado, 
        eta_minutos, 
        tiempo_restante_minutos, 
        tiempo_real_minutos, 
        porcentaje_completado, 
        mensaje
    );
END;
$$;



CREATE OR REPLACE VIEW vista_monitoreo_pedidos AS
SELECT 
    p.id_pedido,
    p.numero_pedido,
    he.estado AS estado_actual,
    p.fecha_creacion AS fecha_recibido,
    
    -- Tiempo estimado total (minutos)
    EXTRACT(EPOCH FROM (p.tiempo_estimado_entrega - p.fecha_creacion))/60 AS eta_total_minutos,
    
    -- Tiempo transcurrido (minutos)
    CASE 
        WHEN he.estado NOT IN ('Listo', 'Cancelado') THEN 
            EXTRACT(EPOCH FROM (now() - p.fecha_creacion))/60 
        ELSE NULL 
    END AS minutos_transcurridos,
    
    -- Tiempo restante estimado (minutos)
    calcular_tiempo_estimado_restante(p.id_pedido) AS minutos_restantes,
    
    -- Porcentaje completado
    CASE 
        WHEN he.estado NOT IN ('Listo', 'Cancelado') THEN 
            ROUND(
                (EXTRACT(EPOCH FROM (now() - p.fecha_creacion)) / 
                EXTRACT(EPOCH FROM (p.tiempo_estimado_entrega - p.fecha_creacion)) * 100)::numeric, 
                1
            )
        WHEN he.estado = 'Listo' THEN 100
        ELSE 0 
    END AS porcentaje_completado,
    
    -- Tiempo real (solo para completados)
    p.tiempo_real_preparacion_minutos,
    
    -- Diferencia entre estimado y real
    CASE 
        WHEN he.estado = 'Listo' THEN 
            p.tiempo_real_preparacion_minutos - EXTRACT(EPOCH FROM (p.tiempo_estimado_entrega - p.fecha_creacion))/60
        ELSE NULL 
    END AS diferencia_minutos

FROM pedido p
JOIN (
    SELECT id_pedido, estado
    FROM historial_estado_pedido
    WHERE (id_pedido, fecha_creacion) IN (
        SELECT id_pedido, MAX(fecha_creacion)
        FROM historial_estado_pedido
        GROUP BY id_pedido
    )
) he ON p.id_pedido = he.id_pedido;


CREATE OR REPLACE FUNCTION recalcular_tiempos_estimados()
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_promedio_actual NUMERIC;
    v_desviacion_estandar NUMERIC;
    v_total_pedidos_hoy BIGINT;
    v_pedidos_actualizados INTEGER := 0;
BEGIN
    -- Obtener estadísticas actuales
    SELECT 
        promedio_hoy, 
        desviacion_estandar, 
        total_pedidos_hoy 
    INTO 
        v_promedio_actual, 
        v_desviacion_estandar, 
        v_total_pedidos_hoy
    FROM calcular_promedios_preparacion();
    
    -- Calcular nuevo tiempo estimado considerando desviación estándar
    IF v_total_pedidos_hoy >= 3 THEN
        v_promedio_actual := v_promedio_actual + (v_desviacion_estandar * 0.3); -- Margen más ajustado
    ELSE
        -- Si no hay suficientes datos hoy, usar promedio de ayer con margen
        SELECT promedio_ayer INTO v_promedio_actual FROM calcular_promedios_preparacion();
        v_promedio_actual := COALESCE(v_promedio_actual, 30) * 1.1; -- 10% más
    END IF;
    
    -- Actualizar pedidos en estado 'Recibido' o 'Preparando'
    UPDATE pedido p
    SET 
        tiempo_estimado_entrega = p.fecha_creacion + (ROUND(v_promedio_actual) || ' minutes')::INTERVAL,
        fecha_actualizacion = now(),
        actualizado_por = 'sistema'
    FROM (
        SELECT id_pedido
        FROM historial_estado_pedido
        WHERE (id_pedido, fecha_creacion) IN (
            SELECT id_pedido, MAX(fecha_creacion)
            FROM historial_estado_pedido
            GROUP BY id_pedido
        )
        AND estado IN ('Recibido', 'Preparando')
    ) he
    WHERE p.id_pedido = he.id_pedido;
    
    GET DIAGNOSTICS v_pedidos_actualizados = ROW_COUNT;
    
    RETURN v_pedidos_actualizados;
END;
$$;

                        
--Examples:
-- Pedido 1 - Hoy a las 12:00
INSERT INTO pedido (
    id_pedido, id_usuario, metodo_pago, numero_pedido, total, total_con_descuento, fecha_creacion, creado_por
)
VALUES (
    '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'Efectivo', 1001, 10.00, 10.00,
    now() - INTERVAL '2 hours', 'sistema'
);

select promedio_hoy as PromedioHoy,promedio_ayer as PromedioAyer, promedio_semana as PromedioSemana,
total_pedidos_hoy as TotalPedidoHoy from calcular_promedios_preparacion()
SELECT * from actualizar_estado_pedido('b55d9b54-b201-4b08-a634-42be49582a9f', 'Preparando', 'usuario1');
SELECT * from actualizar_estado_pedido('debe36a3-c09d-4886-83fd-72153f18e088', 'Listo', 'usuario1');


SELECT * from actualizar_estado_pedido('5dade527-c0fe-4567-816f-ffc927640d1d', 'Preparando', 'usuario1');
SELECT * from actualizar_estado_pedido('f9fb7151-5d51-43cf-b6c3-77adcc1d346d', 'Preparando', 'usuario1');

SELECT * from actualizar_estado_pedido('69e46fdf-a141-4767-a8ed-0e975756fa91', 'Entregado', 'usuario1');
SELECT * from actualizar_estado_pedido('f9fb7151-5d51-43cf-b6c3-77adcc1d346d', 'Cancelado', 'usuario1');

SELECT * from actualizar_estado_pedido('826ad5d2-32cc-4c00-83a7-e2eff3d8244d', 'Listo', 'usuario1');
SELECT * from actualizar_estado_pedido('826ad5d2-32cc-4c00-83a7-e2eff3d8244d', 'Entregado', 'usuario1');
select * from recalcular_tiempos_estimados()

select * from vista_monitoreo_pedidos
select * from calcular_tiempo_estimado_restante('a6400fbb-459b-4916-a253-34e75487720b') 
select  from calcular_tiempo_estimado_restante('5dade527-c0fe-4567-816f-ffc927640d1d') 


-- Pedido 1 completado (tiempo total: 30 min)

CREATE OR REPLACE FUNCTION obtener_etas_pedidos()
RETURNS TABLE (
    IdPedido UUID,
    TiempoEstimado INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id_pedido,
        calcular_tiempo_estimado_restante(p.id_pedido) AS TiempoEstimado
    FROM pedido p
    JOIN (
        SELECT DISTINCT ON (id_pedido)
            id_pedido,
            estado,
            fecha_creacion
        FROM historial_estado_pedido
        ORDER BY id_pedido, fecha_creacion DESC
    ) h ON p.id_pedido = h.id_pedido
    WHERE h.estado in ('Recibido','Preparando');
END;
$$;

SELECT idpedido as IdPedido, tiempoEstimado as TiempoEstimado FROM obtener_etas_pedidos();

drop function registrar_producto_con_relaciones
CREATE OR REPLACE FUNCTION registrar_producto_con_relaciones(
    p_nombre TEXT,
    p_descripcion TEXT,
    p_precio DECIMAL(10,2),
    p_url_modelo_3d TEXT,
    p_calorias INTEGER,
    p_creado_por TEXT,
    p_categorias JSON,
    p_ingredientes JSON,
    p_alergenos JSON,
    p_preferencias_dieteticas JSON,
    p_imagenes TEXT, -- era JSON, ahora TEXT
    p_descuentos TEXT DEFAULT NULL -- era JSON, ahora TEXT
)
RETURNS UUID AS $$
DECLARE
    v_id_producto UUID := gen_random_uuid();
    v_id UUID;
    v_obj JSON;
BEGIN
    -- Insertar producto
    INSERT INTO producto (
        id_producto, nombre, descripcion, precio, url_modelo_3d,
        calorias, creado_por
    )
    VALUES (
        v_id_producto, p_nombre, p_descripcion, p_precio, p_url_modelo_3d,
        p_calorias, p_creado_por
    );

    -- Insertar categorías
    FOR v_id IN SELECT json_array_elements_text(p_categorias)
    LOOP
        INSERT INTO producto_categoria(id_producto, id_categoria, creado_por)
        VALUES (v_id_producto, v_id, p_creado_por);
    END LOOP;

    -- Insertar ingredientes
    FOR v_id IN SELECT json_array_elements_text(p_ingredientes)
    LOOP
        INSERT INTO producto_ingrediente(id_producto, id_ingrediente, creado_por)
        VALUES (v_id_producto, v_id, p_creado_por);
    END LOOP;

    -- Insertar alérgenos
    FOR v_id IN SELECT json_array_elements_text(p_alergenos)
    LOOP
        INSERT INTO producto_alergeno(id_producto, id_alergeno, creado_por)
        VALUES (v_id_producto, v_id, p_creado_por);
    END LOOP;

    -- Insertar preferencias dietéticas
    FOR v_id IN SELECT json_array_elements_text(p_preferencias_dieteticas)
    LOOP
        INSERT INTO producto_preferencia_dietetica(id_producto, id_preferencia, creado_por)
        VALUES (v_id_producto, v_id, p_creado_por);
    END LOOP;

    -- Insertar descuentos
    FOR v_obj IN SELECT * FROM json_array_elements(p_descuentos::JSON)
    LOOP
        INSERT INTO descuento_producto(
            id_descuento, id_producto, tipo_descuento, valor,
            fecha_inicio, fecha_fin, es_activo, creado_por
        )
        VALUES (
            gen_random_uuid(), v_id_producto,
            (v_obj->>'tipo_descuento')::TEXT,
            (v_obj->>'valor')::DECIMAL,
            (v_obj->>'fecha_inicio')::TIMESTAMPTZ,
            (v_obj->>'fecha_fin')::TIMESTAMPTZ,
            TRUE, p_creado_por
        );
    END LOOP;

    -- Insertar imágenes
    FOR v_obj IN SELECT * FROM json_array_elements(p_imagenes::JSON)
    LOOP
        INSERT INTO producto_imagen(
            id_imagen, id_producto, url_imagen, orden,
            es_principal, creado_por
        )
        VALUES (
            gen_random_uuid(), v_id_producto,
            v_obj->>'url',
            (v_obj->>'orden')::SMALLINT,
            (v_obj->>'es_principal')::BOOLEAN,
            p_creado_por
        );
    END LOOP;

    RETURN v_id_producto;
END;
$$ LANGUAGE plpgsql;



SELECT registrar_producto_con_relaciones(
    'Pizza Margarita 2', -- @Nombre
    'Clásica pizza italiana con tomate, mozzarella y albahaca', -- @Descripcion
    9.99, -- @Precio
    'https://cdn.ejemplo.com/modelos/pizza.glb', -- @UrlModelo3D
    850, -- @Calorias
    'admin', -- @CreadoPor
    '["e6d795a4-8ca5-4420-a0cf-c8ad58527448"]', -- @Categorias (JSON string)
    '["2929ac7e-bf38-4223-9911-b3956ddcc5eb", "b08162ce-a957-4b3c-9428-f25acf95e352"]', -- @Ingredientes
    '["bbebf173-93b8-492f-8f2d-b36a5ec4a6e9"]', -- @Alergenos
    '["fe5963a3-e9b4-455f-a82d-441a3adf2d8d"]', -- @Preferencias
    '[
        {
            "url": "https://cdn.ejemplo.com/imagenes/pizza1.jpg",
            "orden": 1,
            "es_principal": true
        },
        {
            "url": "https://cdn.ejemplo.com/imagenes/pizza2.jpg",
            "orden": 2,
            "es_principal": false
        }
    ]', -- @Imagenes (JSON array string)
    '[
        {
            "tipo_descuento": "porcentaje",
            "valor": 10,
            "fecha_inicio": "2025-06-08T00:00:00Z",
            "fecha_fin": "2025-06-30T23:59:59Z"
        }
    ]' -- @Descuentos (JSON array string)
);


 
                        
