-- ##################################################
-- ##### Justice Peyton, Zachary Wilkins-Olson 	#####
-- ##### CS340                                  #####
-- #####                                        #####
-- #####            Stardew Valley:             #####
-- #####     Pelican Town Social Registry       #####
-- ####              PL.SQL File		 		#####
-- ##################################################

-- Drop the procedure if it exists
DROP PROCEDURE IF EXISTS ResetDatabase;

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


-- Create the stored procedure (Node.js compatible - no DELIMITER needed)
CREATE PROCEDURE ResetDatabase()
BEGIN
    -- Disable foreign key checks and autocommit
    SET FOREIGN_KEY_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    -- Drop all tables
    DROP TABLE IF EXISTS `Players`;
    DROP TABLE IF EXISTS `Farms`;
    DROP TABLE IF EXISTS `Villagers`;
    DROP TABLE IF EXISTS `Gifts`;
    DROP TABLE IF EXISTS `GiftHistories`;
    DROP TABLE IF EXISTS `PlayersVillagersRelationships`;
    DROP TABLE IF EXISTS `VillagersGiftsPreferences`;

    -- Create Players table
    CREATE TABLE `Players` (
        `playerID` int not null auto_increment,
        `playerName` varchar(100) not null,
        PRIMARY KEY (`playerID`)
    );

    -- Create Farms table
    CREATE TABLE `Farms` (
        `farmID` int not null auto_increment,
        `playerID` int not null unique,
        `farmName` varchar(100) not null,
        `farmType` varchar(50) not null,
        PRIMARY KEY (`farmID`),
        FOREIGN KEY (`playerID`) REFERENCES Players (`playerID`) ON DELETE CASCADE
    );

    -- Create Villagers table
    CREATE TABLE `Villagers` (
        `villagerID` int not null auto_increment,
        `villagerName` varchar(100) not null,
        `birthdaySeason` varchar(10) not null,
        `birthdayDay` tinyint unsigned not null,
        `homeArea` varchar(100) not null,
        `farmID` int,
        PRIMARY KEY (`villagerID`),
        FOREIGN KEY (`farmID`) REFERENCES Farms (`farmID`) ON DELETE CASCADE
    );

    -- Create Gifts table
    CREATE TABLE `Gifts` (
        `giftID` int not null auto_increment,
        `giftName` varchar(100) not null,
        `value` decimal(8,2) not null,
        `seasonAvailable` varchar(20),
        PRIMARY KEY (`giftID`)
    );

    -- Create GiftHistories table
    CREATE TABLE `GiftHistories` (
        `playerID` int not null,
        `villagerID` int not null,
        `giftID` int not null,
        `givenDate` datetime not null,
        PRIMARY KEY (`playerID`, `villagerID`, `giftID`, `givenDate`),
        FOREIGN KEY (`playerID`) REFERENCES Players (`playerID`) ON DELETE CASCADE,
        FOREIGN KEY (`villagerID`) REFERENCES Villagers (`villagerID`) ON DELETE CASCADE,
        FOREIGN KEY (`giftID`) REFERENCES Gifts (`giftID`) ON DELETE CASCADE
    );

    -- Create PlayersVillagersRelationships table
    CREATE TABLE `PlayersVillagersRelationships` (
        `playerID` int not null,
        `villagerID` int not null,
        `friendshipLevel` int not null default 0,
        PRIMARY KEY (`playerID`, `villagerID`),
        FOREIGN KEY (`playerID`) REFERENCES Players (`playerID`) ON DELETE CASCADE,
        FOREIGN KEY (`villagerID`) REFERENCES Villagers (`villagerID`) ON DELETE CASCADE
    );

    -- Create VillagersGiftsPreferences table
    CREATE TABLE `VillagersGiftsPreferences` (
        `villagerID` int not null,
        `giftID` int not null,
        `preference` varchar(50) not null default 'neutral',
        PRIMARY KEY (`villagerID`, `giftID`),
        FOREIGN KEY (`villagerID`) REFERENCES Villagers (`villagerID`) ON DELETE CASCADE,
        FOREIGN KEY (`giftID`) REFERENCES Gifts (`giftID`) ON DELETE CASCADE
    );

    -- Insert sample data
    -- 1) Players
    INSERT INTO `Players` (`playerID`, `playerName`) VALUES
      (1, 'Ringo'),
      (2, 'John'),
      (3, 'Paul');

    -- 2) Farms (one per player)
    INSERT INTO `Farms` (`playerID`,`farmName`,`farmType`) VALUES
     ((SELECT playerID FROM Players WHERE playerName = 'Ringo'), 'Yellow Submarine', 'Standard'),
     ((SELECT playerID FROM Players WHERE playerName = 'John'), 'Lake District', 'Riverland'),
     ((SELECT playerID FROM Players WHERE playerName = 'Paul'), 'Abbey Orchard', 'Forest');

    -- 3) Villagers
    INSERT INTO `Villagers`
     (`villagerName`,`birthdaySeason`,`birthdayDay`,`homeArea`,`farmID`)
    VALUES
     ('Haley', 'Spring', 14, 'Pelican Town', (SELECT farmID FROM Farms WHERE farmName = 'Yellow Submarine')),
     ('Jas', 'Summer', 4, 'Pelican Town', (SELECT farmID FROM Farms WHERE farmName = 'Yellow Submarine')),
     ('Sebastian', 'Winter', 10, 'The Mountain', (SELECT farmID FROM Farms WHERE farmName = 'Lake District')),
     ('Abigail', 'Fall', 13, 'Pelican Town', (SELECT farmID FROM Farms WHERE farmName = 'Abbey Orchard'));

    -- 4) Gifts
    INSERT INTO `Gifts` (`giftName`,`value`,`seasonAvailable`) VALUES
     ('Amethyst', 120.00, 'Winter'),
     ('Pumpkin', 60.00, 'Fall'),
     ('Pepper Poppers', 40.00, 'Summer'),
     ('Chocolate Cake', 75.00, NULL),
     ('Coconut', 75.00, 'Summer');

    -- 5) GiftHistories
    INSERT INTO `GiftHistories` (`playerID`,`villagerID`,`giftID`,`givenDate`) VALUES
     ((SELECT playerID FROM Players WHERE playerName = 'Ringo'), 
      (SELECT villagerID FROM Villagers WHERE villagerName = 'Haley'), 
      (SELECT giftID FROM Gifts WHERE giftName = 'Coconut'), 
      '2025-04-14'),
     ((SELECT playerID FROM Players WHERE playerName = 'Ringo'), 
      (SELECT villagerID FROM Villagers WHERE villagerName = 'Haley'), 
      (SELECT giftID FROM Gifts WHERE giftName = 'Pepper Poppers'), 
      '2025-05-01'),
     ((SELECT playerID FROM Players WHERE playerName = 'John'), 
      (SELECT villagerID FROM Villagers WHERE villagerName = 'Sebastian'), 
      (SELECT giftID FROM Gifts WHERE giftName = 'Amethyst'), 
      '2025-12-10'),
     ((SELECT playerID FROM Players WHERE playerName = 'Paul'), 
      (SELECT villagerID FROM Villagers WHERE villagerName = 'Abigail'), 
      (SELECT giftID FROM Gifts WHERE giftName = 'Amethyst'), 
      '2025-10-13');

    -- 6) PlayersVillagersRelationships
    INSERT INTO `PlayersVillagersRelationships`
     (`playerID`,`villagerID`,`friendshipLevel`)
    VALUES
     ((SELECT playerID FROM Players WHERE playerName = 'Ringo'), 
      (SELECT villagerID FROM Villagers WHERE villagerName = 'Haley'), 
      3),
     ((SELECT playerID FROM Players WHERE playerName = 'Ringo'), 
      (SELECT villagerID FROM Villagers WHERE villagerName = 'Abigail'), 
      1),
     ((SELECT playerID FROM Players WHERE playerName = 'John'), 
      (SELECT villagerID FROM Villagers WHERE villagerName = 'Sebastian'), 
      5),
     ((SELECT playerID FROM Players WHERE playerName = 'Paul'), 
      (SELECT villagerID FROM Villagers WHERE villagerName = 'Abigail'), 
      8);

    -- 7) VillagersGiftsPreferences
    INSERT INTO `VillagersGiftsPreferences`
     (`villagerID`,`giftID`,`preference`)
    VALUES
     ((SELECT villagerID FROM Villagers WHERE villagerName = 'Haley'), 
      (SELECT giftID FROM Gifts WHERE giftName = 'Coconut'), 
      'love'),
     ((SELECT villagerID FROM Villagers WHERE villagerName = 'Haley'), 
      (SELECT giftID FROM Gifts WHERE giftName = 'Amethyst'), 
      'like'),
     ((SELECT villagerID FROM Villagers WHERE villagerName = 'Sebastian'), 
      (SELECT giftID FROM Gifts WHERE giftName = 'Amethyst'), 
      'love'),
     ((SELECT villagerID FROM Villagers WHERE villagerName = 'Abigail'), 
      (SELECT giftID FROM Gifts WHERE giftName = 'Amethyst'), 
      'love'),
     ((SELECT villagerID FROM Villagers WHERE villagerName = 'Abigail'), 
      (SELECT giftID FROM Gifts WHERE giftName = 'Chocolate Cake'), 
      'like');

    -- Re-enable foreign key checks and commit
    SET FOREIGN_KEY_CHECKS = 1;
    COMMIT;

END;



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

    UPDATE PlayersVillagersRelationships
    SET friendshipLevel = p_friendshipLevel
    WHERE playerID = p_playerID AND villagerID = p_villagerID;

    COMMIT;
END;


CREATE PROCEDURE update_villager_gift_preference (
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
