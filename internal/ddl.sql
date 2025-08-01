-- ##################################################
-- ##### Justice Peyton, Zachary Wilkins-Olson 	#####
-- ##### CS340                                  #####
-- #####                                        #####
-- #####            Stardew Valley:             #####
-- #####     Pelican Town Social Registry       #####
-- ##################################################

-- ############################################
-- ##### Brief Description of the project #####
-- ############################################
-- This project is a social registry for Stardew Valley, focusing on the relationships between players, villagers, and gifts.
-- It includes tables for players, farms, villagers, gifts, gift histories, and relationships between players and villagers.


-- #################################################
-- ################# STARDEW VALLEY DDL ############
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
	`assignedFarmID` int,

	-- constraints
	PRIMARY KEY (`villagerID`),
	FOREIGN KEY (`assignedFarmID`) REFERENCES Farms (`farmID`) ON DELETE CASCADE
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
	`givenDate` date not null,

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
	`relationshipLevel` varchar(50) not null default 'acquaintance',

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
-- ################# INSERTION SCRIPTS #################
-- ####################################################

-- 1) Players
INSERT INTO `Players` (`playerName`) VALUES
  ('Ringo'),
  ('John'),
  ('Paul');

-- 2) Farms (one per player)
INSERT INTO `Farms` (`playerID`,`farmName`,`farmType`) VALUES
  (1, 'Yellow Submarine', 'Standard'),
  (2, 'Lake District',    'Riverland'),
  (3, 'Abbey Orchard',    'Forest');

-- 3) Villagers (A farm with multiple villagers: Haley & Jas on Farm 1)
INSERT INTO `Villagers`
  (`villagerName`,`birthdaySeason`,`birthdayDay`,`homeArea`,`assignedFarmID`)
VALUES
  ('Haley',      'Spring', 14, 'Pelican Town',     1),
  ('Jas',        'Summer',  4, 'Pelican Town',     1),
  ('Sebastian',  'Winter', 10, 'The Mountain',     2),
  ('Abigail',    'Fall',   13, 'Pelican Town',     3);

-- 4) Gifts (5 sample gifts)
INSERT INTO `Gifts` (`giftName`,`value`,`seasonAvailable`) VALUES
  ('Amethyst',      120.00, 'Winter'),
  ('Pumpkin',        60.00, 'Fall'),
  ('Pepper Poppers', 40.00, 'Summer'),
  ('Chocolate Cake', 75.00, NULL),
  ('Coconut',        75.00, 'Summer');

-- 5) GiftHistories (Haley gets two gifts to show 1:M)
INSERT INTO `GiftHistories` (`playerID`,`villagerID`,`giftID`,`givenDate`) VALUES
  (1, 1, 5, '2025-04-14'),  -- Ringo → Haley (Coconut on Spring 14)
  (1, 1, 3, '2025-05-01'),  -- Ringo → Haley (Pepper Poppers on 2025‑05‑01)
  (2, 3, 1, '2025-12-10'),  -- John  → Sebastian (Amethyst on Winter 10)
  (3, 4, 1, '2025-10-13');  -- Paul  → Abigail (Amethyst on Fall 13)

-- 6) PlayersVillagersRelationships (Ringo knows two villagers, showing M:M)
INSERT INTO `PlayersVillagersRelationships`
  (`playerID`,`villagerID`,`friendshipLevel`,`relationshipLevel`)
VALUES
  (1, 1, 3, 'friend'),         -- Ringo & Haley
  (1, 4, 1, 'acquaintance'),   -- Ringo & Abigail
  (2, 3, 5, 'friend'),         -- John & Sebastian
  (3, 4, 8, 'best friend');    -- Paul & Abigail

-- 7) VillagersGiftsPreferences (Villagers can prefer multiple gifts, gifts can appear for multiple villagers)
INSERT INTO `VillagersGiftsPreferences`
  (`villagerID`,`giftID`,`preference`)
VALUES
  (1, 5, 'love'),  -- Haley loves Coconut
  (1, 1, 'like'),  -- Haley likes Amethyst
  (2, 1, 'love'),  -- Sebastian loves Amethyst
  (3, 1, 'love'),  -- Abigail loves Amethyst
  (3, 4, 'like');  -- Abigail likes Chocolate Cake

SET FOREIGN_KEY_CHECKS = 1;
COMMIT;