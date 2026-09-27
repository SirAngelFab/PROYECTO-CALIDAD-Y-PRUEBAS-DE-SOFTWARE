CREATE TABLE Roles (
    RolID INT PRIMARY KEY IDENTITY(1,1),
    NombreRol VARCHAR(50) NOT NULL UNIQUE
);
GO

-- 2. Tabla de Usuarios (Cliente, Vendedor, Admin)
CREATE TABLE Usuarios (
    UsuarioID INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) NOT NULL,
    Correo VARCHAR(100) NOT NULL UNIQUE,
    ClaveHash VARCHAR(255) NOT NULL,
    RolID INT NOT NULL,
    FechaRegistro DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (RolID) REFERENCES Roles(RolID)
);
GO

-- 3. Tabla de Categorías
CREATE TABLE Categorias (
    CategoriaID INT PRIMARY KEY IDENTITY(1,1),
    NombreCategoria VARCHAR(100) NOT NULL
);
GO

-- 4. Tabla de Productos (Relación Padre con Vendedor y Categoría)
CREATE TABLE Productos (
    ProductoID INT PRIMARY KEY IDENTITY(1,1),
    VendedorID INT NOT NULL,
    CategoriaID INT NOT NULL,
    NombreProducto VARCHAR(150) NOT NULL,
    Precio DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL DEFAULT 0,
    FechaPublicacion DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (VendedorID) REFERENCES Usuarios(UsuarioID),
    FOREIGN KEY (CategoriaID) REFERENCES Categorias(CategoriaID)
);
GO

-- 5. Tabla Pedidos / Encabezado de Ventas (Padre)
CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY IDENTITY(1,1),
    ClienteID INT NOT NULL,
    FechaPedido DATETIME DEFAULT GETDATE(),
    Total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (ClienteID) REFERENCES Usuarios(UsuarioID)
);
GO

-- 6. Tabla DetallePedidos / Ventas (Hijo)
CREATE TABLE DetallePedidos (
    DetalleID INT PRIMARY KEY IDENTITY(1,1),
    PedidoID INT NOT NULL,
    ProductoID INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);
GO

-- =============================================
-- CONSULTAS Y REPORTES
-- =============================================

-- Reporte 1: Ventas agregadas por Fecha, Semana y Mes
SELECT 
    CAST(p.FechaPedido AS DATE) AS Fecha, 
    DATEPART(WEEK, p.FechaPedido) AS Semana, 
    MONTH(p.FechaPedido) AS Mes, 
    SUM(p.Total) AS TotalVentas 
FROM Pedidos p 
GROUP BY 
    CAST(p.FechaPedido AS DATE), 
    DATEPART(WEEK, p.FechaPedido), 
    MONTH(p.FechaPedido);
GO

-- Reporte 2: Productos más pedidos (Top Demanda)
SELECT TOP 10 
    pr.NombreProducto, 
    SUM(dp.Cantidad) AS TotalUnidadesPedidas 
FROM DetallePedidos dp 
INNER JOIN Productos pr ON dp.ProductoID = pr.ProductoID 
GROUP BY pr.NombreProducto 
ORDER BY TotalUnidadesPedidas DESC;
GO

-- Reporte 3: Vendedores con ventas más populares
SELECT TOP 5 
    u.Nombre AS Vendedor, 
    SUM(dp.Subtotal) AS TotalVendido, 
    COUNT(DISTINCT dp.PedidoID) AS TotalOrdenes 
FROM DetallePedidos dp 
INNER JOIN Productos pr ON dp.ProductoID = pr.ProductoID 
INNER JOIN Usuarios u ON pr.VendedorID = u.UsuarioID 
GROUP BY u.Nombre 
ORDER BY TotalVendido DESC;
GO