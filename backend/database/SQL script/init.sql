DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Restaurants CASCADE;
DROP TABLE IF EXISTS Food CASCADE;
DROP TABLE IF EXISTS Sells CASCADE;
DROP TABLE IF EXISTS Restaurant_Staff CASCADE;
DROP TABLE IF EXISTS FDS_Managers CASCADE;
DROP TABLE IF EXISTS Customers CASCADE;
DROP TABLE IF EXISTS Riders CASCADE;
DROP TABLE IF EXISTS Part_Time CASCADE;
DROP TABLE IF EXISTS Full_Time CASCADE;
DROP TABLE IF EXISTS Monthly_Work_Schedules CASCADE;
DROP TABLE IF EXISTS Weekly_Work_Schedules CASCADE;
DROP TABLE IF EXISTS Intervals CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS Contains CASCADE;
DROP TABLE IF EXISTS Delivers CASCADE;
DROP TABLE IF EXISTS Promotions CASCADE;
DROP TABLE IF EXISTS MinSpendingPromotions CASCADE;
DROP TABLE IF EXISTS CustomerPromotions CASCADE;

CREATE TABLE Users (
	userId 		SERIAL,
	name		VARCHAR(100),
    PRIMARY KEY (userId)
);

CREATE TABLE Restaurants (

	rname 		VARCHAR(200),
	minOrderAmt	NUMERIC(8, 2),
	area 		VARCHAR(20),
    PRIMARY KEY (rname),
	CHECK(area = 'central' OR
		 area = 'west' OR
		 area = 'east' OR
		 area = 'north' OR
		 area = 'south')
);

CREATE TABLE Food (

	fname 		VARCHAR(200),
	category 	VARCHAR(20) NOT NULL,
    	PRIMARY KEY (fname),
	CHECK (category = 'western' OR
		   category = 'chinese' OR
		   category = 'japanese' OR
		   category = 'korean' OR
		   category = 'fusion')
);

CREATE TABLE Sells (
	rname 		VARCHAR(200) REFERENCES Restaurants on DELETE CASCADE on UPDATE CASCADE,
    fname 		VARCHAR(200) REFERENCES Food on DELETE CASCADE on UPDATE CASCADE,
    price 		NUMERIC(8, 2) NOT NULL,
    availability 	INTEGER DEFAULT 10,
    PRIMARY KEY (rname, fname) 
);

CREATE TABLE Restaurant_Staff (
	userId 		INTEGER,
	rname		VARCHAR(200) REFERENCES Restaurants on DELETE CASCADE on UPDATE CASCADE,
	PRIMARY KEY (userId),
	FOREIGN KEY (userId) REFERENCES Users
			on DELETE CASCADE
			on UPDATE CASCADE

);

CREATE TABLE FDS_Managers (
	userId 		INTEGER,
    PRIMARY KEY (userId),
    FOREIGN KEY (userId) REFERENCES Users
    			on DELETE CASCADE
			    on UPDATE CASCADE
);

CREATE TABLE Customers (
                           userId 		INTEGER,
                           creditCardInfo	VARCHAR(100),
                           PRIMARY KEY (userId),
                           FOREIGN KEY (userId) REFERENCES Users
                               on DELETE CASCADE
                               on UPDATE CASCADE
);

CREATE TABLE Riders (
                        userId 		INTEGER,
                        area 		VARCHAR(20) NOT NULL,
                        PRIMARY KEY (userId),
                        FOREIGN KEY (userId) REFERENCES Users
                            on DELETE CASCADE
                            on UPDATE CASCADE,
                        CHECK(area = 'central' OR
                              area = 'west' OR
                              area = 'east' OR
                              area = 'north' OR
                              area = 'south')
);

