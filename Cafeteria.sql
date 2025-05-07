CREATE DATABASE CAFETERIA;

-- Crear tipos personalizados
CREATE TYPE estado_pedido AS ENUM ('Recibido', 'Preparando', 'Listo', 'Completado');
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


-- Crear tabla pedido
CREATE TABLE IF NOT EXISTS pedido (
  id_pedido UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_usuario UUID NOT NULL,
  metodo_pago tipo_pago NOT NULL,
  total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
  total_con_descuento DECIMAL(10,2) CHECK (total_con_descuento >= 0),
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
    GROUP BY p.id_producto
    ORDER BY p.nombre;
END;
$$ LANGUAGE plpgsql;


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
