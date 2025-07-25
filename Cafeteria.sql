CREATE DATABASE CAFETERIA;

-- Crear tipos personalizados
CREATE TYPE estado_pedido AS ENUM ('Pendiente','Recibido', 'Preparando', 'Listo', 'Entregado','Cancelado','Programado');
CREATE TYPE tipo_pago AS ENUM ('Efectivo', 'Tarjeta','Saldo');


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
  fecha_programada TIMESTAMPTZ NULL,
  es_pedido_programado BOOLEAN DEFAULT false,
  numero_pedido BIGINT NOT NULL,,
  total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
  total_con_descuento DECIMAL(10,2) CHECK (total_con_descuento >= 0),
  fecha_recibido TIMESTAMPTZ,
  tiempo_estimado_entrega TIMESTAMPTZ,
  fecha_entrega TIMESTAMPTZ,
  tiempo_real_preparacion_minutos numeric,
  identificador_enlace_pago UUID UNIQUE,
  id_evento UUID REFERENCES tipo_evento(id_evento),
  fecha_creacion TIMESTAMPTZ DEFAULT now(),	
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ null,
  actualizado_por TEXT
);

CREATE TABLE IF NOT EXISTS saldo_usuario (
  id_saldo UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_usuario UUID NOT NULL UNIQUE,
  saldo DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (saldo >= 0),
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ,
  actualizado_por TEXT
);

