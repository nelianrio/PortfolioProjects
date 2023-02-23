/*
Cleaning Data

*/

Select *
From PortfolioProject..NashvilleHousing

--Standardized Date Format

-- Sale Date is Formated in Date and Time and we want to convert it to a standard date format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, Saledate)

/*Since SaleDate isn't updating from the code that we wrote above let's ALTER the table and add
a new column named SaleDateConverted */

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, Saledate)




-- Populate Property Address Data

--Looking at PropertyAddress where there is no data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is NULL
order by ParcelID

/*We found out that in order to populate the missing data from PropertyAddress
we can locate the right data by referencing ParcelID (Parcel ID matches PropertyAddress) */

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

/*From Above, we used JOIN to look at PropertyAddress vs Unique ID so that we can cross reference
We used ISNULL so that if it is null, it will update into b.Propertyadress, you may also use
a string eg. 'No address'. */

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

----Breaking out Address into Individual Columns ( Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is NULL
--order by ParcelID

-- Results show address and city (seperated by coma, no states ) Delimiter is coma (,)

--We'll use Substring and Character Index - CHARINDEX ( find string, where to find)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

-- In order to separate address we need to add two columns by using ALTER and UPDATE

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))



Select *
From PortfolioProject..NashvilleHousing

--Owner Address (Using Parsename instead of SUBSTRING)

Select OwnerAddress
From PortfolioProject..NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

Select *
From PortfolioProject..NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

-- We need to check the count of SoldAsVacant to check what we are going to change and the results will show that some are written in Y and N

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

--We then need to change the Y and N strings to Yes and NO strings by using CASE statement (like Javascript switch statements)

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject..NashvilleHousing

-- From there if the above code worksm then we need to update our table Nashville and set said column to complete string

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject..NashvilleHousing




----Remove Duplicates

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
						UniqueID
						) row_num
From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

---Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate