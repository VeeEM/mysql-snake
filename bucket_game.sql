-- Tables

CREATE TABLE `bucket` (
  `id` int NOT NULL AUTO_INCREMENT,
  `x` int NOT NULL,
  `y` int NOT NULL,
  `icon` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `direction` (
  `id` int NOT NULL AUTO_INCREMENT,
  `direction` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `game_over` (
  `id` int NOT NULL AUTO_INCREMENT,
  `game_over` tinyint NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `queue` (
  `id` int NOT NULL AUTO_INCREMENT,
  `x` int NOT NULL,
  `y` int NOT NULL,
  `icon` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `queue_icons` (
  `id` int NOT NULL AUTO_INCREMENT,
  `icon` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `update_time` (
  `id` int NOT NULL AUTO_INCREMENT,
  `last_update` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Procedures and functions
DELIMITER ;;

CREATE FUNCTION `bucketOnHead`() RETURNS tinyint
    READS SQL DATA
BEGIN
	DECLARE head_x, head_y, bucket_x, bucket_y INT;
	SELECT x, y FROM queue LIMIT 1 INTO head_x, head_y;
	SELECT x, y FROM bucket INTO bucket_x, bucket_y;
	IF head_x = bucket_x AND head_y = bucket_y THEN
		RETURN 1;
	ELSE
		RETURN 0;
	END IF;
END ;;

CREATE PROCEDURE `checkGameOver`()
BEGIN
	DECLARE head_x, head_y INT;
	SELECT x, y FROM queue LIMIT 1 INTO head_x, head_y;
	IF (SELECT (SELECT id FROM queue WHERE id != 1 AND x = head_x AND y = head_y) IS NOT NULL) THEN
		UPDATE game_over SET game_over = 1;
	END IF;
END ;;

CREATE PROCEDURE `extendQueue`()
BEGIN
	DECLARE second_x, second_y INT;
	SELECT x, y FROM queue WHERE id = 2 INTO second_x, second_y;

	UPDATE queue q1
	LEFT JOIN queue q2 ON q2.id = q1.id + 1
	SET q1.icon = IF(q2.icon IS NULL, getRandomIcon(), q2.icon);

	INSERT INTO queue (x, y, icon) VALUES (second_x, second_y, getRandomIcon());
END ;;

CREATE PROCEDURE `gameLoop`()
BEGIN
	CALL updateGame();
	DO SLEEP(0.25);
	CALL updateGame();
	DO SLEEP(0.25);
	CALL updateGame();
	DO SLEEP(0.25);
	CALL updateGame();
END ;;

CREATE FUNCTION `gameStr`() RETURNS text CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci
    READS SQL DATA
BEGIN
	DECLARE height INT DEFAULT 10;
	DECLARE width INT DEFAULT 10;
	DECLARE loop_x INT DEFAULT 0;
	DECLARE loop_y INT DEFAULT 0;
	DECLARE game_str TEXT DEFAULT "";
	DECLARE bucket_x INT;
	DECLARE bucket_y INT;
	DECLARE bucket_icon VARCHAR(4);
	DECLARE current_icon VARCHAR(4) DEFAULT "🟩";
	DECLARE queue_icon VARCHAR(4) DEFAULT NULL;
	SELECT x, y, icon FROM bucket INTO bucket_x, bucket_y, bucket_icon;
	WHILE loop_y < height DO
		WHILE loop_x < width DO
			IF (bucket_x = loop_x AND bucket_y = loop_y) THEN SET current_icon = bucket_icon;
			END IF;
			SET queue_icon = (SELECT icon FROM queue WHERE x = loop_x AND y = loop_y LIMIT 1);
			IF (queue_icon IS NOT NULL) THEN SET current_icon = queue_icon;
			END IF;
			SET game_str = CONCAT(game_str, current_icon);
			SET queue_icon = NULL;
			SET current_icon = "🟩";
			SET loop_x = loop_x + 1;
		END WHILE;
		SET game_str = CONCAT(game_str, "\n");
		SET loop_x = 0;
		SET loop_y = loop_y + 1;
	END WHILE;
	RETURN game_str;
END ;;

CREATE FUNCTION `getRandomIcon`() RETURNS varchar(4) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci
    READS SQL DATA
BEGIN
	RETURN (SELECT icon FROM queue_icons ORDER BY RAND() LIMIT 1);
END ;;

CREATE PROCEDURE `initGame`()
BEGIN
	TRUNCATE TABLE bucket;
	INSERT INTO bucket (x, y, icon) VALUES (1,1,"🪣");

	TRUNCATE TABLE queue_icons;
	INSERT INTO queue_icons (icon) VALUES ("🕵️");
	INSERT INTO queue_icons (icon) VALUES ("🧑‍⚕️");
	INSERT INTO queue_icons (icon) VALUES ("🧑‍🎓");
	INSERT INTO queue_icons (icon) VALUES ("🧑‍🏫");
	INSERT INTO queue_icons (icon) VALUES ("🧑‍⚖️");
	INSERT INTO queue_icons (icon) VALUES ("🧑‍🌾");
	INSERT INTO queue_icons (icon) VALUES ("🧑‍🍳");
	INSERT INTO queue_icons (icon) VALUES ("🧑‍🔧");
	INSERT INTO queue_icons (icon) VALUES ("🧑‍🏭");
	INSERT INTO queue_icons (icon) VALUES ("🧑‍💼");
	INSERT INTO queue_icons (icon) VALUES ("🧑‍🔬");
	INSERT INTO queue_icons (icon) VALUES ("🧑‍💻");
	INSERT INTO queue_icons (icon) VALUES ("🧑‍🎤");
	INSERT INTO queue_icons (icon) VALUES ("🧑‍🎨");
	INSERT INTO queue_icons (icon) VALUES ("🧑‍✈️");
	INSERT INTO queue_icons (icon) VALUES ("🧑‍🚀");
	INSERT INTO queue_icons (icon) VALUES ("🧑‍🚒");
	INSERT INTO queue_icons (icon) VALUES ("👮");
	INSERT INTO queue_icons (icon) VALUES ("💂");
	INSERT INTO queue_icons (icon) VALUES ("👷");
	INSERT INTO queue_icons (icon) VALUES ("👳");
	INSERT INTO queue_icons (icon) VALUES ("👲");
	INSERT INTO queue_icons (icon) VALUES ("🧕");
	INSERT INTO queue_icons (icon) VALUES ("🤵");
	INSERT INTO queue_icons (icon) VALUES ("👰");
	INSERT INTO queue_icons (icon) VALUES ("🎅");

	TRUNCATE TABLE queue;
	INSERT INTO queue (x, y, icon) VALUES (5,5,getRandomIcon());
	INSERT INTO queue (x, y, icon) VALUES (5,6,getRandomIcon());
	INSERT INTO queue (x, y, icon) VALUES (5,7,getRandomIcon());
	INSERT INTO queue (x, y, icon) VALUES (5,8,getRandomIcon());
	
	TRUNCATE TABLE direction;
	INSERT INTO direction (direction) VALUES ("UP");
	
	TRUNCATE TABLE game_over;
	INSERT INTO game_over (game_over) VALUES (0);

	TRUNCATE TABLE update_time;
	INSERT INTO update_time (last_update) VALUES (SYSDATE(6));
END ;;

CREATE FUNCTION `isGameOver`() RETURNS tinyint
    READS SQL DATA
BEGIN
	DECLARE retVal TINYINT;
	SELECT game_over.game_over FROM game_over INTO retVal;
	RETURN retVal;
END ;;

CREATE PROCEDURE `moveBucket`()
BEGIN
	DECLARE new_x INT;
	DECLARE new_y INT;
	SET new_x = FLOOR(RAND() * 10);
	SET new_y = FLOOR(RAND() * 10);
	WHILE (SELECT id FROM queue WHERE x = new_x AND y = new_y) IS NOT NULL DO
		SET new_x = FLOOR(RAND() * 10);
		SET new_y = FLOOR(RAND() * 10);
	END WHILE;
	UPDATE bucket SET x = new_x, y = new_y;
END ;;

CREATE PROCEDURE `moveQueue`()
BEGIN
	DECLARE current_direction VARCHAR(5);
	DECLARE new_x INT;
	DECLARE new_y INT;
	
	UPDATE queue q1
	LEFT JOIN queue q2 ON q2.id = q1.id - 1
	SET q1.x = q2.x, q1.y = q2.y
	WHERE q2.id IS NOT NULL;

	SELECT x, y FROM queue LIMIT 1 INTO new_x, new_y;
	SET current_direction = (SELECT direction.direction FROM direction);
	IF current_direction = "UP" THEN
		SET new_y = new_y - 1;
	ELSEIF current_direction = "DOWN" THEN
		SET new_y = new_y + 1;
	ELSEIF current_direction = "LEFT" THEN
		SET new_x = new_x - 1;
	ELSEIF current_direction = "RIGHT" THEN
		SET new_x = new_x + 1;
	END IF;
	
	SET new_y = MOD(new_y + 10, 10);
	SET new_x = MOD(new_x + 10, 10);
	
	UPDATE queue SET x = new_x, y = new_y LIMIT 1;
END ;;

CREATE PROCEDURE `renderGame`()
BEGIN
	DECLARE game_str TEXT DEFAULT "";
	DECLARE gameOver TINYINT;
	SELECT gameStr() INTO game_str;
	SELECT isGameOver() INTO gameOver;
	IF gameOver = 1 THEN
		SELECT CONCAT(game_str, "GAME OVER!");
	ELSE
		SELECT game_str;
	END IF;
END ;;

CREATE FUNCTION `sinceLastUpdate`() RETURNS double
    READS SQL DATA
BEGIN
	DECLARE lastUpdate DATETIME(6);
	SELECT last_update FROM update_time LIMIT 1 INTO lastUpdate;
	RETURN SYSDATE(6) - lastUpdate;
END ;;

CREATE PROCEDURE `updateGame`()
BEGIN
	DECLARE gameOver TINYINT;
	DECLARE sinceLast DOUBLE;
	SET sinceLast = sinceLastUpdate();
	SET gameOver = isGameOver();
	IF gameOver = 0 AND sinceLast >= 0.33 THEN
		CALL moveQueue();
		IF bucketOnHead() = 1 THEN
			CALL moveBucket();
			CALL extendQueue(); 
		END IF;
		CALL checkGameOver();
		UPDATE update_time SET last_update = SYSDATE(6); 
	END IF;
END ;;

DELIMITER ;

-- Events

CREATE EVENT gameLoopEvent
ON SCHEDULE EVERY 1 SECOND
STARTS '1995-5-7 15:47:00.000'
ON COMPLETION NOT PRESERVE
DISABLE
DO CALL gameLoop();
