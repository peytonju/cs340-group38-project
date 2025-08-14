-- ##################################################
-- ##### Justice Peyton, Zachary Wilkins-Olson 	#####
-- ##### CS340                                  #####
-- #####                                        #####
-- #####            Stardew Valley:             #####
-- #####     Pelican Town Social Registry       #####
-- #####             ddl.sql File		 		#####
-- ##################################################

-- ############################################
-- ##### Brief Description of the project #####
-- ############################################
-- This project is a social registry for Stardew Valley, focusing on the relationships between players, villagers, and gifts.
-- It includes tables for players, farms, villagers, gifts, gift histories, and relationships between players and villagers.


-- #################################################
-- ############## STARDEW VALLEY DDL ###############
-- #################################################

SET FOREIGN_KEY_CHECKS = 0;
SET AUTOCOMMIT = 0;

-- #################################################
-- ################## TABLE DROPS ##################
-- #################################################

-- entities
DROP TABLE IF EXISTS `Players`;
DROP TABLE IF EXISTS `Farms`;
DROP TABLE IF EXISTS `Villagers`;
DROP TABLE IF EXISTS `Gifts`;
DROP TABLE IF EXISTS `GiftHistories`;

-- intersection tables
DROP TABLE IF EXISTS `PlayersVillagersRelationships`;
DROP TABLE IF EXISTS `VillagersGiftsPreferences`;


-- #################################################
-- ################# ENTITY TABLES #################
-- #################################################

-- object table
CREATE TABLE `Players` (
	-- attributes
	`playerID` int not null auto_increment,
	`playerName` varchar(100) not null,

	-- constraints
	PRIMARY KEY (`playerID`)
);

-- object table
CREATE TABLE `Farms` (
	-- attributes
	`farmID` int not null auto_increment,
	`playerID` int not null unique,
	`farmName` varchar(100) not null,
	`farmType` varchar(50) not null,

	-- constraints
	PRIMARY KEY (`farmID`),
	FOREIGN KEY (`playerID`) REFERENCES Players (`playerID`) ON DELETE CASCADE
);

-- object table
CREATE TABLE `Villagers` (
	-- attributes
	`villagerID` int not null auto_increment,
	`villagerName` varchar(100) not null,
	`birthdaySeason` varchar(10) not null,
	`birthdayDay` tinyint unsigned not null,
	`homeArea` varchar(100) not null,
	`farmID` int,

	-- constraints
	PRIMARY KEY (`villagerID`),
	FOREIGN KEY (`farmID`) REFERENCES Farms (`farmID`) ON DELETE SET NULL
);

-- category table
CREATE TABLE `Gifts` (
	-- attributes
	`giftID` int not null auto_increment,
	`giftName` varchar(100) not null,
	`value` decimal(8,2) not null,
	`seasonAvailable` varchar(20),
	
	-- constraints
	PRIMARY KEY (`giftID`)
);

-- transaction table
CREATE TABLE `GiftHistories` (
	-- attributes
	`playerID` int not null,
	`villagerID` int not null,
	`giftID` int not null,
	`givenDate` datetime not null,

	-- constraints
	PRIMARY KEY (`playerID`, `villagerID`, `giftID`, `givenDate`),
	FOREIGN KEY (`playerID`) REFERENCES Players (`playerID`) ON DELETE CASCADE,
	FOREIGN KEY (`villagerID`) REFERENCES Villagers (`villagerID`) ON DELETE CASCADE,
	FOREIGN KEY (`giftID`) REFERENCES Gifts (`giftID`) ON DELETE CASCADE
);


-- #################################################
-- ############### NON-ENTITY TABLES ###############
-- #################################################

-- intersection table
CREATE TABLE `PlayersVillagersRelationships` (
	-- attributes
	`playerID` int not null,
	`villagerID` int not null,
	`friendshipLevel` int not null default 0,

	-- constraints
	PRIMARY KEY (`playerID`, `villagerID`),
	FOREIGN KEY (`playerID`) REFERENCES Players (`playerID`) ON DELETE CASCADE,
	FOREIGN KEY (`villagerID`) REFERENCES Villagers (`villagerID`) ON DELETE CASCADE
);

-- intersection table
CREATE TABLE `VillagersGiftsPreferences` (
	-- attributes
	`villagerID` int not null,
	`giftID` int not null,
	`preference` varchar(50) not null default 'neutral',

	-- constraints
	PRIMARY KEY (`villagerID`, `giftID`),
	FOREIGN KEY (`villagerID`) REFERENCES Villagers (`villagerID`) ON DELETE CASCADE,
	FOREIGN KEY (`giftID`) REFERENCES Gifts (`giftID`) ON DELETE CASCADE
);


-- ####################################################
-- ################ INSERTION SCRIPTS #################
-- ####################################################

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

-- 3) Villagers (A farm with multiple villagers: Haley & Jas on Farm 1)
INSERT INTO `Villagers`
 (`villagerName`,`birthdaySeason`,`birthdayDay`,`homeArea`,`farmID`)
