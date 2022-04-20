/****** Cleaning Data though SQL Queries   ******/


SELECT *
FROM PortfolioProject..NashvilleHousing

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDate2 DATE;

Update NashvilleHousing
SET SaleDate2= CONVERT(Date, SaleDate)

SELECT SaleDate2
FROM PortfolioProject..NashvilleHousing


-- Populate Property Address data

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID=b.ParcelID AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a 
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID=b.ParcelID AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress is NULL


-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS PropertyAddress2,
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertyAddress2 NVARCHAR(255);

Update PortfolioProject..NashvilleHousing
SET PropertyAddress2= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertyCity NVARCHAR(255);

Update PortfolioProject..NashvilleHousing
SET PropertyCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

/*
Another Method
SELECT PARSENAME(REPLACE(PropertyAddress,',','.'),2) AS Address,
	   PARSENAME(REPLACE(PropertyAddress,',','.'),1) AS City 
FROM PortfolioProject..NashvilleHousing
*/

SELECT *
FROM PortfolioProject..NashvilleHousing


SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing


SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerAddress2 NVARCHAR(255);

Update PortfolioProject..NashvilleHousing
SET OwnerAddress2= PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerCity NVARCHAR(255);

Update PortfolioProject..NashvilleHousing
SET OwnerCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerState NVARCHAR(255);

Update PortfolioProject..NashvilleHousing
SET OwnerState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT *
FROM PortfolioProject..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP By SoldAsVacant

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
	END 
FROM PortfolioProject..NashvilleHousing


UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
	END
	
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP By SoldAsVacant


---- Remove Duplicates


WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() Over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
			ORDER BY UniqueID
			) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
DELETE 
from RowNumCTE
Where row_num>1




---- Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER Table PortfolioProject..NashvilleHousing
DROP COLUMN TaxDistrict