CREATE TABLE Part_Time
(
    userId INTEGER,
    PRIMARY KEY (userId),
    FOREIGN KEY (userId) REFERENCES Riders
        on DELETE CASCADE
        on UPDATE CASCADE
--        DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE Full_Time
(
    userId INTEGER,
    PRIMARY KEY (userId),
    FOREIGN KEY (userId) REFERENCES Riders
        on DELETE CASCADE
        on UPDATE CASCADE
--        DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE Weekly_Work_Schedules
(
    scheduleId SERIAL,
    userId     INTEGER,
    startDate  TIMESTAMP,
    endDate    TIMESTAMP,
    PRIMARY KEY (scheduleId),
    FOREIGN KEY (userId) REFERENCES Riders (userId),
    check ((endDate::date - startDate::date) = 6)
);


CREATE TABLE Monthly_Work_Schedules (
        scheduleId1  INTEGER REFERENCES Weekly_Work_Schedules ON DELETE CASCADE,
        scheduleId2  INTEGER REFERENCES Weekly_Work_Schedules ON DELETE CASCADE,
        scheduleId3  INTEGER REFERENCES Weekly_Work_Schedules ON DELETE CASCADE,
        scheduleId4  INTEGER REFERENCES Weekly_Work_Schedules ON DELETE CASCADE,
        PRIMARY KEY (scheduleId1, scheduleId2, scheduleId3, scheduleId4)
    --DEFERRED TRIGGER TO CHECK FOR CONSTRAINTS (FOR BOTH INTERVAL & SCHEDULE)
);

CREATE TABLE Intervals
(
    intervalId SERIAL,
    scheduleId INTEGER,
    startTime  TIMESTAMP,
    endTime    TIMESTAMP,
    PRIMARY KEY (intervalId),
    FOREIGN KEY (scheduleId) REFERENCES Weekly_Work_Schedules (scheduleId)
        ON DELETE CASCADE,
        check (DATE_PART('minutes', startTime) = 0
        AND
           DATE_PART('seconds', startTime) = 0
        AND
           DATE_PART('minutes', endTime) = 0
        AND
           DATE_PART('seconds', startTime) = 0
        AND
           DATE_PART('hours', endTime) - DATE_PART('hours', startTime) <= 4
        AND
           startTime::date = endTime::date
        AND
           DATE_PART('hours', endTime) > DATE_PART('hours', startTime)
        AND
           startTime::time >= '10:00'
        AND
           endTime::time <= '22:00'
        )
);


--able to share the same promoCode. FD = free delivery
CREATE TABLE Promotions (

	promoCode	    VARCHAR(20),	
	promoDesc 		VARCHAR(200),
	createdBy	    VARCHAR(50), --?
	applicableTo	VARCHAR(200) REFERENCES Restaurants(rname) ON DELETE CASCADE,
	discUnit	    VARCHAR(20) NOT NULL,
	discRate	    INTEGER DEFAULT 0,
	startDate	    TIMESTAMP NOT NULL,
	endDate	        TIMESTAMP NOT NULL,
	PRIMARY KEY (promoCode, applicableTo),
    CHECK(discUnit = '$' OR discUnit = '%' OR discUnit = 'FD')

);

--TODO: TRIGGER FOR used reward Points make sure used reward points lesser than actual
CREATE TABLE Orders (
	orderId 		SERIAL,
	userId 			INTEGER NOT NULL REFERENCES Customers ON DELETE CASCADE ON UPDATE CASCADE,
	promoCode		VARCHAR(20),
  applicableTo	VARCHAR(200),
	modeOfPayment 	VARCHAR(10) NOT NULL,
	timeOfOrder		TIMESTAMP NOT NULL,
	deliveryLocation	VARCHAR(100) NOT NULL,
	usedRewardPoints	INTEGER NOT NULL DEFAULT 0,
	
	PRIMARY KEY(orderId),
	FOREIGN KEY(promoCode, applicableTo)  REFERENCES Promotions,
	CHECK(modeOfPayment = 'cash' OR
		 	modeOfPayment ='credit'),
    CHECK(usedRewardPoints = 5 OR usedRewardPoints = 10 OR usedRewardPoints = 15 OR usedRewardPoints = 0)

);

CREATE TABLE Contains (
                          orderId 		INTEGER REFERENCES Orders ON DELETE CASCADE ON UPDATE CASCADE,
                          rname			VARCHAR(100),
                          fname 			VARCHAR(100),
                          foodQty		    INTEGER NOT NULL,
                          reviewContent	VARCHAR(300),

                          PRIMARY KEY(orderId, rname, fname),
                          FOREIGN KEY(rname, fname) REFERENCES Sells(rname, fname),
                          CHECK(foodQty >= 1)
);

CREATE TABLE Delivers (
                          orderId			        	INTEGER REFERENCES Orders ON DELETE CASCADE ON UPDATE CASCADE,
                          userId				        INTEGER NOT NULL,
                          departTimeForRestaurant	    TIMESTAMP,
                          departTimeFromRestaurant    TIMESTAMP,
                          arrivalTimeAtRestaurant	    TIMESTAMP,
                          deliveryTimetoCustomer	    TIMESTAMP,
                          rating			    INTEGER,
                          PRIMARY KEY (orderId),
                          FOREIGN KEY (userId) REFERENCES Riders ON DELETE CASCADE,
                          CHECK(rating <= 5)
);

-- Free delivery
CREATE TABLE MinSpendingPromotions (
                                       promoCode	    VARCHAR(20),
                                       applicableTo	VARCHAR(200),
                                       minAmt	        NUMERIC(8, 2) DEFAULT 0,
                                       PRIMARY KEY (promoCode, applicableTo),
                                       FOREIGN KEY (promoCode, applicableTo) REFERENCES Promotions ON DELETE CASCADE ON UPDATE CASCADE
);

-- a certain amount off
CREATE TABLE CustomerPromotions (
    promoCode		VARCHAR(20),	
	applicableTo	VARCHAR(200),
	minTimeFromLastOrder 	INTEGER, -- # of days
	PRIMARY KEY (promoCode, applicableTo),
	FOREIGN KEY (promoCode, applicableTo) REFERENCES Promotions ON DELETE CASCADE ON UPDATE CASCADE
);	

/* Trigger functions */

DROP FUNCTION IF EXISTS check_mws_5days_consecutive_constraint_deferred() CASCADE;
CREATE OR REPLACE FUNCTION check_mws_5days_consecutive_constraint_deferred() RETURNS TRIGGER AS
$$
DECLARE
    lastIntervalStartTime  TIMESTAMP;
    firstIntervalStartTime TIMESTAMP;
    distinctDates          INTEGER;
BEGIN
    WITH curr_Intervals AS (
        SELECT *
        FROM Intervals I
        WHERE I.scheduleId = NEW.scheduleId1
    )
    SELECT startTime
    into lastIntervalStartTime
    FROM curr_Intervals I
    ORDER BY endTime DESC
    LIMIT 1;

    WITH curr_Intervals AS (
        SELECT *
        FROM Intervals I2
        WHERE I2.scheduleId = NEW.scheduleId1
    )
    SELECT startTime
    into firstIntervalStartTime
    FROM curr_Intervals I
    ORDER BY endTime ASC
    LIMIT 1;

    WITH curr_Intervals AS (
        SELECT *
        FROM Intervals I3
        WHERE I3.scheduleId = NEW.scheduleId1
    )
    SELECT COUNT(DISTINCT I.startTime::date)
    into distinctDates
    FROM curr_Intervals I;
    IF ((lastIntervalStartTime::date - firstIntervalStartTime::date) <> 4 --all intervals within 5 days
        OR distinctDates <> 5) -- each day got interval
    THEN
        RAISE EXCEPTION 'MWS must have 5 consecutive work days';
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;


DROP TRIGGER IF EXISTS mws_5days_trigger ON Monthly_Work_Schedules CASCADE;
CREATE CONSTRAINT TRIGGER mws_5days_trigger
    AFTER INSERT
    ON Monthly_Work_Schedules
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION check_mws_5days_consecutive_constraint_deferred();

DROP FUNCTION IF EXISTS check_mws_28days_constraint_deferred() CASCADE;
CREATE OR REPLACE FUNCTION check_mws_28days_constraint_deferred() RETURNS TRIGGER AS $$
DECLARE
    newEndDate DATE;
    newStartDate DATE;
BEGIN
    SELECT endDate into newEndDate
    FROM Weekly_Work_Schedules S
    WHERE S.scheduleId = NEW.scheduleId4;
    SELECT startDate into newStartDate
    FROM Weekly_Work_Schedules S2
    WHERE S2.scheduleId = NEW.scheduleId1
    ;
    IF (newEndDate - newStartDate) <> 27 THEN
        RAISE EXCEPTION 'MWS must be declared for 28 days only.';
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;


DROP TRIGGER IF EXISTS mws_28days_trigger ON Monthly_Work_Schedules CASCADE;
CREATE CONSTRAINT TRIGGER mws_28days_trigger
    AFTER INSERT
    ON Monthly_Work_Schedules
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION check_mws_28days_constraint_deferred();

-- if conform to predefined timings
DROP FUNCTION IF EXISTS check_mws_intervals_constraint_deferred() CASCADE;
CREATE OR REPLACE FUNCTION check_mws_intervals_constraint_deferred() RETURNS TRIGGER AS $$
	DECLARE
		badInputSchedule 	INTEGER;
BEGIN
    WITH curr_Intervals AS (
        SELECT *
        FROM Intervals I
        WHERE I.scheduleId = NEW.scheduleId1
    ),
    Interval_Pairs (intervalId1, startTime1, endTime1, intervalId2, startTime2, endTime2) AS (
        select cI1.intervalId, cI1.startTime, cI1.endTime, cI2.intervalId, cI2.startTime, cI2.endTime
        from curr_Intervals cI1, curr_Intervals cI2
        where cI1.startTime::date = cI2.startTime::date -- 2 intervals of the same day
        and cI1.startTime::time < cI2.startTime::time -- cI1 is the earlier timing, cI2 the later
    )
    SELECT S.scheduleId INTO badInputSchedule
    FROM Weekly_Work_Schedules S
    WHERE S.scheduleId = NEW.scheduleId1
    AND (
        NOT EXISTS ( -- table is non-empty
        select 1 from Interval_Pairs IP2 limit 1
        )
        OR
        EXISTS ( --checks for any bad intervals
            SELECT 1
            FROM Interval_Pairs IP
            WHERE (select count(*) from Interval_Pairs) <> ((select count(*) from curr_Intervals) / 2) -- each interval has a pair
            OR NOT(
                IP.startTime1::time = '10:00' OR
                IP.startTime1::time = '11:00' OR
                IP.startTime1::time = '12:00' OR
                IP.startTime1::time = '13:00'
            )
            OR NOT (DATE_PART('hours', IP.endTime1) - DATE_PART('hours',IP.startTime1) = 4
                AND DATE_PART('hours', IP.endTime1) - DATE_PART('hours',IP.startTime1) = 4)

            OR NOT (DATE_PART('hours', IP.startTime2) - DATE_PART('hours',IP.endTime1) = 1)
        )
    )
;

    IF badInputSchedule IS NOT NULL THEN
    RAISE EXCEPTION '% violates some timing in Intervals', badInputSchedule;
    END IF;
    RETURN NULL;
	END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS mws_predefined_interval_trigger ON Monthly_Work_Schedules CASCADE;
CREATE CONSTRAINT TRIGGER mws_predefined_interval_trigger
    AFTER INSERT
    ON Monthly_Work_Schedules
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION check_mws_intervals_constraint_deferred();


CREATE OR REPLACE FUNCTION check_intervals_overlap_deferred() RETURNS TRIGGER AS
$$
DECLARE
    badInputSchedule INTEGER;
BEGIN
    SELECT DISTINCT I1.scheduleId
    INTO badInputSchedule
    FROM Intervals I1
    WHERE EXISTS(
                  SELECT 1
                  FROM Intervals I2
                  WHERE I2.scheduleId = I1.scheduleId
                    AND I2.intervalId <> I1.intervalId
                    AND I2.startTime::date = I1.startTime::date
                    AND (
                          (I2.startTime::time <= I1.startTime::time
                              AND I2.endTime::time >= I1.startTime::time)
                          --IE: first input shift 2-5pm , current input shift 3 - 4pm / 3 - 6pm etc
                          OR
                          (I2.startTime::time <= I1.endTime::time
                              AND I2.endTime::time >= I1.endTime::time)
                          --IE: first input shift 2-5pm, current input shift 12pm - 3pm / 12pm - 6pm
                          OR (
                                      DATE_PART('hours', I1.startTime) - DATE_PART('hours', I2.endTime) < 1
                                  AND DATE_PART('hours', I1.startTime) >= DATE_PART('hours', I2.endTime)
                              -- if current inputted shift start time is less than 1hr from other shifts end time, violated (of the same day).
                              -- this constraint should also be covered without this last statement when the intervals start and end on the hour
                              -- constraint is enforced
                              )
                      )
              );
    IF badInputSchedule IS NOT NULL THEN
        RAISE EXCEPTION 'scheduleId % has some overlapping intervals', badInputSchedule;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS interval_overlap_trigger ON Intervals CASCADE;
CREATE CONSTRAINT TRIGGER interval_overlap_trigger
    AFTER INSERT
    ON Intervals
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION check_intervals_overlap_deferred();


CREATE OR REPLACE FUNCTION check_wws_duration_deferred() RETURNS TRIGGER AS
$$
DECLARE
    badInputSchedule INTEGER;
BEGIN
    WITH IntervalDuration AS
    (
    SELECT IntervalId, scheduleId, startTime, endTime,
    date_part('hours', endTime) - date_part('hours',startTime) as duration
    FROM Intervals
    )
    SELECT DISTINCT scheduleId INTO badInputSchedule
    FROM IntervalDuration
    WHERE scheduleId = NEW.scheduleId
    GROUP BY scheduleId
    HAVING sum(duration) >= 10 and sum(duration) <= 48
    ;

    IF badInputSchedule IS NULL THEN
        RAISE EXCEPTION '% : Total duration of weekly schedule cannot be < 10 or > 48', badInputSchedule;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS wws_duration_trigger ON Weekly_Work_Schedules CASCADE;
CREATE CONSTRAINT TRIGGER wws_duration_trigger
    AFTER INSERT
    ON Weekly_Work_Schedules
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION check_wws_duration_deferred();


CREATE OR REPLACE FUNCTION check_wws_within_seven_days_deferred () RETURNS TRIGGER AS $$
DECLARE
    badInputInterval INTEGER;
BEGIN
    SELECT intervalId into badInputInterval
    FROM  Intervals I
    WHERE I.scheduleId = NEW.scheduleId
    AND EXISTS (
        SELECT 1
        FROM Weekly_Work_Schedules WWS
        WHERE WWS.scheduleId = NEW.scheduleId
        AND (
            I.startTime::date < WWS.startDate::date
            OR
            I.startTime::date > WWs.endDate::date
        )
    )
    ;
    IF badInputInterval IS NOT NULL THEN
        RAISE EXCEPTION 'Intervals in newly added schedule must not exceed 7 days';
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;


DROP TRIGGER IF EXISTS wws_seven_days_trigger ON Weekly_Work_Schedules CASCADE;
CREATE CONSTRAINT TRIGGER wws_seven_days_trigger
    AFTER INSERT ON Weekly_Work_Schedules
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION check_wws_within_seven_days_deferred ();


CREATE OR REPLACE FUNCTION check_wws_overlap_deferred() RETURNS TRIGGER AS
$$
DECLARE
    badInputSchedule INTEGER;
BEGIN
    SELECT S1.scheduleId INTO badInputSchedule
    FROM Weekly_Work_Schedules S1
    WHERE EXISTS(
                  SELECT 1
                  FROM Weekly_Work_Schedules S2
                  WHERE S2.scheduleId <> S1.scheduleId
                  AND S2.userId = S1.userId
                    AND (
                          (S2.startDate::date <= S1.startDate::date
                              AND S2.endDate::date >= S1.startDate::date)
                          OR
                          (S2.startDate::date <= S1.endDate::date
                              AND S2.endDate::date >= S1.endDate::date)
                      )
              );
    IF badInputSchedule IS NOT NULL THEN
        RAISE EXCEPTION 'Newly added schedule must start after the latest schedule';
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE PLPGSQL;


DROP TRIGGER IF EXISTS wws_overlap_trigger ON Weekly_Work_Schedules CASCADE;
CREATE CONSTRAINT TRIGGER wws_overlap_trigger
    AFTER INSERT
    ON Weekly_Work_Schedules
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
EXECUTE FUNCTION check_wws_overlap_deferred();


---FOR ORDERS CALCULATION---
DROP FUNCTION IF EXISTS calculatePrice CASCADE;
CREATE OR REPLACE FUNCTION calculatePrice(rname VARCHAR(20), fname VARCHAR(20), foodQty INTEGER) 
RETURNS NUMERIC(4,2) AS $$
    SELECT S.price * foodQty
    FROM SELLS S
    WHERE S.fname = fname AND S.rname = rname
$$ LANGUAGE SQL
;

--nonpeak vs peak hour deliveryfee
DROP FUNCTION IF EXISTS getDeliveryFee CASCADE;
CREATE OR REPLACE FUNCTION getDeliveryFee(orderTime TIMESTAMP, orderId1 INTEGER)
RETURNS NUMERIC(4,2) AS $$
    DECLARE
        test time;
        amount NUMERIC(4,2);
    
    BEGIN
        test = orderTime::time;
        CASE
            WHEN EXISTS(
                SELECT 1 FROM Orders O JOIN Promotions P ON O.promoCode = P.promoCode AND O.applicableTo = P.applicableTo
                WHERE O.orderId = orderId1 AND P.discUnit = 'FD' 
            ) then amount = 0.00;
            WHEN test < '19:10:00' AND test > '17:00:00'then amount = 10.00;
            else amount = 5.00;
        END CASE;
        RETURN amount;
    END;
$$ LANGUAGE PLPGSQL;

DROP FUNCTION IF EXISTS getearnedRewardPts CASCADE;
CREATE OR REPLACE FUNCTION getearnedRewardPts(foodprice NUMERIC(4,2))
RETURNS NUMERIC(4,0) AS $$
    SELECT FLOOR(foodprice / 10.0)
$$ LANGUAGE SQL;

DROP FUNCTION IF EXISTS getTotalPriceAdjustedForRewards CASCADE;
CREATE OR REPLACE FUNCTION getTotalPriceAdjustedForRewards(foodprice NUMERIC(4,2), rewardPt INTEGER)
RETURNS NUMERIC(4,0) AS $$
    SELECT foodprice - (rewardPt/5)
$$ LANGUAGE SQL;

DROP FUNCTION IF EXISTS calculateTotalPriceAfterPromotionAndRewards CASCADE;
CREATE OR REPLACE FUNCTION calculateTotalPriceAfterPromotionAndRewards(
    foodprice NUMERIC(4,2), deliveryfee NUMERIC(4,2), promoCode1 VARCHAR(20),
    applicableTo1 VARCHAR(200), usedRewardPoints INTEGER
)

RETURNS NUMERIC(4,2) AS $$
    DECLARE 
        amount NUMERIC(4,2);
        discRate INTEGER;
    
    BEGIN 
        SELECT P.discRate INTO discRate
                    FROM PROMOTIONS P 
                    WHERE P.promoCode = promoCode1 AND P.applicableTo = applicableTo1;
        CASE
            -- NO PROMOTION
            WHEN ((promoCode1 IS NULL) AND (applicableTo1 IS NULL)) 
                THEN amount = 
                (getTotalPriceAdjustedForRewards(foodprice, usedRewardPoints) + deliveryfee);
            -- $ PROMOTION
            WHEN EXISTS (
                SELECT 1 
                FROM PROMOTIONS P
                WHERE  P.promoCode = promoCode1 AND P.applicableTo = applicableTo1 AND P.discUnit = '$') 

                THEN amount = (getTotalPriceAdjustedForRewards(foodprice, usedRewardPoints) - discRate
                    + deliveryfee);
            -- Free Delivery PROMOTION
            WHEN EXISTS (
                SELECT 1 
                FROM PROMOTIONS P
                WHERE  P.promoCode = promoCode1 AND P.applicableTo = applicableTo1 AND P.discUnit = 'FD')
            THEN amount = (
                getTotalPriceAdjustedForRewards(foodprice, usedRewardPoints) 
            );
            -- % PROMOTION
            WHEN EXISTS (
                SELECT 1
                FROM PROMOTIONS P
                WHERE  P.promoCode = promoCode1 AND P.applicableTo = applicableTo1 AND P.discUnit = '%'
            ) THEN amount = getTotalPriceAdjustedForRewards(foodprice, usedRewardPoints) * (100-discRate) / 100 
                    + deliveryfee;
            --throw error.
            ELSE amount = -1.00;
        END CASE;

        IF amount < 0 THEN
            RAISE EXCEPTION 'final price should be more than or equal to 0';
        END IF;   

        RETURN amount;
    END;
$$ LANGUAGE PLPGSQL;


DROP VIEW IF EXISTS OrderInfo CASCADE;
CREATE VIEW OrderInfo AS
   
SELECT O.orderId, O.userId, C.rname, sum(calculatePrice(C.rname, C.fname, C.foodQty)) as totalFoodPrice, 
        getDeliveryFee(O.timeOfOrder, O.orderId) as deliveryfee,
        O.timeOfOrder,
        getearnedRewardPts(sum(calculatePrice(C.rname, C.fname, C.foodQty))) as earnedRewardPts, 
        O.usedRewardPoints, 
        calculateTotalPriceAfterPromotionAndRewards(sum(calculatePrice(C.rname, C.fname, C.foodQty)),
        getDeliveryFee(O.timeOfOrder, O.orderId), O.promoCode, O.applicableTo, O.usedRewardPoints) as finalPrice
        
    FROM ORDERS O JOIN CONTAINS C ON O.orderId = C.orderId
    GROUP BY O.orderId, C.rname, O.timeOfOrder
    ORDER BY O.orderId ASC;
---END OF ORDERS CALCULATION---

DELETE FROM Users;
DELETE FROM Restaurants;
DELETE FROM Food;
DELETE FROM Sells;
DELETE FROM Restaurant_Staff;
DELETE FROM Customers;
DELETE FROM Riders;
DELETE FROM Part_Time;
DELETE FROM Full_Time;
DELETE FROM FDS_Managers;
DELETE FROM Monthly_Work_Schedules;
DELETE FROM Weekly_Work_Schedules;
DELETE FROM Intervals;
DELETE FROM Orders;
DELETE FROM Contains;
DELETE FROM Delivers;
DELETE FROM Promotions;
DELETE FROM MinSpendingPromotions;
DELETE FROM CustomerPromotions;


-- 100 user 40 customer 20 part time rider 25 full time rider 5 fds manager 10 restaurants
\copy Users(name) from './CSVFILES/Users.csv' CSV HEADER; --100 user

\copy Customers from './CSVFILES/Customers.csv' CSV HEADER; --40 user
\copy Riders from './CSVFILES/Riders.csv' CSV HEADER;  --45 user

INSERT INTO Part_Time(userId)  -- 20 
SELECT U.userId
FROM Users U
OFFSET 40
LIMIT 20;

INSERT INTO Full_Time(userId) -- 25
SELECT U.userId
FROM Users U
OFFSET 60
LIMIT 25;

INSERT INTO FDS_Managers(userId) -- 5
SELECT U.userId
FROM Users U
OFFSET 95
LIMIT 5;

\copy Restaurants from './CSVFILES/Restaurants.csv' CSV HEADER;  --10 res
\copy Restaurant_Staff from './CSVFILES/RestaurantStaff.csv' CSV HEADER;  --10 res
\copy Food from './CSVFILES/Food.csv' CSV HEADER;
\copy Sells(fname, rname, price, availability) from './CSVFILES/Sells.csv' CSV HEADER;

BEGIN;
--userId, startDate, endDate
\copy Weekly_Work_Schedules(userId, startDate, endDate) from './CSVFILES/weeklywork.csv' CSV HEADER;
\copy Intervals(scheduleId, startTime, endTime) from './CSVFILES/intervals.csv' CSV HEADER;
COMMIT;

BEGIN;
--userId, startDate, endDate
\copy Weekly_Work_Schedules(userId, startDate, endDate) from './CSVFILES/weeklyworkFT.csv' CSV HEADER;
\copy Intervals(scheduleId, startTime, endTime) from './CSVFILES/intervalsFT.csv' CSV HEADER;
\copy Monthly_Work_Schedules(scheduleId1, scheduleId2, scheduleId3, scheduleId4) from './CSVFILES/monthlyworkFT.csv' CSV HEADER;
COMMIT;

