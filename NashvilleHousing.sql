create database SQL_project1

select * 
from SQL_project1.. NashvilleHousing

	--Standardize Date Format--

select SaleDate, convert(date,SaleDate)
from SQL_project1.. NashvilleHousing

update SQL_project1.. NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)

alter table SQL_project1.. NashvilleHousing
add SaleDateConverted date;

update SQL_project1.. NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

select SaleDateConverted, convert(date,SaleDate)
from SQL_project1.. NashvilleHousing

	-- Populate Property Address Data--

select *
from SQL_project1.. NashvilleHousing
--where PropertyAddress is  null
order by ParcelID

select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from SQL_project1.. NashvilleHousing a
join SQL_project1 ..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from SQL_project1.. NashvilleHousing a
join SQL_project1 ..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

	-- Breaking out Address into Indivudual Columns --

select PropertyAddress
from SQL_project1.. NashvilleHousing
--where PropertyAddress is  null

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Adress
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Adress

from SQL_project1..NashvilleHousing

alter table SQL_project1.. NashvilleHousing
add PropertySplitAdress nvarchar(255);

update SQL_project1.. NashvilleHousing
set PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

alter table SQL_project1.. NashvilleHousing
add PropertySplitCity nvarchar(255);

update SQL_project1.. NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

select *
from SQL_project1..NashvilleHousing

select OwnerAddress
from SQL_project1..NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)
from SQL_project1..NashvilleHousing

alter table SQL_project1.. NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update SQL_project1.. NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)

alter table SQL_project1.. NashvilleHousing
add OwnerSplitCity nvarchar(255);

update SQL_project1.. NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)

alter table SQL_project1.. NashvilleHousing
add OwnerSplitState nvarchar(255);

update SQL_project1.. NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)

	-- Change Y and N to Yes and No in "Sold as Vacant" field--

Select distinct(SoldAsVacant), Count(SoldAsVacant)
from SQL_project1..NashvilleHousing
Group by SoldAsVacant
order by 2 

select SoldAsVacant
, case when SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
From SQL_project1..NashvilleHousing

update SQL_project1..NashvilleHousing
	SET SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End

	-- REMOVING DUPLICATES --

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
						) row_num

From SQL_project1..NashvilleHousing
--order by ParcelID
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

	-- DELETE UNUSED COLUMNS --

Select *
from SQL_project1..NashvilleHousing

ALTER TABLE SQL_project1..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate