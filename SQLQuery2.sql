SELECT *
FROM Housing..housing

-- Alter SaleDate datatype to date
ALTER TABLE Housing..housing
ALTER COLUMN SaleDate date

/* Populate property address data that is missing.
Houses with the same ParceID have the same address. Which means
that if we have property addresses that has null value with a 
parcelID of X and another house contaning information about
the property address and with the same parcelID X, we can copy 
that property address and use it on the first house. */

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing..housing as a
JOIN Housing..housing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
--SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing..housing as a
JOIN Housing..housing as b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into individual columns

-- Add Address column

ALTER TABLE Housing..housing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Housing..housing
SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1);

-- Add city column

ALTER TABLE Housing..housing
ADD PropertySplitCity NVARCHAR(255);

UPDATE Housing..housing
SET PropertySplitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

-- Using Parse name

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM housing..housing

ALTER TABLE Housing..housing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Housing..housing
SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3);

ALTER TABLE Housing..housing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Housing..housing
SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2);

ALTER TABLE Housing..housing
ADD OwnerSplitSate NVARCHAR(255);

UPDATE Housing..housing
SET OwnerSplitSate  = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);

SELECT *
FROM Housing..housing

-- Change Y and N to Yes and No

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM Housing..housing
GROUP BY SoldAsVacant 
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN Soldasvacant = 'Y' THEN 'Yes'
	WHEN Soldasvacant = 'N' THEN 'No'
	ELSE Soldasvacant
	END
FROM Housing..housing

UPDATE Housing..housing
SET SoldAsVacant = CASE WHEN Soldasvacant = 'Y' THEN 'Yes'
	WHEN Soldasvacant = 'N' THEN 'No'
	ELSE Soldasvacant
	END


-- Remove Duplicates
WITH Row_num_CTE as(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) as row_number
FROM Housing..housing)

DELETE
FROM Row_num_CTE
WHERE row_number>1

-- Delete Unused Columns

ALTER TABLE Housing..housing
DROP COLUMN OwnerAddress, PropertyAddress

-- Done!