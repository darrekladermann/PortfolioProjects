--Standardize Sale Date Format

select SaleDate, convert(Date,SaleDate)
from NashvilleHousing

Update NashvilleHousing
set SaleDate = Convert(date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date ; 

Update NashvilleHousing
set SaleDateConverted = Convert(date,SaleDate)

Alter Table NashvilleHousing
Drop Column SaleDate

--Populate Property Address Data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress, b.propertyaddress)
from NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.propertyaddress is null

--Breaking address into individual columns (address, city, state)

select
substring(PropertyAddress, 1, CHARINDEX(',',propertyaddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
from NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',',propertyaddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

alter table NashvilleHousing
Drop Column PropertyAddress

select
PARSENAME(Replace(OwnerAddress,',','.'), 3) as OwnerSplitAddress
,PARSENAME(Replace(OwnerAddress,',','.'), 2) as OwnerSplitCity
,PARSENAME(Replace(OwnerAddress,',','.'), 1) as OwnerSplitState
from NashvilleHousing

Alter Table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)

Alter Table NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2)

Alter Table NashvilleHousing
add OwnerSplitState nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)

alter table NashvilleHousing
drop column OwnerAddress

--Change Y and N in "Sold As Vacant" field

select distinct (SoldAsVacant), count(Soldasvacant)
from NashvilleHousing
group by Soldasvacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant =
 case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

-- Remove Duplicates

with RowNumCTE AS(
select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertySplitAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 Order By
					UniqueID
					) row_num

from NashvilleHousing)

Delete
from RowNumCTE
where row_num > 1

-- Delete Unused Columns

Alter Table NashvilleHousing
Drop Column TaxDistrict
