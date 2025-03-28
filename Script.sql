CREATE DATABASE CAFETERIA;

-- Create custom types
CREATE TYPE ORDER_STATUS AS ENUM ('Recibido', 'Preparando', 'Listo', 'Completado');
CREATE TYPE PAYMENT_TYPE AS ENUM ('Efectivo', 'Tarjeta');

-- Create CATEGORY table
CREATE TABLE IF NOT EXISTS CATEGORY (
  PK_CATEGORY uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  NAME text UNIQUE NOT NULL,
  CREATED_AT timestamptz DEFAULT now()
);

-- Create PRODUCT table
CREATE TABLE IF NOT EXISTS PRODUCT (
  PK_PRODUCT uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  NAME text NOT NULL,
  DESCRIPTION text,
  PRICE decimal(10,2) NOT NULL CHECK (PRICE >= 0),
  IMAGE_URL text,
  MODEL_3D_URL text,
  CALORIES integer CHECK (CALORIES >= 0),
  FK_CATEGORY uuid REFERENCES CATEGORY(PK_CATEGORY) ON DELETE SET NULL,
  CREATED_AT timestamptz DEFAULT now(),
  UPDATED_AT timestamptz DEFAULT now()
);

-- Create ALLERGEN table
CREATE TABLE IF NOT EXISTS ALLERGEN (
  PK_ALLERGEN uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  NAME text UNIQUE NOT NULL,
  CREATED_AT timestamptz DEFAULT now()
);

-- Create DIETARY_PREFERENCE table
CREATE TABLE IF NOT EXISTS DIETARY_PREFERENCE (
  PK_DIETARY_PREFERENCE uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  NAME text UNIQUE NOT NULL,
  CREATED_AT timestamptz DEFAULT now()
);

-- Create INGREDIENT table
CREATE TABLE IF NOT EXISTS INGREDIENT (
  PK_INGREDIENT uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  NAME text UNIQUE NOT NULL,
  CREATED_AT timestamptz DEFAULT now()
);

-- Create PRODUCT_INGREDIENT junction table
CREATE TABLE IF NOT EXISTS PRODUCT_INGREDIENT (
  FK_PRODUCT uuid REFERENCES PRODUCT(PK_PRODUCT) ON DELETE CASCADE,
  FK_INGREDIENT uuid REFERENCES INGREDIENT(PK_INGREDIENT) ON DELETE CASCADE,
  PRIMARY KEY (FK_PRODUCT, FK_INGREDIENT)
);

-- Create PRODUCT_ALLERGEN junction table
CREATE TABLE IF NOT EXISTS PRODUCT_ALLERGEN (
  FK_PRODUCT uuid REFERENCES PRODUCT(PK_PRODUCT) ON DELETE CASCADE,
  FK_ALLERGEN uuid REFERENCES ALLERGEN(PK_ALLERGEN) ON DELETE CASCADE,
  PRIMARY KEY (FK_PRODUCT, FK_ALLERGEN)
);

-- Create PRODUCT_DIETARY_PREFERENCE junction table
CREATE TABLE IF NOT EXISTS PRODUCT_DIETARY_PREFERENCE (
  FK_PRODUCT uuid REFERENCES PRODUCT(PK_PRODUCT) ON DELETE CASCADE,
  FK_DIETARY_PREFERENCE uuid REFERENCES DIETARY_PREFERENCE(PK_DIETARY_PREFERENCE) ON DELETE CASCADE,
  PRIMARY KEY (FK_PRODUCT, FK_DIETARY_PREFERENCE)
);


-- Se ejecuto hasta aqui 
-- Create ORDER table
CREATE TABLE IF NOT EXISTS "ORDER" (
  PK_ORDER uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  FK_USER uuid NOT NULL,
  STATUS ORDER_STATUS DEFAULT 'Recibido' NOT NULL,
  PAYMENT_METHOD PAYMENT_TYPE NOT NULL,
  TOTAL decimal(10,2) NOT NULL CHECK (TOTAL >= 0),
  CREATED_AT timestamptz DEFAULT now(),
  UPDATED_AT timestamptz DEFAULT now()
);


