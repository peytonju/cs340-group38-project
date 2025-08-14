-- ##################################################
-- ##### Justice Peyton, Zachary Wilkins-Olson 	#####
-- ##### CS340                                  #####
-- #####                                        #####
-- #####            Stardew Valley:             #####
-- #####     Pelican Town Social Registry       #####
-- #####              dml.sql File		 		#####
-- ##################################################


-- create drops
DROP PROCEDURE IF EXISTS create_player;
DROP PROCEDURE IF EXISTS create_farm;
DROP PROCEDURE IF EXISTS create_gift;
DROP PROCEDURE IF EXISTS create_villager;
DROP PROCEDURE IF EXISTS create_villager_gift_preference;
DROP PROCEDURE IF EXISTS create_villager_player_relationship;
DROP PROCEDURE IF EXISTS create_gift_history;

-- update drops
DROP PROCEDURE IF EXISTS update_player;
DROP PROCEDURE IF EXISTS update_farm;
DROP PROCEDURE IF EXISTS update_gift;
DROP PROCEDURE IF EXISTS update_villager;
DROP PROCEDURE IF EXISTS update_villager_gift_preference;
DROP PROCEDURE IF EXISTS update_villager_player_relationship;

-- delete drops
DROP PROCEDURE IF EXISTS delete_farm;
DROP PROCEDURE IF EXISTS delete_gift;
DROP PROCEDURE IF EXISTS delete_player;
DROP PROCEDURE IF EXISTS delete_villager;
DROP PROCEDURE IF EXISTS delete_villager_gift_preference;
DROP PROCEDURE IF EXISTS delete_villager_player_relationship;


-- #################################################
-- #################### CREATE #####################
-- #################################################
CREATE PROCEDURE create_player (
	IN p_playerName varchar(100)
)
BEGIN
	INSERT INTO Players (playerName)
	VALUES (p_playerName);
    COMMIT;
END;


CREATE PROCEDURE create_villager (
	IN p_villagerName varchar(100),
	IN p_birthdaySeason varchar(10),
	IN p_birthdayDay int,
	IN p_homeArea varchar(100),
	IN p_farmID int
)
BEGIN
    IF p_farmID IS NOT NULL THEN
	    IF NOT EXISTS (SELECT 1 FROM Farms WHERE farmID = p_farmID) THEN
		    SIGNAL SQLSTATE '45000'
		    	SET MESSAGE_TEXT = 'passed farm ID does not exist';
	    END IF;
    END IF;

	INSERT INTO Villagers (villagerName, birthdaySeason, birthdayDay, homeArea, farmID)
	VALUES (p_villagerName, p_birthdaySeason, p_birthdayDay, p_homeArea, p_farmID);
    COMMIT;
END;


CREATE PROCEDURE create_farm (
	IN p_playerID int,
	IN p_farmName varchar(100),
	IN p_farmType  varchar(50)
)
BEGIN
	INSERT INTO Farms (playerID, farmName, farmType)
	VALUES (p_playerID, p_farmName, p_farmType);
    COMMIT;
END;


CREATE PROCEDURE create_gift (
	IN p_giftName varchar(100),
	IN p_value decimal(8,2),
	IN p_seasonAvailable varchar(20)
)
BEGIN
	INSERT INTO Gifts (giftName, value, seasonAvailable)
	VALUES (p_giftName, p_value, p_seasonAvailable);
    COMMIT;
END;


CREATE PROCEDURE create_villager_player_relationship (
	IN p_playerID int,
	IN p_villagerID int,
	IN p_friendshipLevel int
)
BEGIN
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
    COMMIT;
END;


CREATE PROCEDURE create_villager_gift_preference (
	IN p_villagerID int,
	IN p_giftID int,
	IN p_preference varchar(50)
)
BEGIN
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
    COMMIT;
END;


CREATE PROCEDURE create_gift_history (
    IN p_givenDate datetime,
    IN p_playerID int,
    IN p_villagerID int,
    IN p_giftID int
)
BEGIN
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
    IF EXISTS (SELECT 1 FROM VillagersGiftsPreferences
                WHERE villagerID = p_villagerID AND giftID = p_giftID) THEN

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
    IF EXISTS (SELECT 1 FROM PlayersVillagersRelationships
                WHERE playerID = p_playerID AND villagerID = p_villagerID) THEN

        UPDATE PlayersVillagersRelationships
        SET friendshipLevel = LEAST(10, GREATEST(0, friendshipLevel + amount_to_increase_by))
        WHERE playerID = p_playerID AND villagerID = p_villagerID;
    ELSE
        INSERT INTO PlayersVillagersRelationships (playerID, villagerID, friendshipLevel)
        VALUES (p_playerID, p_villagerID, LEAST(10, GREATEST(0, amount_to_increase_by)));
    END IF;

    COMMIT;
