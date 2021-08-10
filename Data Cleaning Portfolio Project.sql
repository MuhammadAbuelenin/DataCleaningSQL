-- Our Data

select * 
from PortfolioProject..NashvilleHousing 



-- Standardize Data Format <<(Adding)>>.

alter table NashvilleHousing
add NewSaleDate Date;

update NashvilleHousing
set NewSaleDate = CONVERT(Date, SaleDate)

select NewSaleDate
from PortfolioProject..NashvilleHousing



-- Populate Property Address Data

select PropertyAddress
from PortfolioProject..NashvilleHousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- Breaking out Address into individual columns (Address, City, State)

select PropertySplitAddress
from PortfolioProject..NashvilleHousing

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) as City,
PropertyAddress
from PortfolioProject..NashvilleHousing


alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)


alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))



select *
from PortfolioProject..NashvilleHousing


select ownerAddress
from PortfolioProject..NashvilleHousing


select 
parsename(REPLACE(ownerAddress, ',', '.'),3),
parsename(REPLACE(ownerAddress, ',', '.'),2),
parsename(REPLACE(ownerAddress, ',', '.'),1),
 ownerAddress
from PortfolioProject..NashvilleHousing



alter table PortfolioProject..NashvilleHousing
add ownerSplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing
set ownerSplitAddress = parsename(REPLACE(ownerAddress, ',', '.'),3)


alter table PortfolioProject..NashvilleHousing
add ownerSplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set ownerSplitCity = parsename(REPLACE(ownerAddress, ',', '.'),2)


alter table PortfolioProject..NashvilleHousing
add ownerSplitState nvarchar(255);

update PortfolioProject..NashvilleHousing
set ownerSplitState = parsename(REPLACE(ownerAddress, ',', '.'),1)



-- Change Y and N to YEs and No

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant


select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
from PortfolioProject..NashvilleHousing


update PortfolioProject..NashvilleHousing
set SoldAsVacant =  Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
from PortfolioProject..NashvilleHousing



-- Delete Duplicate Rows

with DuplicateCTE as
(
	select*, ROW_NUMBER() over 
	( Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
		order by uniqueID ) as row_num
	from PortfolioProject..NashvilleHousing
)
select *
from DuplicateCTE


delete
from DuplicateCTE
where row_num > 1



-- Delete Columns

Alter Table PortfolioProject..NashvilleHousing
drop column PropertyAddress, OwnerAddress
