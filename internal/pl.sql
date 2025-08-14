
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
-- #####             pl.sql File		 		#####
-- ##################################################

-- Drop the procedure if it exists
DROP PROCEDURE IF EXISTS ResetDatabase;

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
