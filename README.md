# Data Analyst Project - Data Cleaning with SQL Queries

## Overview

This GitHub repository contains SQL queries for a data cleaning project focused on a Nashville Housing dataset. The primary goal is to enhance data quality by performing various cleaning operations using SQL queries in a SQL Server environment.

## Table of Contents

- [SQL Queries](#sql-queries)
  - [1. Change SaleDate Format](#1-change-saledate-format)
  - [2. Populate Property Address Data](#2-populate-property-address-data)
    - [2.1 Clean Property Address Data](#21-clean-property-address-data)
    - [2.2 Populate NULL Property Addresses](#22-populate-null-property-addresses)
  - [3. Separate Property Address and Owner Address into Specific Columns (Using Substring Method)](#3-separate-property-address-and-owner-address-into-specific-columns-using-substring-method)
    - [3.1 Separate Property Address into Individual Columns for Address and City](#31-separate-property-address-into-individual-columns-for-address-and-city)
    - [3.2 Separate Owner Address into Individual Columns for Address, City, and State (Using ParseName Method)](#32-separate-owner-address-into-individual-columns-for-address-city-and-state-using-parsename-method)
  - [4. Standardize SoldAsVacant Values](#4-standardize-soldasvacant-values)
## SQL Queries

### 1. Change SaleDate Format

```sql
-- Change SaleDate Format from DATETIME to DATE
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE;
```

### 2. Populate Property Address Data
The ParcelID data is unique per Property Address. Therefore, the NULL Property Address data will be populated based on Property Address data from other rows with similar ParcelID data.

Before doing this, Property Address Data needs to be cleaned since there were some inconsistencies when querying to verify if each ParcelID has more than 1 unique Property Address
```sql
SELECT ParcelID, PropertyAddress
FROM NashvilleHousing
WHERE ParcelID IN (
	SELECT ParcelID
	FROM NashvilleHousing
	GROUP BY ParcelID
	HAVING COUNT(DISTINCT PropertyAddress) > 1
)
```

#### 2.1 Clean Property Address Data

```sql
-- Trim Spaces

UPDATE NashvilleHousing
SET PropertyAddress = TRIM(PropertyAddress)

-- Remove Extra Spaces (fixed a significant amount of issues, only 243 ParcelIDs with more than 1 unique PropertyAddress)

UPDATE NashvilleHousing
SET PropertyAddress = REPLACE(PropertyAddress, '  ', ' ')
```

#### 2.2 Populate NULL Property Addresses

```sql
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

```
### 3. Separate Property Address and Owner Address into Specific Columns (Using Substring Method)

#### 3.1 Separate Property Address into Individual Columns for Address and City

```sql
-- Separate PropertyAddress into Individual Columns for Address and City (USING SUBSTRING METHOD)
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255),
	PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));
```

#### 3.2 Separate Owner Address into Individual Columns for Address, City and State (Using ParseName Method)

```sql
-- Separate OwnerAddress into Individual Columns for Address, City, and State (USING PARSENAME METHOD)
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
	OwnerSplitCity NVARCHAR(255),
	OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);
```

### 4. Standardize SoldAsVacant Values

```sql
-- Standardize SoldAsVacant values to 'YES' or 'NO'
UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant IN ('Y', 'Yes') THEN 'YES'
	WHEN SoldAsVacant IN ('N', 'No') THEN 'NO'
	ELSE SoldAsVacant
	END;
```
