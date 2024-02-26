-- Standarize Date Format

Select SaleDateConverted
From [Nashville Housing Data for Data CleaningCSV]

Update [Nashville Housing Data for Data CleaningCSV]
SET SaleDate = Convert (Date, SaleDate)

Alter Table [Nashville Housing Data for Data CleaningCSV]
Add SaleDateConverted Date; 

Update [Nashville Housing Data for Data CleaningCSV]
SET SaleDateConverted = Convert (Date, SaleDate)


-- Populate Property Address data

Select *
from [Nashville Housing Data for Data CleaningCSV]
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull (a.PropertyAddress, b.PropertyAddress)
from [Nashville Housing Data for Data CleaningCSV] a
JOIN [Nashville Housing Data for Data CleaningCSV] b
on a.ParcelID = b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = isnull (a.PropertyAddress, b.PropertyAddress)
from [Nashville Housing Data for Data CleaningCSV] a
JOIN [Nashville Housing Data for Data CleaningCSV] b
on a.ParcelID = b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out address into individual columns (address, city, state)

Select PropertyAddress
from [Nashville Housing Data for Data CleaningCSV]
--where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
from [Nashville Housing Data for Data CleaningCSV]

Alter Table [Nashville Housing Data for Data CleaningCSV]
Add PropertySplitAddress Nvarchar(255);

Update [Nashville Housing Data for Data CleaningCSV]
Set PropertySplitAddress = replace([PropertySplitAddress], ',', '')


Alter Table [Nashville Housing Data for Data CleaningCSV]
Add PropertySplitCity Nvarchar (255);

Update [Nashville Housing Data for Data CleaningCSV]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

Select *
from [Nashville Housing Data for Data CleaningCSV]

Select OwnerAddress
from [Nashville Housing Data for Data CleaningCSV]

Select
PARSENAME(Replace (OwnerAddress, ',', '.'), 3),
PARSENAME(Replace (OwnerAddress, ',', '.'), 2),
PARSENAME(Replace (OwnerAddress, ',', '.'), 1)
from [Nashville Housing Data for Data CleaningCSV]

Alter Table [Nashville Housing Data for Data CleaningCSV]
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing Data for Data CleaningCSV]
Set OwnerSplitAddress = PARSENAME(Replace (OwnerAddress, ',', '.'), 3)

Alter Table [Nashville Housing Data for Data CleaningCSV]
Add OwnerSplitCity Nvarchar (255);

Update [Nashville Housing Data for Data CleaningCSV]
Set OwnerSplitCity = PARSENAME(Replace (OwnerAddress, ',', '.'), 2)

Alter Table [Nashville Housing Data for Data CleaningCSV]
Add OwnerSplitState Nvarchar (255);

Update [Nashville Housing Data for Data CleaningCSV]
Set OwnerSplitState = PARSENAME(Replace (OwnerAddress, ',', '.'), 1)

select * 
from [Nashville Housing Data for Data CleaningCSV]


-- Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(SoldAsVacant), count(SoldAsVacant)
from [Nashville Housing Data for Data CleaningCSV]
group by SoldAsVacant

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from [Nashville Housing Data for Data CleaningCSV]

update [Nashville Housing Data for Data CleaningCSV]
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end


-- Remove duplicates

--With RowNumCTE as(
--Select *, 
--ROW_NUMBER() Over (
--Partition by ParcelID,
--			PropertyAddress,
--			SalePrice,
--			SaleDate,
--			LegalReference
--			Order by 
--				UniqueID
--				) as row_num
--from [Nashville Housing Data for Data CleaningCSV]
--)

--select *
--from RowNumCTE
--where row_num > 1
--order by PropertyAddress


--Delete 
--from RowNumCTE
--where row_num > 1


WITH RowNumCTE as  
(  
   SELECT*, ROW_NUMBER() over (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate ORDER BY ParcelID) as RowNumber  
   FROM [Nashville Housing Data for Data CleaningCSV]  
)  
DELETE FROM RowNumCTE WHERE RowNumber>1  
  
SELECT * FROM [Nashville Housing Data for Data CleaningCSV] 
where RowNumber>1


--Delete unused columns

Select *
from [Nashville Housing Data for Data CleaningCSV]

Alter Table [Nashville Housing Data for Data CleaningCSV]
drop column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

Alter Table [Nashville Housing Data for Data CleaningCSV]
drop column SaleDate