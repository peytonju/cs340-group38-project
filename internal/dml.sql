
-- ################# CITATION NOTICE #################
-- If any function does NOT list a citation, then it
-- was created originally by either Justice Peyton or
-- Zachary Wilkins-Olson, and in those cases the entire
-- team (Justice Peyton, Zachary Wilkins-Olson) is to
-- be credited.
-- ###################################################


-- ##################################################
-- ##### Justice Peyton, Zachary Wilkins-Olson 	#####
-- ##### CS340                                  #####
-- #####                                        #####
-- #####            Stardew Valley:             #####
-- #####     Pelican Town Social Registry       #####
-- #####             dml.sql File		 		#####
-- ##################################################

-- please note that this file is not actually used and
-- is merely for reference on how to create, modify,
-- and delete rows in the database.

-- actual implementation has been placed in pl.sql,
-- as that is responsible for creating stored procedures
-- that modify the database, essentially acting as DML.

-- please note that all SQL placed here was created by
-- Justice Peyton.



-- #################################################
-- #################### Players ####################
-- #################################################
-- #################### create
INSERT INTO Players (playerName)
	VALUES (p_playerName);


-- #################### update
IF NOT EXISTS (SELECT 1 FROM Players WHERE playerID = p_playerID) THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'passed player ID does not exist';
END IF;

UPDATE Players
SET playerName = p_playerName
WHERE playerID = p_playerID;


-- #################### delete
DELETE FROM Players
WHERE playerID = p_playerID;


-- #################################################
-- ################### Villagers ###################
-- #################################################
-- #################### create
IF p_farmID IS NOT NULL THEN
    IF NOT EXISTS (SELECT 1 FROM Farms WHERE farmID = p_farmID) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'passed farm ID does not exist';
    END IF;
END IF;

INSERT INTO Villagers (villagerName, birthdaySeason, birthdayDay, homeArea, farmID)
VALUES (p_villagerName, p_birthdaySeason, p_birthdayDay, p_homeArea, p_farmID);


-- #################### update
IF p_farmID IS NOT NULL THEN
    IF NOT EXISTS (SELECT 1 FROM Farms WHERE farmID = p_farmID) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'passed farm ID does not exist';
    END IF;
END IF;

IF NOT EXISTS (SELECT 1 FROM Villagers WHERE villagerID = p_villagerID) THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'passed villager ID does not exist';
END IF;

UPDATE Villagers
SET villagerName = p_villagerName, birthdaySeason = p_birthdaySeason, birthdayDay = p_birthdayDay, homeArea = p_homeArea, farmID = p_farmID
WHERE villagerID = p_villagerID;


-- #################### delete
DELETE FROM Villagers
WHERE villagerID = p_villagerID;


-- #################################################
-- ##################### Farms #####################
-- #################################################
-- #################### create
INSERT INTO Farms (playerID, farmName, farmType)
VALUES (p_playerID, p_farmName, p_farmType);


-- #################### update
UPDATE Farms
SET playerID = p_playerID, farmName = p_farmName, farmType = p_farmType
WHERE farmID = p_farmID;


-- #################### delete
DELETE FROM Farms
WHERE farmID = p_farmID;


-- #################################################
-- ##################### Gifts #####################
-- #################################################
-- #################### create
INSERT INTO Gifts (giftName, value, seasonAvailable)
VALUES (p_giftName, p_value, p_seasonAvailable);


-- #################### update
IF NOT EXISTS (SELECT 1 FROM Gifts WHERE giftID = p_giftID) THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'passed gift ID does not exist';
END IF;

UPDATE Gifts
SET giftName = p_giftName, value = p_value, seasonAvailable = p_seasonAvailable
WHERE giftID = p_giftID;


-- #################### delete
DELETE FROM Gifts 
WHERE giftID = p_giftID;


-- #################################################
-- ################# Gift Histories ################
-- #################################################
-- #################### create
DECLARE amount_to_increase_by int;
DECLARE villager_preference varchar(50);

IF NOT EXISTS (SELECT 1 FROM Villagers WHERE villagerID = p_villagerID) THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'passed villager ID does not exist';
END IF;

IF NOT EXISTS (SELECT 1 FROM Players WHERE playerID = p_playerID) THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'passed player ID does not exist';
END IF;

INSERT INTO GiftHistories (playerID, villagerID, giftID, givenDate)
VALUES (p_playerID, p_villagerID, p_giftID, p_givenDate);

-- get the amount to increase by
IF EXISTS (SELECT 1 FROM VillagersGiftsPreferences WHERE villagerID = p_villagerID AND giftID = p_giftID) THEN

    SELECT preference INTO villager_preference
    FROM VillagersGiftsPreferences
    WHERE villagerID = p_villagerID AND giftID = p_giftID;

    -- determine the amount to increase by
    IF villager_preference = 'love' THEN
        SET amount_to_increase_by = 2;
    ELSEIF villager_preference = 'like' THEN
        SET amount_to_increase_by = 1;
    ELSEIF villager_preference = 'neutral' THEN
        SET amount_to_increase_by = 0;
    ELSEIF villager_preference = 'dislike' THEN
        SET amount_to_increase_by = -1;
    ELSEIF villager_preference = 'hate' THEN
        SET amount_to_increase_by = -2;
    END IF;

