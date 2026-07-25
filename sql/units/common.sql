-- ----------------- USER DEFINE FUCNTION
USE hr_database;

DROP FUNCTION FORMAT_NUMBER;
DELIMITER $$
CREATE FUNCTION FORMAT_NUMBER(varia FLOAT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE variable VARCHAR(50);

    SET variable = IF(varia >= 1000000000, CONCAT(ROUND(varia/1000000000,2)," B"),
                   IF(varia >= 1000000, CONCAT(ROUND(varia/1000000,2)," M" ),
                   IF(varia >= 1000, CONCAT(ROUND(varia/1000,2)," K" ), ROUND(varia,2))));
    
    RETURN variable;
END$$
DELIMITER;
-- --------------------------------------