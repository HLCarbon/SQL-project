SELECT *
FROM Housing..housing

-- Alter SaleDate datatype to date instead of vchar(255)
ALTER TABLE Housing..housing
ALTER COLUMN SaleDate date

/* Populate property address data that is missing.
Houses with the same ParceID have the same address. Which means
that if we have property addresses that has null value with a 
parcelID of X and another house contaning information about
the property address and with the same parcelID X, we can copy 
that property address and use it on the first house. */
