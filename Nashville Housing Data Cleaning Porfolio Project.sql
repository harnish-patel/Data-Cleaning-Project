-----------------------------------------------------------------------------------------------------

-- Change SaleDate Format from DATETIME to DATE

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE


-----------------------------------------------------------------------------------------------------

-- Populate Property Address Data

-- Verify if ParcelID relates to only 1 Property Address (this can be used to fill in NULL Property Addresses)
-- Query identifies cases where a specific ParcelID has more than 1 unique PropertyAddress 

SELECT ParcelID, COUNT(DISTINCT PropertyAddress) AS UniqueAddresses
FROM NashvilleHousing
GROUP BY ParcelID
HAVING COUNT(DISTINCT PropertyAddress) > 1

-- Query above showed there are quite a few ParcelIDs with more than 1 unique PropertyAddress
-- Querty below used to see PropertyAddress values for each ParcelID which has more than 1 unique PropertyAddress

SELECT ParcelID, PropertyAddress
FROM NashvilleHousing
WHERE ParcelID IN (
	SELECT ParcelID
	FROM NashvilleHousing
	GROUP BY ParcelID
	HAVING COUNT(DISTINCT PropertyAddress) > 1
)

-- From analyzing data, looks like there are inconsistenies with inputted PropertAddress causes non unique strings
-- PropertyAddress must be cleaned before trying to fill NULL PropertyAddress data

-- Trim Spaces

UPDATE NashvilleHousing
SET PropertyAddress = TRIM(PropertyAddress)

-- Remove Extra Spaces (fixed a significant amount of issues, only 243 ParcelIDs with more than 1 unique PropertyAddress)

UPDATE NashvilleHousing
SET PropertyAddress = REPLACE(PropertyAddress, '  ', ' ')

-- Populate NULL PropertyAddress with PropertyAddress from same UniqueID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-----------------------------------------------------------------------------------------------------

-- Seperate PropertyAddress into Individual Columns for Address and City (USING SUBSTRING METHOD)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM NashvilleHousing
order by PropertyAddress

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255),
	PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



-- Seperate OwnerAddress into Individual Columns for Address, City, and State (USING PARSENAME METHOD)

SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
	OwnerSplitCity NVARCHAR(255),
	OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)


-----------------------------------------------------------------------------------------------------

-- SoldAsVacant currently showing (Yes, No, Y, N) as options. Changing all to Yes, No for consistency

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES' 
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES' 
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