-- Create ORDER_ITEM table
CREATE TABLE IF NOT EXISTS ORDER_ITEM (
  PK_ORDER_ITEM uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  FK_ORDER uuid REFERENCES "ORDER" (PK_ORDER) ON DELETE CASCADE NOT NULL,
  FK_PRODUCT uuid REFERENCES PRODUCT(PK_PRODUCT) ON DELETE SET NULL NOT NULL,
  QUANTITY integer NOT NULL CHECK (QUANTITY > 0),
  UNIT_PRICE decimal(10,2) NOT NULL CHECK (UNIT_PRICE >= 0),
  CREATED_AT timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS COUPON (
  PK_COUPON uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  CODE text UNIQUE NOT NULL,
  DISCOUNT decimal(10,2) NOT NULL CHECK (DISCOUNT >= 0),
  EXPIRATION_DATE timestamptz NOT NULL,
  USAGE_LIMIT integer CHECK (USAGE_LIMIT >= 0),
  CREATED_AT timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ORDER_COUPON (
  PK_ORDER_COUPON uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  FK_ORDER uuid REFERENCES "ORDER" (PK_ORDER) ON DELETE CASCADE NOT NULL,
  FK_COUPON uuid REFERENCES COUPON (PK_COUPON) ON DELETE CASCADE NOT NULL,
  DISCOUNT_APPLIED decimal(10,2) NOT NULL CHECK (DISCOUNT_APPLIED >= 0),
  CREATED_AT timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ORDER_STATUS_HISTORY (
  PK_ORDER_STATUS_HISTORY uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  FK_ORDER uuid REFERENCES "ORDER" (PK_ORDER) ON DELETE CASCADE NOT NULL,
  STATUS text NOT NULL,
  CHANGED_BY uuid REFERENCES USERS (PK_USER) ON DELETE SET NULL,
  CHANGED_AT timestamptz DEFAULT now()
);

-- Create function to update UPDATED_AT timestamp
CREATE OR REPLACE FUNCTION UPDATE_UPDATED_AT_COLUMN()
RETURNS TRIGGER AS $$
BEGIN
  NEW.UPDATED_AT = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updating UPDATED_AT
CREATE TRIGGER UPDATE_PRODUCT_UPDATED_AT
  BEFORE UPDATE ON PRODUCT
  FOR EACH ROW
  EXECUTE FUNCTION UPDATE_UPDATED_AT_COLUMN();

CREATE TRIGGER UPDATE_ORDER_UPDATED_AT
  BEFORE UPDATE ON "ORDER"
  FOR EACH ROW
  EXECUTE FUNCTION UPDATE_UPDATED_AT_COLUMN();
 
 

-- INSERTS PARA ALERGENOS
INSERT INTO ALLERGEN (NAME) VALUES 
('Gluten'),
('Lácteos'),
('Frutos secos'),
('Huevo'),
('Soja'),
('Mariscos'),
('Pescado'),
('Apio');

-- INSERTS PARA PREFERENCIAS DIETÉTICAS
INSERT INTO DIETARY_PREFERENCE (NAME) VALUES 
('Vegetariano'),
('Vegano'),
('Sin gluten'),
('Bajo en azúcar'),
('Bajo en calorías'),
('Keto'),
('Paleo'),
('Sin lactosa');

-- INSERTS PARA CATEGORÍAS
INSERT INTO CATEGORY (NAME) VALUES 
('Café'),
('Bebidas frías'),
('Pasteles'),
('Sándwiches'),
('Ensaladas'),
('Desayunos'),
('Postres'),
('Comidas rápidas');

-- INSERTS PARA INGREDIENTES
INSERT INTO INGREDIENT (NAME) VALUES 
('Café'),
('Leche'),
('Azúcar'),
('Harina de trigo'),
('Huevos'),
('Mantequilla'),
('Chocolate'),
('Nata'),
('Queso'),
('Jamón'),
('Lechuga'),
('Tomate'),
('Pan'),
('Pollo'),
('Fresas');

-- INSERTS PARA PRODUCTOS
INSERT INTO PRODUCT (NAME, DESCRIPTION, PRICE, IMAGE_URL, MODEL_3D_URL, CALORIES, FK_CATEGORY) VALUES 
(
    'Café Latte', 
    'Espresso con leche cremosa al vapor', 
    3.50, 
    'https://images.unsplash.com/photo-1541167760496-1628856ab772', 
    'https://modelviewer.dev/shared-assets/models/NeilArmstrong.webp', 
    120, 
    (SELECT PK_CATEGORY FROM CATEGORY WHERE NAME = 'Café')
),
(
    'Tarta de Chocolate', 
    'Deliciosa tarta con ganache de chocolate negro', 
    4.95, 
    'https://images.unsplash.com/photo-1578985545062-69928b1d9587', 
    'https://modelviewer.dev/shared-assets/models/NeilArmstrong.webp', 
    350, 
    (SELECT PK_CATEGORY FROM CATEGORY WHERE NAME = 'Pasteles')
),
(
    'Ensalada César', 
    'Lechuga romana, crutones, pollo y aderezo César', 
    8.75, 
    'https://images.unsplash.com/photo-1550304943-4f24f54ddde9', 
    'https://modelviewer.dev/shared-assets/models/NeilArmstrong.webp', 
    420, 
    (SELECT PK_CATEGORY FROM CATEGORY WHERE NAME = 'Ensaladas')
),
(
    'Sándwich Vegetariano', 
    'Pan integral con hummus, aguacate y vegetales frescos', 
    7.25, 
    'https://images.unsplash.com/photo-1554433607-66b5efe9d304', 
    '', 
    380, 
    (SELECT PK_CATEGORY FROM CATEGORY WHERE NAME = 'Sándwiches')
),
(
    'Smoothie de Frutas', 
    'Batido refrescante de frutas mixtas y yogur', 
    5.50, 
    'https://images.unsplash.com/photo-1589734435354-1e25f1c8ee09', 
    '', 
    220, 
    (SELECT PK_CATEGORY FROM CATEGORY WHERE NAME = 'Bebidas frías')
);

-- INSERTS PARA PRODUCTOS-ALÉRGENOS
INSERT INTO PRODUCT_ALLERGEN (FK_PRODUCT, FK_ALLERGEN) VALUES
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Café Latte'),
    (SELECT PK_ALLERGEN FROM ALLERGEN WHERE NAME = 'Lácteos')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Tarta de Chocolate'),
    (SELECT PK_ALLERGEN FROM ALLERGEN WHERE NAME = 'Gluten')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Tarta de Chocolate'),
    (SELECT PK_ALLERGEN FROM ALLERGEN WHERE NAME = 'Lácteos')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Tarta de Chocolate'),
    (SELECT PK_ALLERGEN FROM ALLERGEN WHERE NAME = 'Huevo')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Ensalada César'),
    (SELECT PK_ALLERGEN FROM ALLERGEN WHERE NAME = 'Gluten')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Sándwich Vegetariano'),
    (SELECT PK_ALLERGEN FROM ALLERGEN WHERE NAME = 'Gluten')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Smoothie de Frutas'),
    (SELECT PK_ALLERGEN FROM ALLERGEN WHERE NAME = 'Lácteos')
);

-- INSERTS PARA PRODUCTOS-DIETAS
INSERT INTO PRODUCT_DIETARY_PREFERENCE (FK_PRODUCT, FK_DIETARY_PREFERENCE) VALUES
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Sándwich Vegetariano'),
    (SELECT PK_DIETARY_PREFERENCE FROM DIETARY_PREFERENCE WHERE NAME = 'Vegetariano')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Smoothie de Frutas'),
    (SELECT PK_DIETARY_PREFERENCE FROM DIETARY_PREFERENCE WHERE NAME = 'Vegetariano')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Smoothie de Frutas'),
    (SELECT PK_DIETARY_PREFERENCE FROM DIETARY_PREFERENCE WHERE NAME = 'Bajo en calorías')
);

-- INSERTS PARA PRODUCTOS-INGREDIENTES
INSERT INTO PRODUCT_INGREDIENT (FK_PRODUCT, FK_INGREDIENT) VALUES
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Café Latte'),
    (SELECT PK_INGREDIENT FROM INGREDIENT WHERE NAME = 'Café')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Café Latte'),
    (SELECT PK_INGREDIENT FROM INGREDIENT WHERE NAME = 'Leche')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Tarta de Chocolate'),
    (SELECT PK_INGREDIENT FROM INGREDIENT WHERE NAME = 'Harina de trigo')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Tarta de Chocolate'),
    (SELECT PK_INGREDIENT FROM INGREDIENT WHERE NAME = 'Chocolate')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Tarta de Chocolate'),
    (SELECT PK_INGREDIENT FROM INGREDIENT WHERE NAME = 'Huevos')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Ensalada César'),
    (SELECT PK_INGREDIENT FROM INGREDIENT WHERE NAME = 'Lechuga')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Ensalada César'),
    (SELECT PK_INGREDIENT FROM INGREDIENT WHERE NAME = 'Pollo')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Sándwich Vegetariano'),
    (SELECT PK_INGREDIENT FROM INGREDIENT WHERE NAME = 'Pan')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Sándwich Vegetariano'),
    (SELECT PK_INGREDIENT FROM INGREDIENT WHERE NAME = 'Tomate')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Sándwich Vegetariano'),
    (SELECT PK_INGREDIENT FROM INGREDIENT WHERE NAME = 'Lechuga')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Smoothie de Frutas'),
    (SELECT PK_INGREDIENT FROM INGREDIENT WHERE NAME = 'Fresas')
),
(
    (SELECT PK_PRODUCT FROM PRODUCT WHERE NAME = 'Smoothie de Frutas'),
    (SELECT PK_INGREDIENT FROM INGREDIENT WHERE NAME = 'Leche')
); 
 
