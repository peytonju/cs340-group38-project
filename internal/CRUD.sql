-- ##################################################
-- ##### Justice Peyton, Zachary Wilkins-Olson 	#####
-- ##### CS340                                  #####
-- #####                                        #####
-- #####            Stardew Valley:             #####
-- #####     Pelican Town Social Registry       #####
-- #####             CRUD QUERIES               #####
-- ##################################################

-- #################################################
-- #################### PLAYERS ####################
-- #################################################
-- ##### select
SELECT * FROM `Players`
    WHERE
        'playerID' = int

-- ##### insert
INSERT INTO `Players` (`playerName`)
    VALUES
        (varchar)

-- ##### update
UPDATE `Players`
    SET
        'playerName' = varchar
    WHERE
        'playerID' = int

-- ##### delete
DELETE FROM `Players`
    WHERE
        'playerID' = int

-- #################################################
-- ##################### GIFTS #####################
-- #################################################
-- ##### select
SELECT * FROM `Gifts`
    WHERE
        'giftID' = int

-- ##### insert
INSERT INTO `Gifts` (`giftName`, `value`, `seasonAvailable`)
    VALUES
        (varchar, decimal, varchar)

-- ##### update
UPDATE `Gifts`
    SET
        'giftName' = varchar, 'value' = decimal, 'seasonAvailable' = varchar
    WHERE
        'giftID' = int

-- ##### delete
DELETE FROM Gifts
    WHERE
        'giftID' = int

-- #################################################
-- ################### VILLAGERS ###################
-- #################################################
-- ##### select
SELECT * FROM `Villagers`
    WHERE
        'villagerID' = int

-- ##### insert
INSERT INTO `Villagers` (`villagerName`, `birthdaySeason`, `birthdayDay`, `homeArea`, `farmID`)
    VALUES
        (varchar, varchar, int, varchar, int)

-- ##### update
UPDATE `Villagers`
    SET
        'villagerName' = varchar, 'birthdaySeason' = varchar, 'birthdayDay' = int, 'homeArea' = varchar, 'farmID' = int
    WHERE
        'villagerID' = int

-- ##### delete
DELETE FROM Villagers
    WHERE
        'villagerID' = int

-- #################################################
-- ##################### FARMS #####################
-- #################################################
-- Farms have a one-to-one relationship with players, 
-- so the player ID also uniquely identifies the farm.

-- #### select
SELECT * FROM `Farms`
    WHERE
        'farmID' = int

SELECT * FROM `Farms`
    WHERE
        'playerID' = int

-- ##### insert
INSERT INTO `Farms` (`playerID`, `farmName`, `farmType`)
    VALUES
        (int, varchar, varchar)

-- ##### update
UPDATE Farms
    SET
        'playerID' = int, 'farmName' = varchar, 'farmType' = varchar
    WHERE
        'farmID' = int

UPDATE `Farms`
    SET
        'playerID' = int, 'farmName' = varchar, 'farmType' = varchar
    WHERE
        'playerID' = int


-- ##### delete
DELETE FROM `Farms`
    WHERE
        'farmID' = int

-- #################################################
-- ################# GIFTHISTORIES #################
-- #################################################
-- This is a transaction table, so updating and deleting entries from this is not allowed!

-- ##### select
SELECT * FROM `GiftHistories`
    WHERE
        'playerID' = int, 'villagerID' = int, 'giftID' = int, 'givenDate' = date

-- ##### insert
INSERT INTO `GiftHistories` (`playerID`, `villagerID`, `giftID`, `givenDate`)
    VALUES
        (int, int, int, date)


