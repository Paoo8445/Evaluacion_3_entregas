-- ================================================
-- SISTEMA DE ENTREGAS PAQUEXPRESS
-- Base de datos: eva3
-- Autor: [Paola Tellez]
-- Fecha: Noviembre 2025
-- ================================================

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS eva3;
USE eva3;

-- ================================================
-- TABLA: agentes
-- Descripción: Almacena la información de los agentes de entrega
-- ================================================
CREATE TABLE IF NOT EXISTS agentes (
    id_agente INT(11) NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id_agente),
    INDEX idx_email (email),
    INDEX idx_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ================================================
-- TABLA: paquetes
-- Descripción: Almacena la información de los paquetes a entregar
-- ================================================
CREATE TABLE IF NOT EXISTS paquetes (
    id_paquete INT(11) NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(100) NOT NULL,
    direccion TEXT NOT NULL,
    id_agente INT(11) DEFAULT NULL,
    estado ENUM('pendiente', 'entregado') NOT NULL DEFAULT 'pendiente',
    PRIMARY KEY (id_paquete),
    INDEX idx_agente (id_agente),
    INDEX idx_estado (estado),
    CONSTRAINT fk_paquetes_agente 
        FOREIGN KEY (id_agente) 
        REFERENCES agentes(id_agente) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ================================================
-- TABLA: entregas
-- Descripción: Almacena el registro de entregas realizadas con evidencia
-- ================================================
CREATE TABLE IF NOT EXISTS entregas (
    id_entrega INT(11) NOT NULL AUTO_INCREMENT,
    id_paquete INT(11) NOT NULL,
    id_agente INT(11) NOT NULL,
    fecha_hora DATETIME NOT NULL,
    latitud DECIMAL(10,6) NOT NULL,
    longitud DECIMAL(10,6) NOT NULL,
    foto_url TEXT NOT NULL,
    PRIMARY KEY (id_entrega),
    INDEX idx_paquete (id_paquete),
    INDEX idx_agente (id_agente),
    INDEX idx_fecha (fecha_hora),
    CONSTRAINT fk_entregas_paquete 
        FOREIGN KEY (id_paquete) 
        REFERENCES paquetes(id_paquete) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_entregas_agente 
        FOREIGN KEY (id_agente) 
        REFERENCES agentes(id_agente) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ================================================
-- DATOS DE PRUEBA
-- ================================================

-- Insertar agentes de prueba
-- Nota: Contraseñas encriptadas con SHA256
-- Contraseña original: "123456" -> SHA256: "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92"
INSERT INTO agentes (nombre, email, password_hash, activo) VALUES
('Paola Tellez', 'paola@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1),
('Gabriel', 'gabo@gmail.com', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 1),


-- Insertar paquetes de prueba
INSERT INTO paquetes (codigo, direccion, id_agente, estado) VALUES
('PTB001', 'Calle Principal 123, Col. Centro, Queretaro', 1, 'pendiente'),
('PTB002', 'Av. Universidad 456, Col. Álamos, Queretaro', 1, 'pendiente'),
('PTB003', 'Blvd. Bernardo Quintana 789, Col. San Pablo, Queretaro', 2, 'pendiente'),
('PTB004', 'Calle Reforma 321, Col. Hercules, Queretaro', 2, 'pendiente'),


-- Insertar una entrega de ejemplo (para paquete PTB004)
INSERT INTO entregas (id_paquete, id_agente, fecha_hora, latitud, longitud, foto_url) VALUES
(4, 2, NOW(), 20.588793, -100.389888, '4_1701234567.jpg');