VALUES
 ('Haley', 'Spring', 14, 'Pelican Town', (SELECT farmID FROM Farms WHERE farmName = 'Yellow Submarine')),
 ('Jas', 'Summer', 4, 'Pelican Town', (SELECT farmID FROM Farms WHERE farmName = 'Yellow Submarine')),
 ('Sebastian', 'Winter', 10, 'The Mountain', (SELECT farmID FROM Farms WHERE farmName = 'Lake District')),
 ('Abigail', 'Fall', 13, 'Pelican Town', (SELECT farmID FROM Farms WHERE farmName = 'Abbey Orchard'));

-- 4) Gifts (5 sample gifts)
INSERT INTO `Gifts` (`giftName`,`value`,`seasonAvailable`) VALUES
 ('Amethyst', 120.00, 'Winter'),
 ('Pumpkin', 60.00, 'Fall'),
 ('Pepper Poppers', 40.00, 'Summer'),
 ('Chocolate Cake', 75.00, NULL),
 ('Coconut', 75.00, 'Summer');

-- 5) GiftHistories (Haley gets two gifts)
INSERT INTO `GiftHistories` (`playerID`,`villagerID`,`giftID`,`givenDate`) VALUES
 ((SELECT playerID FROM Players WHERE playerName = 'Ringo'), 
  (SELECT villagerID FROM Villagers WHERE villagerName = 'Haley'), 
  (SELECT giftID FROM Gifts WHERE giftName = 'Coconut'), 
  '2025-04-14'), -- Ringo → Haley (Coconut on Spring 14)
 ((SELECT playerID FROM Players WHERE playerName = 'Ringo'), 
  (SELECT villagerID FROM Villagers WHERE villagerName = 'Haley'), 
  (SELECT giftID FROM Gifts WHERE giftName = 'Pepper Poppers'), 
  '2025-05-01'), -- Ringo → Haley (Pepper Poppers on 2025‑05‑01)
 ((SELECT playerID FROM Players WHERE playerName = 'John'), 
  (SELECT villagerID FROM Villagers WHERE villagerName = 'Sebastian'), 
  (SELECT giftID FROM Gifts WHERE giftName = 'Amethyst'), 
  '2025-12-10'), -- John → Sebastian (Amethyst on Winter 10)
 ((SELECT playerID FROM Players WHERE playerName = 'Paul'), 
  (SELECT villagerID FROM Villagers WHERE villagerName = 'Abigail'), 
  (SELECT giftID FROM Gifts WHERE giftName = 'Amethyst'), 
  '2025-10-13'); -- Paul → Abigail (Amethyst on Fall 13)

-- 6) PlayersVillagersRelationships (Ringo knows two villagers)
INSERT INTO `PlayersVillagersRelationships`
 (`playerID`,`villagerID`,`friendshipLevel`)
VALUES
 ((SELECT playerID FROM Players WHERE playerName = 'Ringo'), 
  (SELECT villagerID FROM Villagers WHERE villagerName = 'Haley'), 
  3), -- Ringo & Haley
 ((SELECT playerID FROM Players WHERE playerName = 'Ringo'), 
  (SELECT villagerID FROM Villagers WHERE villagerName = 'Abigail'), 
  1), -- Ringo & Abigail
 ((SELECT playerID FROM Players WHERE playerName = 'John'), 
  (SELECT villagerID FROM Villagers WHERE villagerName = 'Sebastian'), 
  5), -- John & Sebastian
 ((SELECT playerID FROM Players WHERE playerName = 'Paul'), 
  (SELECT villagerID FROM Villagers WHERE villagerName = 'Abigail'), 
  8); -- Paul & Abigail

-- 7) VillagersGiftsPreferences
INSERT INTO `VillagersGiftsPreferences`
 (`villagerID`,`giftID`,`preference`)
VALUES
 ((SELECT villagerID FROM Villagers WHERE villagerName = 'Haley'), 
  (SELECT giftID FROM Gifts WHERE giftName = 'Coconut'), 
  'love'), -- Haley loves Coconut
 ((SELECT villagerID FROM Villagers WHERE villagerName = 'Haley'), 
  (SELECT giftID FROM Gifts WHERE giftName = 'Amethyst'), 
  'like'), -- Haley likes Amethyst
 ((SELECT villagerID FROM Villagers WHERE villagerName = 'Sebastian'), 
  (SELECT giftID FROM Gifts WHERE giftName = 'Amethyst'), 
  'love'), -- Sebastian loves Amethyst
 ((SELECT villagerID FROM Villagers WHERE villagerName = 'Abigail'), 
  (SELECT giftID FROM Gifts WHERE giftName = 'Amethyst'), 
  'love'), -- Abigail loves Amethyst
 ((SELECT villagerID FROM Villagers WHERE villagerName = 'Abigail'), 
  (SELECT giftID FROM Gifts WHERE giftName = 'Chocolate Cake'), 
  'like'); -- Abigail likes Chocolate Cake

SET FOREIGN_KEY_CHECKS = 1;
COMMIT;