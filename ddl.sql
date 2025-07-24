
-- #################################################
-- ########## ESSENTIAL TABLES (ENTITIES) ##########
-- #################################################
CREATE OR REPLACE TABLE `Players` (
	-- attributes
	`playerID` int not null auto_increment,
	`playerName` varchar(100) not null,

	-- constraints
	PRIMARY KEY (`playerID`)
);

CREATE OR REPLACE TABLE `Farms` (
	-- attributes
	`farmID` int not null auto_increment,
	`playerID` int not null unique,
	`farmName` varchar(100) not null,
	`farmType` varchar(50) not null,

	-- constraints
	PRIMARY KEY (`farmID`),
	FOREIGN KEY (`playerID`) REFERENCES Players (`playerID`)
);

CREATE OR REPLACE TABLE `Villagers` (
	-- attributes
	`villagerID` int not null auto_increment,
	`villagerName` varchar(100) not null,
	`birthday` date not null,
	`homeArea` varchar(100) not null,
	`assignedFarmID` int,

	-- constraints
	PRIMARY KEY (`villagerID`),
	FOREIGN KEY (`assignedFarmID`) REFERENCES Farms (`farmID`)
);

CREATE OR REPLACE TABLE `Gifts` (
	-- attributes
	`giftID` int not null auto_increment,
	`giftName` varchar(100) not null,
	`value` decimal(8,2) not null,
	`seasonAvailable` varchar(20),
	
	-- constraints
	PRIMARY KEY (`giftID`)
);



-- #################################################
-- ############## TRANSACTION TABLES ###############
-- #################################################
CREATE OR REPLACE TABLE `GiftHistories` (
	-- attributes
	`playerID` int not null,
	`villagerID` int not null,
	`giftID` int not null,
	`givenDate` date not null,

	-- constraints
	PRIMARY KEY (`playerID`, `villagerID`, `giftID`),
	FOREIGN KEY (`playerID`) REFERENCES Players (`playerID`),
	FOREIGN KEY (`villagerID`) REFERENCES Villagers (`villagerID`),
	FOREIGN KEY (`giftID`) REFERENCES Gifts (`giftID`)
);



-- #################################################
-- ############## INTERSECTION TABLES ##############
-- #################################################
CREATE OR REPLACE TABLE `PlayersVillagersRelationships` (
	-- attributes
	`playerID` int not null,
	`villagerID` int not null,
	`friendshipLevel` int not null default 0,
	`relationshipLevel` varchar(50) not null default 'acquaintance',

	-- constraints
	PRIMARY KEY (`playerID`, `villagerID`),
	FOREIGN KEY (`playerID`) REFERENCES Players (`playerID`),
	FOREIGN KEY (`villagerID`) REFERENCES Villagers (`villagerID`)
);

CREATE OR REPLACE TABLE `VillagersGiftsPreferences` (
	-- attributes
	`villagerID` int not null,
	`giftID` int not null,
	`preference` varchar(50) not null default 'neutral',

	-- constraints
	PRIMARY KEY (`villagerID`, `giftID`),
	FOREIGN KEY (`villagerID`) REFERENCES Villagers (`villagerID`),
	FOREIGN KEY (`giftID`) REFERENCES Gifts (`giftID`)
);


