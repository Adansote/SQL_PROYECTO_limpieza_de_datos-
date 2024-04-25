
--CREAR BASE DATOS --
CREATE DATABASE LIMPIEZA_NASHVILLE 
USE LIMPIEZA_NASHVILLE 

--VISTASO A LOS DATOS IMPORTADOS --
Select *
From NASHVILLE 

--CAMBIANDO FORMATO DE FECHA AA-MM-DD se creo una nueva columna con los datos originales de la columna saledate a saledateconvert  --

--con este script no cambia el tipo de datos con ceros 
UPDATE Nashville
SET SaleDate = CONVERT(DATE, SaleDate);


---SE CRE UNA NUEVA COLUMNA  PARA ELEGIR UN FORMATO DE FECHA CORTA AA-MM-DD SIN 00000
ALTER TABLE Nashville
Add SaleDateConverted Date

Update Nashville
SET SaleDateConverted = CONVERT(Date,SaleDate)


--ELIMINAR COLUMNA QUE NO SE PUDO MOIFICAR SALEDATE--
ALTER TABLE Nashville
DROP COLUMN SaleDate;

---RELLENAR COLUMNA PROPERTYANDRESS QUE CONTENGA VALORES NULL 
Select *
From Nashville
Where PropertyAddress is null
Order by ParcelID;

-- Consulta SELECT 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville a
JOIN Nashville b ON a.ParcelID = b.ParcelID
WHERE a.PropertyAddress IS NULL AND a.UniqueID <> b.UniqueID;

-- Consulta UPDATE ACTUALIZAR 
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville a
JOIN Nashville b ON a.ParcelID = b.ParcelID
WHERE a.PropertyAddress IS NULL AND a.UniqueID <> b.UniqueID;



-- Dividir la dirección en columnas individuales (dirección, ciudad, estado)


Select PropertyAddress
From NASHVILLE

--SEPARANDO LA CIUDAD GOODLETTSVILLEEN NUEVA COLUMNA Y LA DRECCION  SPLITANDRESS Y SPLITCITY ---
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From .NASHVILLE


ALTER TABLE NASHVILLE
Add PropertySplitAddress Nvarchar(255);

Update NASHVILLE
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

EXEC sp_columns NASHVILLE;

ALTER TABLE NASHVILLE
ADD PropertySplitCity VARCHAR(255); -- O el tipo de datos adecuado para la ciudad


Update NASHVILLE
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--SEPARNADO LA COLUMNA OWNERADDRESS--
Select *
From NASHVILLE 

--visualizar columna OwnerAddress--
Select OwnerAddress
From NASHVILLE

---para separa los datos de la columna en base a las comas y puntos de cada fila y ageregar columnas 
--para dividir la direcion la ciudad y estado--
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NASHVILLE

ALTER TABLE NASHVILLE
Add OwnerSplitAddress Nvarchar(255);

Update NASHVILLE
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NASHVILLE
Add OwnerSplitCity Nvarchar(255);

Update NASHVILLE
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NASHVILLE
Add OwnerSplitState Nvarchar(255);

Update NASHVILLE
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--eliminar la columnas que se dividieron  OwnerAddress y  PropertyAddress
ALTER TABLE Nashville
DROP COLUMN OwnerAddress;

ALTER TABLE Nashville
DROP COLUMN PropertyAddress;

ALTER TABLE Nashville
DROP COLUMN TaxDistrict;

Select *
From NASHVILLE
--------------------------------

--cambiando NO , SI por Y, N 
---contando los datos Y, N , NO , YES revueltos sin sentido 
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From .NASHVILLE
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NASHVILLE


Update NASHVILLE
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

	   ---------------------------

	   -- Removiendo dulicados

----
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID,
                            SalePrice,
                            LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM NASHVILLE
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY ParcelID, SalePrice, LegalReference;

Select *
From NASHVILLE
----------------------------