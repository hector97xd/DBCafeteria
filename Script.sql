CREATE DATABASE CAFETERIA;

-- Crear tipos personalizados
CREATE TYPE estado_pedido AS ENUM ('Recibido', 'Preparando', 'Listo', 'Completado');
CREATE TYPE tipo_pago AS ENUM ('Efectivo', 'Tarjeta');

-- Crear tabla categoria
CREATE TABLE IF NOT EXISTS categoria (
  id_categoria UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT UNIQUE NOT NULL,
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ DEFAULT now(),
  actualizado_por TEXT
);

-- Crear tabla producto
CREATE TABLE IF NOT EXISTS producto (
  id_producto UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
  url_imagen TEXT,
  url_modelo_3d TEXT,
  calorias INTEGER CHECK (calorias >= 0),
  id_categoria UUID REFERENCES categoria(id_categoria) ON DELETE SET NULL,
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ DEFAULT now(),
  actualizado_por TEXT
);

-- Crear tabla alergeno
CREATE TABLE IF NOT EXISTS alergeno (
  id_alergeno UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT UNIQUE NOT NULL,
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ DEFAULT now(),
  actualizado_por TEXT
);

-- Crear tabla preferencia_dietetica
CREATE TABLE IF NOT EXISTS preferencia_dietetica (
  id_preferencia UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT UNIQUE NOT NULL,
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ DEFAULT now(),
  actualizado_por TEXT
);

-- Crear tabla ingrediente
CREATE TABLE IF NOT EXISTS ingrediente (
  id_ingrediente UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT UNIQUE NOT NULL,
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ DEFAULT now(),
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
  fecha_actualizacion TIMESTAMPTZ DEFAULT now(),
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
  fecha_creacion TIMESTAMPTZ DEFAULT now(),
  creado_por TEXT,
  fecha_actualizacion TIMESTAMPTZ DEFAULT now(),
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

CREATE INDEX idx_producto_categoria ON producto(id_categoria);
CREATE INDEX idx_pedido_usuario ON pedido(id_usuario);
CREATE INDEX idx_detalle_pedido_pedido ON detalle_pedido(id_pedido);
CREATE INDEX idx_detalle_pedido_producto ON detalle_pedido(id_producto);
CREATE INDEX idx_historial_pedido ON historial_estado_pedido(id_pedido);

 
-- INSERTS
INSERT INTO alergeno (nombre) VALUES 
('Gluten'), ('Lácteos'), ('Frutos secos'), ('Huevo'), ('Soja'), ('Mariscos'), ('Pescado'), ('Apio')
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO preferencia_dietetica (nombre) VALUES 
('Vegetariano'), ('Vegano'), ('Sin gluten'), ('Bajo en azúcar'), ('Bajo en calorías'), ('Keto'), ('Paleo'), ('Sin lactosa')
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO categoria (nombre) VALUES 
('Café'), ('Bebidas frías'), ('Pasteles'), ('Sándwiches'), ('Ensaladas'), ('Desayunos'), ('Postres'), ('Comidas rápidas')
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO ingrediente (nombre) VALUES 
('Café'), ('Leche'), ('Azúcar'), ('Harina de trigo'), ('Huevos'), ('Mantequilla'), ('Chocolate'), ('Nata'), ('Queso'), ('Jamón'), ('Lechuga'), ('Tomate'), ('Pan'), ('Pollo'), ('Fresas')
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO producto (nombre, descripcion, precio, url_imagen, url_modelo_3d, calorias, id_categoria) VALUES 
('Café Latte', 'Espresso con leche cremosa al vapor', 3.50, '', '', 120, (SELECT id_categoria FROM categoria WHERE nombre = 'Café')),
('Tarta de Chocolate', 'Deliciosa tarta con ganache de chocolate negro', 4.95, '', '', 350, (SELECT id_categoria FROM categoria WHERE nombre = 'Pasteles'))
ON CONFLICT (nombre) DO NOTHING;