-- Tabla para registrar transacciones de saldo
CREATE TABLE IF NOT EXISTS transaccion_saldo (
  id_transaccion UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_usuario UUID NOT NULL,
  tipo TEXT NOT NULL CHECK (tipo IN ('Recarga', 'Compra', 'Devolucion')),
  monto DECIMAL(10,2) NOT NULL,
  id_pedido UUID REFERENCES pedido(id_pedido) ON DELETE SET NULL,
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT
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
  tipo_descuento TEXT CHECK (tipo_descuento IN ('	', 'porcentaje')) NOT NULL,
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

CREATE TABLE IF NOT EXISTS tipo_evento (
    id_evento UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL unique,
    fecha_creacion TIMESTAMPTZ DEFAULT now(),
  	creado_por TEXT,
  	fecha_actualizacion TIMESTAMPTZ null,
  	actualizado_por TEXT
);
CREATE TABLE IF NOT EXISTS stock_producto_dia (
  id_stock UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_producto UUID REFERENCES producto(id_producto) ON DELETE CASCADE,
  dia_semana varchar(100),
  stock_disponible INTEGER NOT NULL CHECK (stock_disponible >= 0),
  stock_reservado INTEGER DEFAULT 0 CHECK (stock_reservado >= 0),
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ,
  actualizado_por TEXT);



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
-- CRÍTICO: Para consultas de ventas por período (día, semana, mes)
CREATE INDEX idx_pedido_fecha_creacion ON pedido(fecha_creacion DESC) 
INCLUDE (total, total_con_descuento, id_usuario);

-- CRÍTICO: Para estado de pedidos por período
CREATE INDEX idx_historial_estado_compuesto ON historial_estado_pedido(estado, fecha_creacion DESC) 
INCLUDE (id_pedido);

-- Para obtener el último estado de cada pedido eficientemente
CREATE INDEX idx_historial_pedido_fecha ON historial_estado_pedido(id_pedido, fecha_creacion DESC);

-- Para productos más vendidos
CREATE INDEX idx_detalle_pedido_producto_cantidad ON detalle_pedido(id_producto) 
INCLUDE (cantidad, precio_unitario);


-- INSERTS
INSERT INTO tipo_evento (nombre, creado_por)
VALUES
  ('Evento académico', 'admin'),
  ('Taller de capacitación', 'admin'),
  ('Jornada de socialización de proyectos', 'admin'),
  ('Congreso de investigación', 'admin'),
  ('Reunión de docentes', 'admin');


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

SELECT 'DROP FUNCTION ' || oid::regprocedure || ';' 
FROM pg_proc 
WHERE proname = 'registrar_pedido_completo';

DROP FUNCTION registrar_pedido_completo(uuid,tipo_pago,numeric,numeric,text,json,json,uuid,boolean,timestamp with time zone);

CREATE OR REPLACE FUNCTION registrar_pedido_completo(
    p_id_usuario UUID,
    p_metodo_pago tipo_pago,
    p_total DECIMAL,
    p_total_con_descuento DECIMAL,
    p_creado_por TEXT,
    p_detalles JSON,
    p_cupones JSON DEFAULT null,
    p_id_enlace UUID DEFAULT NULL,
    p_es_pedido_programado BOOLEAN DEFAULT FALSE,
    p_fecha_programada TIMESTAMPTZ DEFAULT null,
    p_id_evento UUID DEFAULT NULL
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

    IF p_es_pedido_programado AND p_fecha_programada IS NULL THEN
        RETURN QUERY SELECT NULL::UUID, 'Debe especificar una fecha programada para el pedido', FALSE;
        RETURN;
    END IF;
	-- Validacion de Saldo
	IF p_metodo_pago = 'Saldo' THEN
	  -- Descontar saldo
	  UPDATE saldo_usuario
	  SET saldo = saldo - p_total_con_descuento,
	      fecha_actualizacion = NOW(),
	      actualizado_por = p_creado_por
	  WHERE id_usuario = p_id_usuario;
	
	  -- Registrar transacción de saldo
	  INSERT INTO transaccion_saldo (
	    id_usuario, tipo, monto, id_pedido, creado_por
	  ) VALUES (
	    p_id_usuario, 'Compra', p_total_con_descuento, v_id_pedido, p_creado_por
	  );
	END IF;

    -- Insertar pedido
    INSERT INTO pedido (
        id_pedido,
        id_usuario,
        identificador_enlace_pago,
        metodo_pago,
        total,
        total_con_descuento,
        creado_por,
        fecha_creacion,
        es_pedido_programado,
        fecha_programada,
		id_evento
    ) VALUES (
        v_id_pedido,
        p_id_usuario,
        p_id_enlace,
        p_metodo_pago,
        p_total,
        p_total_con_descuento,
        p_creado_por,
        NOW(),
        p_es_pedido_programado,
        p_fecha_programada,
		p_id_evento 
    );

    -- Insertar detalles del pedido
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

    -- Insertar cupones si hay
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

    -- Estado inicial del pedido
    IF p_es_pedido_programado THEN
        PERFORM * FROM actualizar_estado_pedido(v_id_pedido, 'Programado', p_creado_por);
    ELSIF p_metodo_pago = 'Efectivo' THEN
        PERFORM * FROM actualizar_estado_pedido(v_id_pedido, 'Recibido', p_creado_por);
    ELSE
        PERFORM * FROM actualizar_estado_pedido(v_id_pedido, 'Pendiente', p_creado_por);
    END IF;

    RETURN QUERY SELECT v_id_pedido, 
        'Pedido ' || CASE WHEN p_es_pedido_programado THEN 'programado' ELSE 'normal' END ||
        ' registrado correctamente con ' || 
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


CREATE OR REPLACE FUNCTION registrar_pedido_completo(
    p_id_usuario UUID,
    p_metodo_pago tipo_pago,
    p_total DECIMAL,
    p_total_con_descuento DECIMAL,
    p_creado_por TEXT,
    p_detalles JSON,
    p_cupones JSON DEFAULT null,
    p_id_enlace UUID DEFAULT NULL
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
        identificador_enlace_pago,
        metodo_pago,
        total,
        total_con_descuento,
        creado_por,
        fecha_creacion
    ) VALUES (
        v_id_pedido,
        p_id_usuario,
        p_id_enlace,
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

    -- Establecer estado según método de pago
    IF p_metodo_pago = 'Efectivo' THEN
        PERFORM * FROM actualizar_estado_pedido(v_id_pedido, 'Recibido', p_creado_por);
    ELSE
        PERFORM * FROM actualizar_estado_pedido(v_id_pedido, 'Pendiente', p_creado_por);
    END IF;

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
DECLARE
    zona_horaria TEXT := 'America/El_Salvador';
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
                -- Si han pasado más de 30 días, mostrar la fecha completa
                WHEN EXTRACT(DAY FROM (NOW() AT TIME ZONE zona_horaria - p.fecha_creacion AT TIME ZONE zona_horaria)) >= 30 THEN
                    TO_CHAR(p.fecha_creacion AT TIME ZONE zona_horaria, 'DD Mon YYYY, HH12:MI ') ||
                    CASE 
                        WHEN EXTRACT(HOUR FROM p.fecha_creacion AT TIME ZONE zona_horaria) < 12 THEN 'a.m.'
                        ELSE 'p.m.'
                    END
                -- Si han pasado días
                WHEN EXTRACT(DAY FROM (NOW() AT TIME ZONE zona_horaria - p.fecha_creacion AT TIME ZONE zona_horaria)) > 0 THEN
                    'hace ' || 
                    FLOOR(EXTRACT(EPOCH FROM (NOW() AT TIME ZONE zona_horaria - p.fecha_creacion AT TIME ZONE zona_horaria)) / 86400)::TEXT || 
                    CASE 
                        WHEN FLOOR(EXTRACT(EPOCH FROM (NOW() AT TIME ZONE zona_horaria - p.fecha_creacion AT TIME ZONE zona_horaria)) / 86400) = 1 THEN ' día'
                        ELSE ' días'
                    END || ' • ' ||
                    TO_CHAR(p.fecha_creacion AT TIME ZONE zona_horaria, 'DD Mon, HH12:MI ') ||
                    CASE 
                        WHEN EXTRACT(HOUR FROM p.fecha_creacion AT TIME ZONE zona_horaria) < 12 THEN 'a.m.'
                        ELSE 'p.m.'
                    END
                -- Si han pasado horas
                WHEN EXTRACT(HOUR FROM (NOW() AT TIME ZONE zona_horaria - p.fecha_creacion AT TIME ZONE zona_horaria)) > 0 THEN
                    'hace ' || 
                    FLOOR(EXTRACT(EPOCH FROM (NOW() AT TIME ZONE zona_horaria - p.fecha_creacion AT TIME ZONE zona_horaria)) / 3600)::TEXT || 
                    CASE 
                        WHEN FLOOR(EXTRACT(EPOCH FROM (NOW() AT TIME ZONE zona_horaria - p.fecha_creacion AT TIME ZONE zona_horaria)) / 3600) = 1 THEN ' hora'
                        ELSE ' horas'
                    END || ' • ' ||
                    TO_CHAR(p.fecha_creacion AT TIME ZONE zona_horaria, 'DD Mon, HH12:MI ') ||
                    CASE 
                        WHEN EXTRACT(HOUR FROM p.fecha_creacion AT TIME ZONE zona_horaria) < 12 THEN 'a.m.'
                        ELSE 'p.m.'
                    END
                -- Si han pasado minutos
                WHEN EXTRACT(MINUTE FROM (NOW() AT TIME ZONE zona_horaria - p.fecha_creacion AT TIME ZONE zona_horaria)) > 0 THEN
                    'hace ' || 
                    FLOOR(EXTRACT(EPOCH FROM (NOW() AT TIME ZONE zona_horaria - p.fecha_creacion AT TIME ZONE zona_horaria)) / 60)::TEXT || 
                    CASE 
                        WHEN FLOOR(EXTRACT(EPOCH FROM (NOW() AT TIME ZONE zona_horaria - p.fecha_creacion AT TIME ZONE zona_horaria)) / 60) = 1 THEN ' minuto'
                        ELSE ' minutos'
                    END || ' • ' ||
                    TO_CHAR(p.fecha_creacion AT TIME ZONE zona_horaria, 'DD Mon, HH12:MI ') ||
                    CASE 
                        WHEN EXTRACT(HOUR FROM p.fecha_creacion AT TIME ZONE zona_horaria) < 12 THEN 'a.m.'
                        ELSE 'p.m.'
                    END
                -- Si es menos de un minuto
                ELSE
                    'hace un momento • ' ||
                    TO_CHAR(p.fecha_creacion AT TIME ZONE zona_horaria, 'DD Mon, HH12:MI ') ||
                    CASE 
                        WHEN EXTRACT(HOUR FROM p.fecha_creacion AT TIME ZONE zona_horaria) < 12 THEN 'a.m.'
                        ELSE 'p.m.'
                    END
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



SELECT * FROM obtener_pedidos_usuario('883a5449-0e53-4186-8b03-84d4d3ee936d');

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

select * from obtener_detalle_pedido('087e90b1-51a2-4f76-9afb-05c0885c7911')
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
    v_id_pedido UUID;
    v_tiempo_estimado INTEGER := 15;
    v_promedio_actual NUMERIC;
    v_desviacion_estandar NUMERIC;
    v_total_pedidos_hoy INT;
    v_promedio_ayer NUMERIC;
    v_fecha_creacion TIMESTAMPTZ;
    v_tiempo_real NUMERIC := NULL;
    v_porcentaje NUMERIC := NULL;
BEGIN
    -- Determinar el ID del pedido basándose en el identificador proporcionado
    -- Primero intentar como UUID (id_pedido)
    BEGIN
        v_id_pedido := p_id_pedido::UUID;
        
        -- Verificar si existe el pedido con este ID
        IF NOT EXISTS (SELECT 1 FROM pedido WHERE pedido.id_pedido = v_id_pedido) THEN
            v_id_pedido := NULL;
        END IF;
    EXCEPTION WHEN invalid_text_representation THEN
        -- Si no es un UUID válido, continuar con la búsqueda por identificador_enlace_pago
        v_id_pedido := NULL;
    END;
    
    -- Si no se encontró por ID, buscar por identificador_enlace_pago
    IF v_id_pedido IS NULL THEN
        BEGIN
            SELECT pedido.id_pedido INTO v_id_pedido
            FROM pedido 
            WHERE pedido.identificador_enlace_pago = p_id_pedido::UUID;
        EXCEPTION WHEN invalid_text_representation THEN
            -- Si tampoco es un UUID válido para identificador_enlace_pago
            v_id_pedido := NULL;
        END;
    END IF;
    
    -- Si no se encontró el pedido, retornar error
    IF v_id_pedido IS NULL THEN
        RETURN QUERY
        SELECT * FROM (
            VALUES (
                NULL::UUID,
                'Error'::TEXT,
                0,
                0,
                NULL::NUMERIC,
                NULL::NUMERIC,
                'Pedido no encontrado con el identificador proporcionado.'::TEXT
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
        RETURN;
    END IF;

    -- Insertar en historial
    INSERT INTO historial_estado_pedido(id_pedido, estado, creado_por)
    VALUES (v_id_pedido, p_estado, p_usuario);

    -- Obtener fecha de creación del pedido
    SELECT ped.fecha_creacion INTO v_fecha_creacion
    FROM pedido ped
    WHERE ped.id_pedido = v_id_pedido;

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
        WHERE pedido.id_pedido = v_id_pedido;

    ELSIF p_estado = 'Listo' THEN
        -- Calcular tiempo real de preparación
        v_tiempo_real := EXTRACT(EPOCH FROM (now() - v_fecha_creacion)) / 60;
        UPDATE pedido
        SET
            fecha_entrega = now(),
            tiempo_real_preparacion_minutos = v_tiempo_real
        WHERE pedido.id_pedido = v_id_pedido;
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
        WHERE p.id_pedido = v_id_pedido;
    ELSE
        v_porcentaje := 100;
    END IF;

    -- Retornar resumen exitoso
    RETURN QUERY
    SELECT * FROM (
        VALUES (
            v_id_pedido,
            p_estado::TEXT,
            v_tiempo_estimado,
            calcular_tiempo_estimado_restante(v_id_pedido),
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

SELECT 'DROP FUNCTION ' || oid::regprocedure || ';' 
FROM pg_proc 
WHERE proname = 'registrar_producto_con_relaciones';
DROP FUNCTION registrar_producto_con_relaciones(text,text,numeric,text,integer,text,text,text,text,text,text,text);

CREATE OR REPLACE FUNCTION registrar_producto_con_relaciones(
    p_nombre TEXT,
    p_descripcion TEXT,
    p_precio NUMERIC,
    p_url_modelo_3d TEXT,
    p_calorias INTEGER,
    p_creado_por TEXT,
    p_categorias TEXT,
    p_ingredientes TEXT,
    p_alergenos TEXT,
    p_preferencias_dieteticas TEXT,
    p_imagenes TEXT,
    p_descuentos TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_id_producto UUID := gen_random_uuid();
    v_id UUID;
    v_obj JSON;
    v_image JSON;
BEGIN
    -- Insertar producto principal
    INSERT INTO producto (
        id_producto, nombre, descripcion, precio, url_modelo_3d,
        calorias, creado_por
    )
    VALUES (
        v_id_producto, p_nombre, p_descripcion, p_precio, p_url_modelo_3d,
        p_calorias, p_creado_por
    );

    -- Insertar categorías
    IF p_categorias IS NOT NULL AND p_categorias <> 'null' AND p_categorias <> '' THEN
        FOR v_id IN SELECT json_array_elements_text(p_categorias::JSON)
        LOOP
            INSERT INTO producto_categoria(id_producto, id_categoria, creado_por)
            VALUES (v_id_producto, v_id::UUID, p_creado_por);
        END LOOP;
    END IF;

    -- Insertar ingredientes
    IF p_ingredientes IS NOT NULL AND p_ingredientes <> 'null' AND p_ingredientes <> '' THEN
        FOR v_id IN SELECT json_array_elements_text(p_ingredientes::JSON)
        LOOP
            INSERT INTO producto_ingrediente(id_producto, id_ingrediente, creado_por)
            VALUES (v_id_producto, v_id::UUID, p_creado_por);
        END LOOP;
    END IF;

    -- Insertar alérgenos
    IF p_alergenos IS NOT NULL AND p_alergenos <> 'null' AND p_alergenos <> '' THEN
        FOR v_id IN SELECT json_array_elements_text(p_alergenos::JSON)
        LOOP
            INSERT INTO producto_alergeno(id_producto, id_alergeno, creado_por)
            VALUES (v_id_producto, v_id::UUID, p_creado_por);
        END LOOP;
    END IF;

    -- Insertar preferencias dietéticas
    IF p_preferencias_dieteticas IS NOT NULL AND p_preferencias_dieteticas <> 'null' AND p_preferencias_dieteticas <> '' THEN
        FOR v_id IN SELECT json_array_elements_text(p_preferencias_dieteticas::JSON)
        LOOP
            INSERT INTO producto_preferencia_dietetica(id_producto, id_preferencia, creado_por)
            VALUES (v_id_producto, v_id::UUID, p_creado_por);
        END LOOP;
    END IF;

    -- Insertar descuentos
    IF p_descuentos IS NOT NULL AND p_descuentos <> 'null' AND p_descuentos <> '' THEN
        FOR v_obj IN SELECT * FROM json_array_elements(p_descuentos::JSON)
        LOOP
            INSERT INTO descuento_producto(
                id_descuento, id_producto, tipo_descuento, valor,
                fecha_inicio, fecha_fin, es_activo, creado_por
            )
            VALUES (
                gen_random_uuid(), v_id_producto,
                (v_obj->>'TipoDescuento')::TEXT,
                (v_obj->>'Valor')::DECIMAL,
                (v_obj->>'FechaInicio')::TIMESTAMPTZ,
                (v_obj->>'FechaFin')::TIMESTAMPTZ,
                TRUE,
                p_creado_por
            );
        END LOOP;
    END IF;

    -- Insertar imágenes
    IF p_imagenes IS NOT NULL AND p_imagenes <> 'null' AND p_imagenes <> '' THEN
        FOR v_image IN SELECT * FROM json_array_elements(p_imagenes::JSON)
        LOOP
            INSERT INTO producto_imagen(
                id_imagen, id_producto, url_imagen, orden,
                es_principal, creado_por
            )
            VALUES (
                gen_random_uuid(), 
                v_id_producto,
                (v_image->>'Url')::TEXT,
                COALESCE((v_image->>'Orden')::SMALLINT, 1),
                COALESCE((v_image->>'EsPrincipal')::BOOLEAN, FALSE),
                p_creado_por
            );
        END LOOP;
    END IF;

    RETURN v_id_producto;
END;
$$ LANGUAGE plpgsql;



SELECT registrar_producto_con_relaciones(
    'Pizza Margarita 3', -- @Nombre
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
drop FUNCTION validar_y_aplicar_cupon
CREATE OR REPLACE FUNCTION validar_y_aplicar_cupon(
    codigo TEXT,
    total DECIMAL,
    id_usuario UUID
)
RETURNS TABLE (
    "Estado" BOOLEAN,
    "Mensaje" TEXT,
    "idCupon" UUID,
    "tipoDescuento" TEXT,
    "descuentoAplicado" DECIMAL,
    "totalConDescuento" DECIMAL
)
AS $$
DECLARE
    cupon_reg RECORD;
    descuento DECIMAL;
    total_descuento DECIMAL;
BEGIN
	SET TIME ZONE 'America/El_Salvador';
    -- Buscar cupón por código
    SELECT *
    INTO cupon_reg
    FROM cupon c
    WHERE c.codigo = validar_y_aplicar_cupon.codigo;

    -- Validación: cupón no encontrado
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Cupón no encontrado', NULL::UUID, NULL::TEXT, NULL::DECIMAL, NULL::DECIMAL;
        RETURN;
    END IF;

    -- Validación: inactivo
    IF NOT cupon_reg.es_activo THEN
        RETURN QUERY SELECT FALSE, 'El cupón no está activo', NULL::UUID, NULL::TEXT, NULL::DECIMAL, NULL::DECIMAL;
        RETURN;
    END IF;

    -- Validación: expirado
    IF cupon_reg.fecha_expiracion < NOW() THEN
        RETURN QUERY SELECT FALSE, 'El cupón ha expirado', NULL::UUID, NULL::TEXT, NULL::DECIMAL, NULL::DECIMAL;
        RETURN;
    END IF;

    -- Validación: límite de uso alcanzado
    IF cupon_reg.limite_uso IS NOT NULL THEN
        IF (
            SELECT COUNT(*) FROM pedido_cupon pc
            WHERE pc.id_cupon = cupon_reg.id_cupon
        ) >= cupon_reg.limite_uso THEN
            RETURN QUERY SELECT FALSE, 'El cupón ha alcanzado su límite de uso', NULL::UUID, NULL::TEXT, NULL::DECIMAL, NULL::DECIMAL;
            RETURN;
        END IF;
    END IF;

    -- Validación: el usuario ya usó el cupón
    IF EXISTS (
        SELECT 1
        FROM pedido_cupon pc
        INNER JOIN pedido p ON p.id_pedido = pc.id_pedido
        WHERE pc.id_cupon = cupon_reg.id_cupon
        AND p.id_usuario = validar_y_aplicar_cupon.id_usuario
    ) THEN
        RETURN QUERY SELECT FALSE, 'El usuario ya ha usado este cupón', NULL::UUID, NULL::TEXT, NULL::DECIMAL, NULL::DECIMAL;
        RETURN;
    END IF;

    -- Aplicar descuento
    IF cupon_reg.tipo_descuento = 'fijo' THEN
        descuento := cupon_reg.descuento;
        total_descuento := GREATEST(0, total - descuento);
        RETURN QUERY SELECT TRUE, 'Cupón válido', cupon_reg.id_cupon, cupon_reg.tipo_descuento, descuento, total_descuento;
    ELSIF cupon_reg.tipo_descuento = 'porcentaje' THEN
        descuento := total * (cupon_reg.descuento / 100);
        total_descuento := GREATEST(0, total - descuento);
        RETURN QUERY SELECT TRUE, 'Cupón válido', cupon_reg.id_cupon, cupon_reg.tipo_descuento, descuento, total_descuento;
    ELSE
        RETURN QUERY SELECT FALSE, 'Tipo de descuento no válido', NULL::UUID, NULL::TEXT, NULL::DECIMAL, NULL::DECIMAL;
        RETURN;
    END IF;
END;
$$ LANGUAGE plpgsql;
SHOW timezone;

select * from validar_y_aplicar_cupon('NEWDATE', 20, '5b4197bb-a13e-4e08-a6e9-9705a96be22d')



SELECT * FROM validar_y_aplicar_cupon(
  'PROMO2025',                          -- código del cupón
  13.19,                           -- total de la compra
  '1d2fda2e-2a9d-4e0a-a932-4a51748a3fd7' -- id del usuario
);

CREATE OR REPLACE FUNCTION modificar_producto_con_relaciones(
    p_id_producto UUID,
    p_nombre TEXT,
    p_descripcion TEXT,
    p_precio NUMERIC,
    p_url_modelo_3d TEXT,
    p_calorias INTEGER,
    p_actualizado_por TEXT,
    p_categorias TEXT,
    p_ingredientes TEXT,
    p_alergenos TEXT,
    p_preferencias_dieteticas TEXT,
    p_imagenes TEXT,
    p_descuentos TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_id UUID;
    v_obj JSON;
    v_image JSON;
BEGIN
    UPDATE producto
    SET nombre = p_nombre,
        descripcion = p_descripcion,
        precio = p_precio,
        url_modelo_3d = p_url_modelo_3d,
        calorias = p_calorias,
        actualizado_por = p_actualizado_por,
        fecha_actualizacion = now()
    WHERE id_producto = p_id_producto;

    -- Limpiar relaciones existentes
    DELETE FROM producto_categoria WHERE id_producto = p_id_producto;
    DELETE FROM producto_ingrediente WHERE id_producto = p_id_producto;
    DELETE FROM producto_alergeno WHERE id_producto = p_id_producto;
    DELETE FROM producto_preferencia_dietetica WHERE id_producto = p_id_producto;
    DELETE FROM descuento_producto WHERE id_producto = p_id_producto;
    DELETE FROM producto_imagen WHERE id_producto = p_id_producto;

    -- Insertar categorías
    IF p_categorias IS NOT NULL AND p_categorias <> 'null' AND p_categorias <> '' THEN
        FOR v_id IN SELECT json_array_elements_text(p_categorias::JSON)
        LOOP
            INSERT INTO producto_categoria(id_producto, id_categoria, creado_por)
            VALUES (p_id_producto, v_id::UUID, p_actualizado_por);
        END LOOP;
    END IF;

    -- Insertar ingredientes
    IF p_ingredientes IS NOT NULL AND p_ingredientes <> 'null' AND p_ingredientes <> '' THEN
        FOR v_id IN SELECT json_array_elements_text(p_ingredientes::JSON)
        LOOP
            INSERT INTO producto_ingrediente(id_producto, id_ingrediente, creado_por)
            VALUES (p_id_producto, v_id::UUID, p_actualizado_por);
        END LOOP;
    END IF;

    -- Insertar alérgenos
    IF p_alergenos IS NOT NULL AND p_alergenos <> 'null' AND p_alergenos <> '' THEN
        FOR v_id IN SELECT json_array_elements_text(p_alergenos::JSON)
        LOOP
            INSERT INTO producto_alergeno(id_producto, id_alergeno, creado_por)
            VALUES (p_id_producto, v_id::UUID, p_actualizado_por);
        END LOOP;
    END IF;

    -- Insertar preferencias dietéticas
    IF p_preferencias_dieteticas IS NOT NULL AND p_preferencias_dieteticas <> 'null' AND p_preferencias_dieteticas <> '' THEN
        FOR v_id IN SELECT json_array_elements_text(p_preferencias_dieteticas::JSON)
        LOOP
            INSERT INTO producto_preferencia_dietetica(id_producto, id_preferencia, creado_por)
            VALUES (p_id_producto, v_id::UUID, p_actualizado_por);
        END LOOP;
    END IF;

    -- Insertar descuentos
    IF p_descuentos IS NOT NULL AND p_descuentos <> 'null' AND p_descuentos <> '' THEN
        FOR v_obj IN SELECT * FROM json_array_elements(p_descuentos::JSON)
        LOOP
            INSERT INTO descuento_producto(
                id_descuento, id_producto, tipo_descuento, valor,
                fecha_inicio, fecha_fin, es_activo, creado_por
            )
            VALUES (
                gen_random_uuid(), p_id_producto,
                (v_obj->>'TipoDescuento')::TEXT,
                (v_obj->>'Valor')::DECIMAL,
                (v_obj->>'FechaInicio')::TIMESTAMPTZ,
                (v_obj->>'FechaFin')::TIMESTAMPTZ,
                TRUE,
                p_actualizado_por
            );
        END LOOP;
    END IF;

    -- Insertar imágenes
    IF p_imagenes IS NOT NULL AND p_imagenes <> 'null' AND p_imagenes <> '' THEN
        FOR v_image IN SELECT * FROM json_array_elements(p_imagenes::JSON)
        LOOP
            INSERT INTO producto_imagen(
                id_imagen, id_producto, url_imagen, orden,
                es_principal, creado_por
            )
            VALUES (
                gen_random_uuid(),
                p_id_producto,
                (v_image->>'Url')::TEXT,
                COALESCE((v_image->>'Orden')::SMALLINT, 1),
                COALESCE((v_image->>'EsPrincipal')::BOOLEAN, FALSE),
                p_actualizado_por
            );
        END LOOP;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

SELECT nombre,pi2.* FROM public.producto_imagen AS pi2
inner join producto p on pi2.id_producto = p.id_producto


-- Update statements for producto_imagen table
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Pollo%20en%20salsa%20cilantro.jpg' WHERE id_imagen = '8dded38a-f8fe-4fca-837c-a45960bea143';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Pollo%20en%20salsa%20cilantro.jpg' WHERE id_imagen = '1383a9f2-2c78-4d42-8eb3-dbc02a53d21a';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Sopa%20de%20frijoles%20con%20carne%20de%20cerdo.jpg' WHERE id_imagen = '298f198c-3fa7-4619-bbd9-b42015c5dcf7';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Sopa%20de%20frijoles%20con%20carne%20de%20cerdo.jpg' WHERE id_imagen = '7db38c67-49e7-48b6-9ec1-280c8289919f';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Pupusas.jpg' WHERE id_imagen = '148d8385-e197-477c-93bd-08337aec85c2';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Pupusas.jpg' WHERE id_imagen = '38b2832e-9ced-4435-ad73-503661f3952b';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Pollo%20en%20salsa%20cilantro.jpg' WHERE id_imagen = '53330326-47b0-446a-8a8a-9b0e7f39d5fe';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Pollo%20en%20salsa%20cilantro.jpg' WHERE id_imagen = '2f49964a-913a-441b-9274-b7aacc4f4eac';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Costillas%20a%20la%20barbacoa%20jugosas.jpg' WHERE id_imagen = '1eee1c15-76d1-4723-9e0f-6424388895ed';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Costillas%20a%20la%20barbacoa%20jugosas.jpg' WHERE id_imagen = '09487467-549e-4a69-baa2-4e06b39cbfb0';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Pasta%20corta%20en%20salsa%20blanco.jpg' WHERE id_imagen = '323bfcf6-5be0-4cde-a75f-1570afae0b5c';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Pasta%20corta%20en%20salsa%20blanco.jpg' WHERE id_imagen = '1eeaa8a5-e2cd-42ee-8837-0f5ee45ae085';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Chilaquilas.jpg' WHERE id_imagen = 'd3a9b6d0-58f5-4ed9-b7a1-16120cc14291';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Chilaquilas.jpg' WHERE id_imagen = '0bb60510-3de0-4efe-9bb6-1081d6d62269';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Sopa%20de%20frijoles%20con%20carne%20de%20cerdo.jpg' WHERE id_imagen = 'ccda22ec-8ca7-490a-85a3-c1a0c6575777';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Sopa%20de%20frijoles%20con%20carne%20de%20cerdo.jpg' WHERE id_imagen = '7bdc4b49-133d-4116-b2e2-7b31025bdee4';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Atol%20de%20pin%CC%83a.jpg' WHERE id_imagen = 'd1587111-f535-40b9-9d02-3085840e11b6';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Atol%20de%20pin%CC%83a.jpg' WHERE id_imagen = 'fb84db78-987b-415e-a6a3-e5911a1f4117';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Pupusas.jpg' WHERE id_imagen = '0644d03e-4ed1-4c11-80d5-d8281bdd5ae8';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Pupusas.jpg' WHERE id_imagen = '3599194f-e4e5-4f3c-87ab-478406369860';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Pastelitos%20de%20res.jpg' WHERE id_imagen = '1626b7a0-2999-4a7d-a4ec-cfa1c5f6621b';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Pastelitos%20de%20res.jpg' WHERE id_imagen = 'f3aa510d-5e28-4968-8fcb-4beb9eb6400f';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Yuca%20salcochada.jpg' WHERE id_imagen = '94a3e1d5-f686-4b06-9834-f760a5ea643f';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Yuca%20salcochada.jpg' WHERE id_imagen = '6aac14d2-487e-4318-b7c5-7ec81e3baa4e';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Arroz%20en%20leche.jpg' WHERE id_imagen = 'e9199f84-efb0-44df-a60a-aaec7dafb19f';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Arroz%20en%20leche.jpg' WHERE id_imagen = 'ecb02670-f141-434f-876a-5e91d270a59b';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Canoas.jpg' WHERE id_imagen = 'f0471c11-a499-449c-b9b8-3a25f1ad91a2';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Canoas.jpg' WHERE id_imagen = '79aa5420-5b87-49c1-a508-e129f8b87244';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Fajitas%20de%20cerdo.jpg' WHERE id_imagen = 'd3aa5e16-e422-4ad9-8488-54147062a182';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Fajitas%20de%20cerdo.jpg' WHERE id_imagen = '429cd1c8-1051-45ca-b2a0-0a259de842c8';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Lomo%20de%20cerdo%20en%20Barbacoa.jpg' WHERE id_imagen = 'e70a5cdc-ea92-464d-ba89-59154b1bc061';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Lomo%20de%20cerdo%20en%20Barbacoa.jpg' WHERE id_imagen = 'fe963d4e-6131-47e9-9c74-20652c8f974a';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Alitas%20Chipotle.jpg' WHERE id_imagen = '60ffd13c-8737-4131-9ee6-c3c149f831dd';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Alitas%20Chipotle.jpg' WHERE id_imagen = 'd59c90d6-c2c8-4d37-824e-dfde774cfb91';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Papas%20rellenas.jpg' WHERE id_imagen = 'faa2378f-a7f8-410c-bf5d-b1e1c18c90bb';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Papas%20rellenas.jpg' WHERE id_imagen = 'b6c24e77-930a-4435-bd3b-d255b406d0d8';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Sopa%20de%20pollo.jpg' WHERE id_imagen = 'a22e94b4-7a63-4248-a800-f123f7185148';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Sopa%20de%20pollo.jpg' WHERE id_imagen = '03e6d1cd-57fa-4f59-875f-285e04b35dd1';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Filete%20de%20res%20en%20salsa%20de%20hongos.jpg' WHERE id_imagen = '7b721657-8aaa-452c-8566-0796c5a0c21a';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Filete%20de%20res%20en%20salsa%20de%20hongos.jpg' WHERE id_imagen = '9fe204eb-30dc-484e-91d2-4459297373bd';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Crema%20de%20tomate.jpg' WHERE id_imagen = '14e3af76-84af-42f9-8ed7-498f4ebd48b5';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Crema%20de%20tomate.jpg' WHERE id_imagen = '079bda86-2fcc-4005-800a-b82121ab5521';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Lasan%CC%83a%20de%20Res.png' WHERE id_imagen = '4c66a618-5309-4565-a7d9-65369e1d74dc';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Lasan%CC%83a%20de%20Res.png' WHERE id_imagen = '83b86329-e094-4fbb-a4dd-8ba020cf98c4';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Canoas.jpg' WHERE id_imagen = '8e5d758e-666e-486d-b8de-b36df424d0b1';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Canoas.jpg' WHERE id_imagen = '8e52a19f-ecb8-4e02-8482-20a8d0c9a0d8';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/porcion-de-lasana-de-pollo.jpg' WHERE id_imagen = 'dc28d772-62ea-425a-b543-3870d9f3df59';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/porcion-de-lasana-de-pollo.jpg' WHERE id_imagen = '7d7591c1-f4ba-44a5-a516-f09b933ddd20';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Alitas%20Chipotle.jpg' WHERE id_imagen = '314fde28-b8fc-4813-8803-8525b190283e';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Alitas%20Chipotle.jpg' WHERE id_imagen = '1abbfdf2-dcc1-484b-ba67-c205b4e7e450';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Torta%20mexicana%20de%20pollo.jpg' WHERE id_imagen = 'c6467aee-8e5d-4174-a557-49aec46ece91';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Torta%20mexicana%20de%20pollo.jpg' WHERE id_imagen = '3ff0c750-67d0-446f-bbd3-3260425497db';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Sopa%20de%20pollo.jpg' WHERE id_imagen = 'ec5ec50f-d93f-4127-bee6-fe3bffdd4e1d';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Sopa%20de%20pollo.jpg' WHERE id_imagen = '13625205-2c9c-447d-b487-b7989a134475';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Nuegados%20de%20yuca.jpg' WHERE id_imagen = '0f39f4e4-a405-45a5-9deb-43d52247bbb6';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Nuegados%20de%20yuca.jpg' WHERE id_imagen = '414a6f53-09c2-4e75-9ec4-d058ddcf87de';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Arroz%20en%20leche.jpg' WHERE id_imagen = '501056ce-5d2e-4c13-9384-a7e00f64cd31';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Arroz%20en%20leche.jpg' WHERE id_imagen = 'fd1020d2-eb8e-4ccf-b330-bad161e12711';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Canoas.jpg' WHERE id_imagen = 'c6faba8b-9a9a-4d36-b54c-ff0967949172';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Canoas.jpg' WHERE id_imagen = 'dcb4c6ec-2d48-4b9c-8fda-9f8978b46705';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Arroz%20en%20leche.jpg' WHERE id_imagen = 'c1f546c8-50b8-4f3c-bb94-e26ecf34ba06';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/Arroz%20en%20leche.jpg' WHERE id_imagen = '60845247-8d88-4039-8108-ecbc67cc3e6f';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/porcion-de-lasana-de-pollo.jpg' WHERE id_imagen = '1f98a879-138a-4b27-8a9f-dedf7783eae5';
UPDATE producto_imagen SET url_imagen = 'https://pedidosdigitalesblob.blob.core.windows.net/productos-default/porcion-de-lasana-de-pollo.jpg' WHERE id_imagen = 'ee378386-394b-444c-97d0-5c0a655d177d';



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
                            tiempo_transcurrido as TiempoTranscurrido,
                            (select promedio_hoy from public.calcular_promedios_preparacion() as promedio)
                        FROM obtener_detalle_pedido('d88f2478-af86-49fe-bdf9-e747c00c52b9')
                        
                        select * from public.calcular_promedios_preparacion() as promedio
                        
                        
 select * from producto                       
 UPDATE producto
 SET es_activo=true, fecha_actualizacion=NULL, actualizado_por=NULL
 WHERE id_producto='bfaa26d9-6a8f-4855-8ec9-130906e8d2bc'::uuid;  
 
 
 SELECT * FROM pg_stat_activity;
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'CafeteriaBeta'
  AND pid <> pg_backend_pid();
 
 SELECT idpedido AS IdPedido, tiempoestimado AS TiempoEstimado FROM obtener_etas_pedidos()
 
 
 SELECT 
                    p.id_pedido as IdPedido,
                    p.numero_pedido as NumeroPedido,
                    COALESCE(p.creado_por, 'Cliente No Identificado') as Cliente,
                    (SELECT email
					FROM user_entity where id::uuid = p.id_usuario::uuid) as Correo,
                    hep.estado  as EstadoActual,
                    p.metodo_pago as MetodoPago,
                    p.total as Total,
                    p.fecha_creacion as FechaCreacion
                FROM pedido p
                LEFT JOIN (
                    SELECT 
                        id_pedido,
                        estado,
                        ROW_NUMBER() OVER (PARTITION BY id_pedido ORDER BY fecha_creacion DESC) as rn
                    FROM historial_estado_pedido
                ) hep ON p.id_pedido = hep.id_pedido AND hep.rn = 1
                ORDER BY p.fecha_creacion DESC

 -- En tu base de datos actual
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Crear el servidor remoto
CREATE SERVER keycloak_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (
    host 'db-postgresql-nyc3-99023-do-user-18706657-0.k.db.ondigitalocean.com',
    dbname 'keycloak',
    port '25060',
    sslmode 'require'  -- 🔒 DigitalOcean requiere SSL
);

-- Crear el mapeo de usuario
CREATE USER MAPPING FOR CURRENT_USER
SERVER keycloak_server
OPTIONS (user 'doadmin', password 'AVNS_Jv9mcVOk_LozcflpjrN');

-- Importar la tabla
IMPORT FOREIGN SCHEMA public
FROM SERVER keycloak_server
INTO public;
               
DROP SERVER IF EXISTS keycloak_server CASCADE;
SELECT * FROM user_entity;
select * from saldo_usuario;


CREATE OR REPLACE FUNCTION eliminar_producto_completo(p_id_producto UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Eliminar en orden inverso de dependencias
    DELETE FROM producto_imagen WHERE id_producto = p_id_producto;
    DELETE FROM descuento_producto WHERE id_producto = p_id_producto;
    DELETE FROM producto_preferencia_dietetica WHERE id_producto = p_id_producto;
    DELETE FROM producto_alergeno WHERE id_producto = p_id_producto;
    DELETE FROM producto_ingrediente WHERE id_producto = p_id_producto;
    DELETE FROM producto_categoria WHERE id_producto = p_id_producto;
    
    -- Opcional: Si no quieres eliminar pedidos, solo actualiza a NULL
    -- UPDATE detalle_pedido SET id_producto = NULL WHERE id_producto = p_id_producto;
    
    -- O si quieres eliminar los detalles del pedido también:
    -- DELETE FROM detalle_pedido WHERE id_producto = p_id_producto;
    
    -- Finalmente, eliminar el producto
    DELETE FROM producto WHERE id_producto = p_id_producto;
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error al eliminar producto: %', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

WITH ultimo_estado AS (
                    SELECT DISTINCT ON (id_pedido)
                        id_pedido,
                        estado,
                        fecha_creacion
                    FROM historial_estado_pedido
                    ORDER BY id_pedido, fecha_creacion DESC
                )
                SELECT 
                    p.id_pedido,
                      (SELECT first_name || ' ' || last_name 
					   FROM user_entity where id::uuid = p.id_usuario::uuid) AS nombre_cliente,
                    ue.estado,
                    p.fecha_creacion,
                    p.total
                FROM pedido p
                INNER JOIN ultimo_estado ue ON p.id_pedido = ue.id_pedido
                WHERE p.fecha_creacion >= CURRENT_DATE
                ORDER BY p.fecha_creacion DESC
                LIMIT 4
                
SELECT 
                    p.numero_pedido as NumeroPedido,
                    (SELECT first_name || ' ' || last_name 
					   FROM user_entity where id::uuid = p.id_usuario::uuid) as Cliente,
                    hep.estado as Estado,
                    p.metodo_pago as MetodoPago,
                    p.fecha_creacion as FechaCreacion,
                    COALESCE(p.fecha_actualizacion, p.fecha_creacion) as UltimaActualizacion,
                    p.total_con_descuento as Total
                FROM pedido p
                LEFT JOIN (
                    SELECT 
                        id_pedido,
                        estado,
                        ROW_NUMBER() OVER (PARTITION BY id_pedido ORDER BY fecha_creacion DESC) as rn
                    FROM historial_estado_pedido
                ) hep ON p.id_pedido = hep.id_pedido AND hep.rn = 1
                WHERE p.numero_pedido = @NumeroPedido";

                    var pedido = await _conexionDb.QueryFirstOrDefaultAsync<DetalleOrden>(
                        sqlPedido, new { NumeroPedido = numeroPedido });

                    if (pedido == null)
                        return;

                    // Obtener productos del pedido
                    string sqlProductos = @"
                SELECT 
                    pr.nombre as Nombre,
                    pr.descripcion as Descripcion,
                    COALESCE(pi.url_imagen, '') as UrlImagenPrincipal,
                    dp.cantidad as Cantidad,
                    dp.precio_unitario as PrecioUnitario,
                    (dp.cantidad * dp.precio_unitario) as Subtotal
                FROM detalle_pedido dp
                INNER JOIN pedido p ON dp.id_pedido = p.id_pedido
                INNER JOIN producto pr ON dp.id_producto = pr.id_producto
                LEFT JOIN (
                    SELECT 
                        id_producto,
                        url_imagen,
                        ROW_NUMBER() OVER (PARTITION BY id_producto ORDER BY 
                            CASE WHEN es_principal THEN 1 ELSE 2 END, orden ASC) as rn
                    FROM producto_imagen
                ) pi ON pr.id_producto = pi.id_producto AND pi.rn = 1
                WHERE p.numero_pedido = @NumeroPedido
                ORDER BY dp.fecha_creacion                
                
  SELECT first_name || ' ' || last_name AS nombre_completo
FROM user_entity;              
  SELECT first_name + last_name  FROM user_entity              
  
drop function obtener_dashboard_completo()
CREATE OR REPLACE FUNCTION obtener_dashboard_completo()
RETURNS TABLE (
    tipo_dato TEXT,
    datos_json JSONB
) AS $$
BEGIN
    RETURN QUERY
    WITH periodos AS (
        SELECT 
            CURRENT_DATE AT TIME ZONE 'America/El_Salvador' as hoy,
            (CURRENT_DATE - INTERVAL '7 days') AT TIME ZONE 'America/El_Salvador' as inicio_semana,
            (CURRENT_DATE - INTERVAL '30 days') AT TIME ZONE 'America/El_Salvador' as inicio_mes
    ),
    pedidos_con_estado AS (
        SELECT 
            p.*,
            ue.estado as estado_actual,
            ue.fecha_creacion as fecha_estado
        FROM pedido p
        INNER JOIN LATERAL (
            SELECT estado, fecha_creacion
            FROM historial_estado_pedido
            WHERE id_pedido = p.id_pedido
            ORDER BY fecha_creacion DESC
            LIMIT 1
        ) ue ON true
        WHERE p.fecha_creacion >= (SELECT inicio_mes FROM periodos)
    ),
    estadisticas AS (
        SELECT jsonb_build_object(
            'ventaDia', COALESCE(SUM(CASE WHEN fecha_creacion >= (SELECT hoy FROM periodos) THEN total_con_descuento END), 0),
            'ordenDia', COUNT(CASE WHEN fecha_creacion >= (SELECT hoy FROM periodos) THEN 1 END),
            'clienteDia', COUNT(DISTINCT CASE WHEN fecha_creacion >= (SELECT hoy FROM periodos) THEN id_usuario END),
            'ventaSemana', COALESCE(SUM(CASE WHEN fecha_creacion >= (SELECT inicio_semana FROM periodos) THEN total_con_descuento END), 0),
            'ordenSemana', COUNT(CASE WHEN fecha_creacion >= (SELECT inicio_semana FROM periodos) THEN 1 END),
            'clienteSemana', COUNT(DISTINCT CASE WHEN fecha_creacion >= (SELECT inicio_semana FROM periodos) THEN id_usuario END),
            'ventaMes', COALESCE(SUM(CASE WHEN fecha_creacion >= (SELECT inicio_mes FROM periodos) THEN total_con_descuento END), 0),
            'ordenMes', COUNT(CASE WHEN fecha_creacion >= (SELECT inicio_mes FROM periodos) THEN 1 END),
            'clienteMes', COUNT(DISTINCT CASE WHEN fecha_creacion >= (SELECT inicio_mes FROM periodos) THEN id_usuario END)
        ) as resultado
        FROM pedidos_con_estado
    ),
    sumatoria_ordenes AS (
        SELECT jsonb_build_object(
            'pendienteHoy', COUNT(CASE WHEN estado_actual = 'Pendiente' AND fecha_creacion >= (SELECT hoy FROM periodos) THEN 1 END),
            'recibidoHoy', COUNT(CASE WHEN estado_actual = 'Recibido' AND fecha_creacion >= (SELECT hoy FROM periodos) THEN 1 END),
            'preparandoHoy', COUNT(CASE WHEN estado_actual = 'Preparando' AND fecha_creacion >= (SELECT hoy FROM periodos) THEN 1 END),
            'listoHoy', COUNT(CASE WHEN estado_actual = 'Listo' AND fecha_creacion >= (SELECT hoy FROM periodos) THEN 1 END),
            'completadoHoy', COUNT(CASE WHEN estado_actual = 'Entregado' AND fecha_creacion >= (SELECT hoy FROM periodos) THEN 1 END),
            'pendienteSemana', COUNT(CASE WHEN estado_actual = 'Pendiente' AND fecha_creacion >= (SELECT inicio_semana FROM periodos) THEN 1 END),
            'recibidoSemana', COUNT(CASE WHEN estado_actual = 'Recibido' AND fecha_creacion >= (SELECT inicio_semana FROM periodos) THEN 1 END),
            'preparandoSemana', COUNT(CASE WHEN estado_actual = 'Preparando' AND fecha_creacion >= (SELECT inicio_semana FROM periodos) THEN 1 END),
            'listoSemana', COUNT(CASE WHEN estado_actual = 'Listo' AND fecha_creacion >= (SELECT inicio_semana FROM periodos) THEN 1 END),
            'completadoSemana', COUNT(CASE WHEN estado_actual = 'Entregado' AND fecha_creacion >= (SELECT inicio_semana FROM periodos) THEN 1 END),
            'pendienteMes', COUNT(CASE WHEN estado_actual = 'Pendiente' AND fecha_creacion >= (SELECT inicio_mes FROM periodos) THEN 1 END),
            'recibidoMes', COUNT(CASE WHEN estado_actual = 'Recibido' AND fecha_creacion >= (SELECT inicio_mes FROM periodos) THEN 1 END),
            'preparandoMes', COUNT(CASE WHEN estado_actual = 'Preparando' AND fecha_creacion >= (SELECT inicio_mes FROM periodos) THEN 1 END),
            'listoMes', COUNT(CASE WHEN estado_actual = 'Listo' AND fecha_creacion >= (SELECT inicio_mes FROM periodos) THEN 1 END),
            'completadoMes', COUNT(CASE WHEN estado_actual = 'Entregado' AND fecha_creacion >= (SELECT inicio_mes FROM periodos) THEN 1 END)
        ) as resultado
        FROM pedidos_con_estado
    ),
    ventas_por_periodo AS (
        WITH horas_dia AS (
            SELECT 
                rango,
                hora_inicio,
                COALESCE(SUM(total), 0) as total
            FROM (
                VALUES 
                    ('12am-2am', 0),
                    ('2am-4am', 2),
                    ('4am-6am', 4),
                    ('6am-8am', 6),
                    ('8am-10am', 8),
                    ('10am-12pm', 10),
                    ('12pm-2pm', 12),
                    ('2pm-4pm', 14),
                    ('4pm-6pm', 16),
                    ('6pm-8pm', 18),
                    ('8pm-10pm', 20),
                    ('10pm-12am', 22)
            ) AS rangos(rango, hora_inicio)
            LEFT JOIN (
                SELECT 
                    EXTRACT(HOUR FROM fecha_creacion AT TIME ZONE 'America/El_Salvador')::int as hora,
                    total_con_descuento as total
                FROM pedido
                WHERE DATE(fecha_creacion AT TIME ZONE 'America/El_Salvador') = CURRENT_DATE
            ) p ON p.hora >= rangos.hora_inicio AND p.hora < rangos.hora_inicio + 2
            GROUP BY rango, hora_inicio
            ORDER BY hora_inicio
        ),
        dias_semana AS (
            SELECT 
                dia_nombre,
                dia_num,
                COALESCE(total, 0) as total
            FROM (
                VALUES 
                    ('Dom', 0),
                    ('Lun', 1),
                    ('Mar', 2),
                    ('Mié', 3),
                    ('Jue', 4),
                    ('Vie', 5),
                    ('Sáb', 6)
            ) AS dias(dia_nombre, dia_num)
            LEFT JOIN (
                SELECT 
                    EXTRACT(DOW FROM fecha_creacion AT TIME ZONE 'America/El_Salvador')::int as dia_semana,
                    SUM(total_con_descuento) as total
                FROM pedido
                WHERE fecha_creacion AT TIME ZONE 'America/El_Salvador' >= CURRENT_DATE - INTERVAL '6 days'
                    AND fecha_creacion AT TIME ZONE 'America/El_Salvador' < CURRENT_DATE + INTERVAL '1 day'
                GROUP BY EXTRACT(DOW FROM fecha_creacion AT TIME ZONE 'America/El_Salvador')
            ) p ON p.dia_semana = dias.dia_num
            ORDER BY dia_num
        ),
        semanas_mes AS (
            SELECT 
                'Sem ' || (ROW_NUMBER() OVER (ORDER BY semana_inicio))::text as semana_label,
                COALESCE(SUM(total_con_descuento), 0) as total
            FROM (
                SELECT 
                    DATE_TRUNC('week', generate_series(
                        DATE_TRUNC('month', CURRENT_DATE AT TIME ZONE 'America/El_Salvador'),
                        DATE_TRUNC('month', CURRENT_DATE AT TIME ZONE 'America/El_Salvador') + INTERVAL '1 month' - INTERVAL '1 day',
                        '1 week'::interval
                    )) as semana_inicio
            ) semanas
            LEFT JOIN pedido p ON DATE_TRUNC('week', p.fecha_creacion AT TIME ZONE 'America/El_Salvador') = semanas.semana_inicio
                AND p.fecha_creacion AT TIME ZONE 'America/El_Salvador' >= DATE_TRUNC('month', CURRENT_DATE)
                AND p.fecha_creacion AT TIME ZONE 'America/El_Salvador' < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
            GROUP BY semanas.semana_inicio
            ORDER BY semanas.semana_inicio
        )
        SELECT jsonb_build_object(
            'day', jsonb_build_object(
                'labels', (SELECT jsonb_agg(rango ORDER BY hora_inicio) FROM horas_dia),
                'data', (SELECT jsonb_agg(total ORDER BY hora_inicio) FROM horas_dia)
            ),
            'week', jsonb_build_object(
                'labels', (SELECT jsonb_agg(dia_nombre ORDER BY dia_num) FROM dias_semana),
                'data', (SELECT jsonb_agg(total ORDER BY dia_num) FROM dias_semana)
            ),
            'month', jsonb_build_object(
                'labels', (SELECT jsonb_agg(semana_label) FROM semanas_mes),
                'data', (SELECT jsonb_agg(total) FROM semanas_mes)
            )
        ) as resultado
    ),
    productos_populares AS (
        SELECT jsonb_agg(
            jsonb_build_object(
                'idProducto', id_producto,
                'nombre', nombre,
                'urlImagen', url_imagen,
                'totalVentas', total_ventas,
                'porcentajeCambio', porcentaje_cambio
            ) ORDER BY total_ventas DESC
        ) as resultado
        FROM (
            SELECT 
                p.id_producto,
                p.nombre,
                COALESCE(pi.url_imagen, '') as url_imagen,
                COUNT(DISTINCT dp.id_pedido)::int as total_ventas,
                0::numeric as porcentaje_cambio
            FROM producto p
            INNER JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
            INNER JOIN pedido ped ON dp.id_pedido = ped.id_pedido
            LEFT JOIN producto_imagen pi ON p.id_producto = pi.id_producto AND pi.es_principal = true
            WHERE ped.fecha_creacion >= CURRENT_DATE - INTERVAL '30 days'
                AND p.es_activo = true
            GROUP BY p.id_producto, p.nombre, pi.url_imagen
            ORDER BY total_ventas DESC
            LIMIT 4
        ) t
    ),
    ordenes_recientes AS (
        SELECT jsonb_agg(
            jsonb_build_object(
                'idPedido', id_pedido,
                'nombreCliente', nombre_cliente,
                'estado', estado_actual,
                'fechaCreacion', fecha_creacion,
                'total', total
            ) ORDER BY fecha_creacion DESC
        ) as resultado
        FROM (
            SELECT 
                p.id_pedido,
                COALESCE(u.first_name || ' ' || u.last_name, 'Cliente') as nombre_cliente,
                p.estado_actual,
                p.fecha_creacion,
                p.total
            FROM pedidos_con_estado p
            LEFT JOIN user_entity u ON u.id::uuid = p.id_usuario
            WHERE p.fecha_creacion >= CURRENT_DATE
            ORDER BY p.fecha_creacion DESC
            LIMIT 4
        ) t
    )
    -- Retornar todos los resultados
    SELECT 'clientesVentasOrdenes'::TEXT, resultado FROM estadisticas
    UNION ALL
    SELECT 'sumatoriaOrdenes'::TEXT, resultado FROM sumatoria_ordenes
    UNION ALL
    SELECT 'ventasPorPeriodo'::TEXT, resultado FROM ventas_por_periodo
    UNION ALL
    SELECT 'productosPopulares'::TEXT, resultado FROM productos_populares
    UNION ALL
    SELECT 'ordenesRecientes'::TEXT, resultado FROM ordenes_recientes;
END;
$$ LANGUAGE plpgsql;
  
SELECT tipo_dato, datos_json FROM obtener_dashboard_completo()
  
  SELECT EXISTS (
    SELECT 1
    FROM pedido_cupon pc
    INNER JOIN pedido p ON pc.id_pedido = p.id_pedido
    INNER JOIN cupon c ON pc.id_cupon = c.id_cupon
    WHERE p.id_usuario = '883a5449-0e53-4186-8b03-84d4d3ee936d'::uuid
      AND c.codigo = 'PRUEBAFORMATO'
) as ya_uso_cupon;
  
WITH uso_cupon AS (
    SELECT 
        c.id_cupon,
        c.codigo,
        c.limite_uso,
        COUNT(pc.id_pedido_cupon) as veces_usado_total,
        COUNT(CASE WHEN p.id_usuario = '883a5449-0e53-4186-8b03-84d4d3ee936d'::uuid THEN 1 END) as veces_usado_por_usuario
    FROM cupon c
    LEFT JOIN pedido_cupon pc ON c.id_cupon = pc.id_cupon
    LEFT JOIN pedido p ON pc.id_pedido = p.id_pedido
    WHERE c.codigo = 'PRUEBAFORMATO'
    GROUP BY c.id_cupon, c.codigo, c.limite_uso
)
SELECT 
    codigo,
    limite_uso,
    veces_usado_total,
    veces_usado_por_usuario,
    CASE 
        WHEN veces_usado_por_usuario > 0 THEN true
        ELSE false
    END as usuario_ya_uso_cupon,
    CASE 
        WHEN limite_uso IS NULL THEN true
        WHEN veces_usado_total < limite_uso THEN true
        ELSE false
    END as cupon_aun_disponible
FROM uso_cupon;

WITH uso_cupon AS (
    SELECT 
        c.id_cupon,
        c.codigo,
        c.descuento,
        c.tipo_descuento,
        c.limite_uso,
        c.es_activo,
        c.fecha_expiracion,
        COUNT(pc.id_pedido_cupon) as veces_usado_total,
        COUNT(CASE WHEN p.id_usuario = '883a5449-0e53-4186-8b03-84d4d3ee936d'::uuid THEN 1 END) as veces_usado_por_usuario
    FROM cupon c
    LEFT JOIN pedido_cupon pc ON c.id_cupon = pc.id_cupon
    LEFT JOIN pedido p ON pc.id_pedido = p.id_pedido
    WHERE c.codigo = 'PRUEBAFORMATO'
    GROUP BY c.id_cupon, c.codigo, c.descuento, c.tipo_descuento, c.limite_uso, c.es_activo, c.fecha_expiracion
)
SELECT 
    codigo,
    descuento,
    tipo_descuento,
    limite_uso,
    veces_usado_total,
    veces_usado_por_usuario,
    -- Validaciones
    CASE 
        WHEN veces_usado_por_usuario > 0 THEN false  -- Usuario ya usó el cupón
        WHEN NOT es_activo THEN false                -- Cupón inactivo
        WHEN fecha_expiracion < now() THEN false     -- Cupón expirado
        WHEN limite_uso IS NOT NULL AND veces_usado_total >= limite_uso THEN false  -- Límite global alcanzado
        ELSE true
    END as puede_usar_cupon,
    -- Mensaje descriptivo
    CASE 
        WHEN veces_usado_por_usuario > 0 THEN 'Ya has utilizado este cupón anteriormente'
        WHEN NOT es_activo THEN 'El cupón no está activo'
        WHEN fecha_expiracion < now() THEN 'El cupón ha expirado'
        WHEN limite_uso IS NOT NULL AND veces_usado_total >= limite_uso THEN 'El cupón ha alcanzado su límite de uso'
        ELSE 'Cupón válido y disponible'
    END as mensaje
FROM uso_cupon;


SELECT 
    c.id_cupon AS IdCupon,
    c.codigo AS Codigo,
    c.descuento AS Descuento,
    c.tipo_descuento AS TipoDescuento,
    c.fecha_expiracion AS FechaExpiracion,
    c.limite_uso AS LimiteUso,
    c.es_activo AS EsActivo,
    c.fecha_creacion AS FechaCreacion,
    c.creado_por AS CreadoPor,
    c.fecha_actualizacion AS FechaActualizacion,
    c.actualizado_por AS ActualizadoPor,
    -- Conteo de usos
    COALESCE(COUNT(pc.id_pedido_cupon), 0) AS UsosActuales,
    -- Usos restantes (null si no hay límite)
    CASE 
        WHEN c.limite_uso IS NULL THEN NULL
        ELSE GREATEST(c.limite_uso - COUNT(pc.id_pedido_cupon), 0)
    END AS UsosRestantes,
    -- Porcentaje de uso
    CASE 
        WHEN c.limite_uso IS NULL OR c.limite_uso = 0 THEN NULL
        ELSE ROUND((COUNT(pc.id_pedido_cupon)::NUMERIC / c.limite_uso) * 100, 2)
    END AS PorcentajeUso,
    -- Estado del cupón basado en usos
    CASE 
        WHEN c.limite_uso IS NOT NULL AND COUNT(pc.id_pedido_cupon) >= c.limite_uso THEN 'Agotado'
        WHEN c.limite_uso IS NULL THEN 'Sin límite'
        ELSE 'Disponible'
    END AS EstadoUso
FROM cupon c
LEFT JOIN pedido_cupon pc ON c.id_cupon = pc.id_cupon
WHERE c.codigo = 'PRUEBAFORMATO'
GROUP BY 
    c.id_cupon, c.codigo, c.descuento, c.tipo_descuento, 
    c.fecha_expiracion, c.limite_uso, c.es_activo, 
    c.fecha_creacion, c.creado_por, c.fecha_actualizacion, 
    c.actualizado_por;

--Flujo de Saldo
SELECT id AS Id,userName AS UserName, email AS Correo FROM user_entity WHERE realm_id = '0a968fa2-46bc-45a1-884e-77df8034b23d'
--Obtener usuarios
SELECT * FROM user_entity where realm_id = '0a968fa2-46bc-45a1-884e-77df8034b23d';
--Obtener saldo por usuario
SELECT 
  ue.id AS Id,
  ue.email AS Correo,
  s.saldo AS Saldo,
  s.actualizado_por AS UsuarioModifica,
  s.fecha_actualizacion AS fechaModificacion
FROM saldo_usuario s inner join user_entity ue
on ue.id::uuid = s.id_usuario::uuid

--Asignar o recarga saldo
CREATE OR REPLACE FUNCTION asignar_o_actualizar_saldo(
  p_id_usuario UUID,
  p_nuevo_saldo DECIMAL,
  p_actualizado_por TEXT
)
RETURNS TEXT AS $$
DECLARE
  v_existe BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM saldo_usuario WHERE id_usuario = p_id_usuario
  ) INTO v_existe;

  IF v_existe THEN
    UPDATE saldo_usuario
    SET saldo = p_nuevo_saldo,
        actualizado_por = p_actualizado_por,
        fecha_actualizacion = NOW()
    WHERE id_usuario = p_id_usuario;

    RETURN 'Saldo actualizado correctamente.';
  ELSE
    INSERT INTO saldo_usuario (
      id_usuario, saldo, creado_por
    ) VALUES (
      p_id_usuario, p_nuevo_saldo, p_actualizado_por
    );

    RETURN 'Saldo asignado correctamente.';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Verificar si el usuario tiene suficiente saldo
PERFORM 1 FROM saldo_usuario 
WHERE id_usuario = p_id_usuario AND saldo >= p_total_con_descuento;