END;


-- #################################################
-- #################### UPDATE #####################
-- #################################################
CREATE PROCEDURE update_player (
    IN p_playerID int,
    IN p_playerName varchar(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Players WHERE playerID = p_playerID) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'passed player ID does not exist';
	END IF;

    UPDATE Players
    SET playerName = p_playerName
    WHERE playerID = p_playerID;

    COMMIT;
END;


CREATE PROCEDURE update_gift (
    IN p_giftID int,
    IN p_giftName varchar(100),
    IN p_value decimal(8,2),
    IN p_seasonAvailable varchar(20)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Gifts WHERE giftID = p_giftID) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'passed gift ID does not exist';
	END IF;

    UPDATE Gifts
    SET giftName = p_giftName, value = p_value, seasonAvailable = p_seasonAvailable
    WHERE giftID = p_giftID;

    COMMIT;
END;


CREATE PROCEDURE update_farm (
    IN p_farmID int,
	IN p_playerID int,
	IN p_farmName varchar(100),
	IN p_farmType  varchar(50)
)
BEGIN
	UPDATE Farms
    SET playerID = p_playerID, farmName = p_farmName, farmType = p_farmType
    WHERE farmID = p_farmID;
    COMMIT;
END;


CREATE PROCEDURE update_villager (
    IN p_villagerID int,
	IN p_villagerName varchar(100),
	IN p_birthdaySeason varchar(10),
	IN p_birthdayDay int,
	IN p_homeArea varchar(100),
	IN p_farmID int
)
BEGIN
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

    COMMIT;
END;


CREATE PROCEDURE update_villager_player_relationship (
	IN p_playerID int,
	IN p_villagerID int,
    IN p_newPlayerID int,
    IN p_newVillagerID int,
	IN p_friendshipLevel int
)
BEGIN
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


    -- update IDs
    IF p_playerID != p_newPlayerID OR p_villagerID != p_newVillagerID THEN
        UPDATE PlayersVillagersRelationships
        SET playerID = p_newPlayerID, villagerID = p_newVillagerID
        WHERE playerID = p_playerID AND villagerID = p_villagerID;
    END IF;

    IF (p_friendshipLevel) IS NULL THEN
        SET friendship_level_start = 0;
    ELSE
        SET friendship_level_start = p_friendshipLevel;
    END IF;

    -- update friendship level
    UPDATE PlayersVillagersRelationships
    SET friendshipLevel = p_friendshipLevel
    WHERE playerID = p_playerID AND villagerID = p_villagerID;

    COMMIT;
END;


CREATE PROCEDURE update_villager_gift_preference (
	IN p_villagerID int,
	IN p_giftID int,
    IN p_newVillagerID int,
    IN p_newGiftID int,
	IN p_preference varchar(50)
)
BEGIN
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


    -- update IDs
    IF p_villagerID != p_newVillagerID OR p_giftID != p_newGiftID THEN
        UPDATE VillagersGiftsPreferences
        SET villagerID = p_newVillagerID, giftID = p_newGiftID
        WHERE villagerID = p_villagerID AND giftID = p_giftID;
    END IF;

    -- update preference
	UPDATE VillagersGiftsPreferences
    SET preference = p_preference
    WHERE villagerID = p_villagerID AND giftID = p_giftID;

    COMMIT;
END;



-- #################################################
-- #################### DELETE #####################
-- #################################################
CREATE PROCEDURE delete_player (
    IN p_playerID int
)
BEGIN
    DELETE FROM Players
    WHERE playerID = p_playerID;
    COMMIT;
END;


CREATE PROCEDURE delete_villager (
    IN p_villagerID int
)
BEGIN
    DELETE FROM Villagers
    WHERE villagerID = p_villagerID;
    COMMIT;
END;


CREATE PROCEDURE delete_farm (
    IN p_farmID int
)
BEGIN
    DELETE FROM Farms
    WHERE farmID = p_farmID;
    COMMIT;
END;


CREATE PROCEDURE delete_gift (
    IN p_giftID int
)
BEGIN
    DELETE FROM Gifts 
    WHERE giftID = p_giftID;
    COMMIT;
END;


CREATE PROCEDURE delete_villager_player_relationship (
	IN p_playerID int,
	IN p_villagerID int
)
BEGIN
	DELETE FROM PlayersVillagersRelationships
    WHERE playerID = p_playerID AND villagerID = p_villagerID;
    COMMIT;
END;



CREATE PROCEDURE delete_villager_gift_preference (
    IN p_villagerID int,
    IN p_giftID int
)
BEGIN
    DELETE FROM VillagersGiftsPreferences
    WHERE villagerID = p_villagerID AND giftID = p_giftID;
    COMMIT;
END;