ELSE
    -- create a neutral preference
    INSERT INTO VillagersGiftsPreferences (villagerID, giftID, preference)
    VALUES (p_villagerID, p_giftID, 'neutral');

    SET amount_to_increase_by = 0;
END IF;

-- improve their relationship
IF EXISTS (SELECT 1 FROM PlayersVillagersRelationships WHERE playerID = p_playerID AND villagerID = p_villagerID) THEN

    UPDATE PlayersVillagersRelationships
    SET friendshipLevel = LEAST(10, GREATEST(0, friendshipLevel + amount_to_increase_by))
    WHERE playerID = p_playerID AND villagerID = p_villagerID;
ELSE
    INSERT INTO PlayersVillagersRelationships (playerID, villagerID, friendshipLevel)
    VALUES (p_playerID, p_villagerID, LEAST(10, GREATEST(0, amount_to_increase_by)));
END IF;

-- #################### update
-- none, this is a transaction table.

-- #################### delete
-- none, this is a transaction table.

-- #################################################
-- ######### Players-Villagers Preferences #########
-- #################################################
-- #################### create
DECLARE friendship_level_start int;

IF NOT EXISTS (SELECT 1 FROM Villagers WHERE villagerID = p_villagerID) THEN
    SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'passed villager ID does not exist';
END IF;

IF NOT EXISTS (SELECT 1 FROM Players WHERE playerID = p_playerID) THEN
    SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'passed player ID does not exist';
END IF;

IF (p_friendshipLevel) IS NULL THEN
    SET friendship_level_start = 0;
ELSE
    SET friendship_level_start = p_friendshipLevel;
END IF;

INSERT INTO PlayersVillagersRelationships (playerID, villagerID, friendshipLevel)
VALUES (p_playerID, p_villagerID, friendship_level_start);


-- #################### update
DECLARE friendship_level_start int;

IF NOT EXISTS (SELECT 1 FROM Players WHERE playerID = p_playerID) THEN
    SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'passed player ID does not exist';
END IF;

IF NOT EXISTS (SELECT 1 FROM Villagers WHERE villagerID = p_villagerID) THEN
    SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'passed villager ID does not exist';
END IF;

IF NOT EXISTS (SELECT 1 FROM Players WHERE playerID = p_newPlayerID) THEN
    SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'passed new player ID does not exist';
END IF;

IF NOT EXISTS (SELECT 1 FROM Villagers WHERE villagerID = p_newVillagerID) THEN
    SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'passed new villager ID does not exist';
END IF;


-- if no friendship level was passed, just set it to 0.
IF (p_friendshipLevel) IS NULL THEN
    SET friendship_level_start = 0;
-- otherwise, set it to the passed friendship level.
ELSE
    SET friendship_level_start = p_friendshipLevel;
END IF;

UPDATE PlayersVillagersRelationships
SET playerID = p_newPlayerID, villagerID = p_newVillagerID, friendshipLevel = LEAST(10, GREATEST(0, friendship_level_start))
WHERE playerID = p_playerID AND villagerID = p_villagerID;


-- #################### delete
DELETE FROM PlayersVillagersRelationships
WHERE playerID = p_playerID AND villagerID = p_villagerID;


-- #################################################
-- ########### Villager-Gift Preferences ###########
-- #################################################
-- #################### create
IF NOT EXISTS (SELECT 1 FROM Villagers WHERE villagerID = p_villagerID) THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'passed villager ID does not exist';
END IF;

IF NOT EXISTS (SELECT 1 FROM Gifts WHERE giftID = p_giftID) THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'passed gift ID does not exist';
END IF;

INSERT INTO VillagersGiftsPreferences (villagerID, giftID, preference)
VALUES (p_villagerID, p_giftID, p_preference);


-- #################### update
IF NOT EXISTS (SELECT 1 FROM Villagers WHERE villagerID = p_villagerID) THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'passed villager ID does not exist';
END IF;

IF NOT EXISTS (SELECT 1 FROM Gifts WHERE giftID = p_giftID) THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'passed gift ID does not exist';
END IF;

IF NOT EXISTS (SELECT 1 FROM Villagers WHERE villagerID = p_newVillagerID) THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'passed new villager ID does not exist';
END IF;

IF NOT EXISTS (SELECT 1 FROM Gifts WHERE giftID = p_newGiftID) THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'passed new gift ID does not exist';
END IF;


UPDATE VillagersGiftsPreferences
SET villagerID = p_newVillagerID, giftID = p_newGiftID, preference = p_preference
WHERE villagerID = p_villagerID AND giftID = p_giftID;


-- #################### deletion
DELETE FROM VillagersGiftsPreferences
WHERE villagerID = p_villagerID AND giftID = p_giftID;
