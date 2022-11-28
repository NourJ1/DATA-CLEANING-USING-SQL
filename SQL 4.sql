-- Cleaning Data
select * from NashvilleHousing 

-- Standardize SaleDate 

Select SaleDate , CONVERT( DATE , SaleDate)
FROM NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT( DATE , SaleDate) 

ALTER TABLE NashvilleHousing 
ADD SaleDateConverted DATE ; 
Update NashvilleHousing
SET SaleDateConverted = CONVERT( DATE , SaleDate) 

SELECT SaleDateConverted from NashvilleHousing


-- Populate Property Address 
SELECT *  FROM NashvilleHousing
WHERE PropertyAddress IS NULL 
ORDER BY ParcelID 

SELECT a.ParcelID, a.PropertyAddress , b.ParcelID , b.PropertyAddress , ISNULL( a.PropertyAddress , b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID= b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]  
--where a.PropertyAddress is null 

UPDATE a 
SET PropertyAddress = ISNULL( a.PropertyAddress , b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID= b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]  
where a.PropertyAddress is null 

SELECT a.ParcelID, a.PropertyAddress , b.ParcelID , b.PropertyAddress 
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID= b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]  
--where a.PropertyAddress is null 


-- BREAKING DOWN ADDRESS INTO INDIVIDIOUL COLUMNS 

SELECT propertyaddress , 
SUBSTRING ( PropertyAddress , 1 , CHARINDEX( ',', PropertyAddress)-1 )  ,
SUBSTRING ( PropertyAddress , CHARINDEX(',' , PropertyAddress)+1 , LEN(propertyaddress))
FROM NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD SplitAddress NVARCHAR(255);
UPDATE NashvilleHousing
SET SplitAddress = SUBSTRING ( PropertyAddress , 1 , CHARINDEX( ',', PropertyAddress)-1 )

ALTER TABLE NashvilleHousing 
ADD SplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET SplitCity = SUBSTRING ( PropertyAddress , CHARINDEX(',' , PropertyAddress)+1 , LEN(propertyaddress))


-- SPLIT OWNER ADDRESS

SELECT  
PARSENAME(REPLACE(OwnerAddress,',','.') ,3) ,
PARSENAME( replace(OwnerAddress , ',' , '.') ,2) ,
PARSENAME(REPLACE(OwnerAddress, ',','.'),1 )
From NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress NVARCHAR(255) ; 
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') ,3)

ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity NVARCHAR(255) ; 
UPDATE NashvilleHousing
SET  OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.') ,2)

ALTER TABLE NashvilleHousing 
ADD OwnerSplitState NVARCHAR(255) ; 
UPDATE NashvilleHousing
SET  OwnerSplitstate= PARSENAME(REPLACE(OwnerAddress,',','.') ,1)

--CHANGE (Y)&(N) TO (YES)&(NO)
Select distinct(SoldAsVacant) , count(soldasvacant)
from NashvilleHousing
group by soldasvacant 
order by 2 

Select SoldAsVacant 
, CASE WHEN SoldAsVacant = 'Y' then 'YES' 
       WHEN SoldAsVacant = 'N' then 'NO'
	   ELSE SoldAsVacant 
	   END 
FROM NashvilleHousing

UPDATE NashvilleHousing
set SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' then 'YES' 
       WHEN SoldAsVacant = 'N' then 'NO'
	   ELSE SoldAsVacant 
	   END 


--REMOVE DUPLICATES 

with rownumCTE AS (
select * , ROW_NUMBER () over ( partition by 
                                ParcelID,
								PropertyAddress,
								SalePrice,
								SaleDate,
								LegalReference
								Order By uniqueID 
								) row_num
FROM NashvilleHousing

)
select * 
 FROM rownumCTE
where row_num > 1 

-- delete unused columns 

ALTER TABLE NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict , PropertyAddress 


ALTER TABLE NashvilleHousing 
DROP COLUMN SaleDate 

SELECT * FROM NashvilleHousing 