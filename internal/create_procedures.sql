
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
		    	SET MESSAGE_TEXT = 'Error: passed farm ID does not exist';
	    END IF;
    END IF;

	INSERT INTO Villagers (villagerName, birthdaySeason, birthdayDay, homeArea, assignedFarmID)
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
	IN p_giftID int,
	IN p_giftName varchar(100),
	IN p_value decimal(8,2),
	IN p_seasonAvailable varchar(20)
)
BEGIN
	INSERT INTO Gifts (giftID, giftName, value, seasonAvailable)
	VALUES (p_giftID, p_giftName, p_value, p_seasonAvailable);
    COMMIT;
END;


CREATE PROCEDURE create_villager_player_relationship (
	IN p_playerID int,
	IN p_villagerID int,
	IN p_friendshipLevel int,
	IN p_relationshipLevel varchar(50)
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Villagers WHERE villagerID = p_villagerID) THEN
		SIGNAL SQLSTATE '45000' 
			SET MESSAGE_TEXT = 'Error: passed villager ID does not exist';
	END IF;

	IF NOT EXISTS (SELECT 1 FROM Players WHERE playerID = p_playerID) THEN
		SIGNAL SQLSTATE '45000' 
			SET MESSAGE_TEXT = 'Error: passed player ID does not exist';
	END IF;

	INSERT INTO PlayersVillagersRelationships (playerID, villagerID, friendshipLevel, relationshipLevel)
	VALUES (p_playerID, p_villagerID, p_friendshipLevel, p_relationshipLevel);
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
			SET MESSAGE_TEXT = 'Error: passed villager ID does not exist';
	END IF;

	IF NOT EXISTS (SELECT 1 FROM Gifts WHERE giftID = p_giftID) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Error: passed gift ID does not exist';
	END IF;

	INSERT INTO VillagersGiftsPreferences (villagerID, giftID, preference)
	VALUES (p_villagerID, p_giftID, p_preference);
    COMMIT;
END;


-- #################################################
-- #################### UPDATE #####################
-- #################################################


-- #################################################
-- #################### DELETE #####################
-- #################################################
CREATE PROCEDURE create_villager_player_relationship (
	IN p_playerID int,
	IN p_villagerID int,
)
BEGIN
	DELETE FROM PlayersVillagersRelationships
    WHERE playerID = p_playerID and villagerID = p_villagerID;
    COMMIT;
END;



CREATE PROCEDURE delete_villager_gift_preference (
    IN p_villagerID,
    IN p_giftID
)
BEGIN
    DELETE FROM VillagersGiftsPreferences
    WHERE villagerID = p_villagerID AND giftID = p_giftID;
    COMMIT;
END;