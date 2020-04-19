-- Create database
DROP DATABASE IF EXISTS FinalExam;
CREATE DATABASE FinalExam;
USE FinalExam;

-- Create table
-- Table Student
CREATE TABLE Student(
	RN		INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `Name`	VARCHAR(100) NOT NULL,
    Age		TINYINT	UNSIGNED NOT NULL,
    Gender	ENUM('Male','Female') NOT NULL
);

-- Table Subject
CREATE TABLE `Subject`(
	sID		TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sName	CHAR(10) UNIQUE KEY
);

-- Table StudentSubject
CREATE TABLE StudentSubject(
	RN		INT UNSIGNED,
    sID		TINYINT UNSIGNED,
    Mark	TINYINT	UNSIGNED CHECK (Mark <= 10),
    `Date`	DATE,
    PRIMARY KEY (RN,sID),
    FOREIGN KEY (RN) REFERENCES Student(RN) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (sID) REFERENCES `Subject`(sID) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Questions 
-- a) 	Tạo table với các ràng buộc và kiểu dữ liệu  
-- 		Thêm ít nhất 3 bản ghi vào table
INSERT INTO Student	(`Name`				, 	Age	, 	Gender)
	VALUES			('Ngo Lan Ngoc'		, 	17	, 	'Female'),
					('Dinh Thi Hang Nga', 	17	, 	'Female'),
                    ('Tran Thai Binh'	, 	18	, 	'Male');
                    
INSERT INTO `Subject`	(sName)
	VALUES				('Toan'),
						('Van'),
                        ('Ly'),
                        ('Hoa'),
						('Anh');

INSERT INTO StudentSubject	(RN,	sID,	Mark,	`Date`)
	VALUES					(1,		3,		8,		'2020-04-10'),
							(2,		1,		8,		'2020-04-11'),
                            (3,		2,		NULL,	'2020-04-11'),
                            (1,		1,		8,		'2020-04-11'),
							(3,		5,		10,		'2020-04-09');
                            
-- b) Viết lệnh để 
--  	a. Lấy tất cả các môn học không có bất kì điểm nào
SELECT	s.sID, s.sName, ss.Mark
FROM	`Subject` s
JOIN	StudentSubject ss ON s.sID = ss.sID
WHERE	ss.Mark is Null
GROUP BY s.sName;
 
-- 		b. Lấy danh sách các môn học có ít nhất 2 điểm 
SELECT		ss.sID, s.sName, count(ss.Mark) so_luong_diem
FROM		StudentSubject ss
JOIN		`Subject`s ON ss.sID = s.sID
GROUP BY	ss.sID
HAVING 		so_luong_diem >= 2;

-- c) Tạo "StudentInfo" view có các thông tin về học sinh bao gồm: 
-- 		RN,sID,Name, Age, Gender, sName, Mark, Date. 
-- 		Với cột Gender show Male để thay thế cho 0, Female thay thế cho 1 và Unknow thay thế cho null.
DROP VIEW IF EXISTS StudentInfo;
CREATE OR REPLACE VIEW	StudentInfo AS
	SELECT	sd.RN, s.sID, sd.`Name`, sd.Age, sd.Gender, s.sName, ss.Mark, ss.`Date`
    FROM	StudentSubject ss
	JOIN	Student sd ON ss.RN = sd.RN
    JOIN	`Subject` s ON ss.sID = s.sID;  
    
SELECT * FROM StudentInfo;

-- d) Tạo trigger cho table Subject: 
-- 		a. Trigger CasUpdate: khi thay đổi data của cột sID, thì giá trị của cột sID của table StudentSubject cũng thay đổi theo
UPDATE `Subject`
SET sID = 6
WHERE sName = 'Anh';

DROP TRIGGER IF EXISTS CasUpdate;
DELIMITER $$
CREATE TRIGGER CasUpdate
BEFORE UPDATE ON `Subject` 
FOR EACH ROW
BEGIN
    UPDATE StudentSubject
	SET sID = NEW.sID
	WHERE sID = OLD.sID;
END$$    
DELIMITER ;

-- 		b. Trigger casDel: Khi xóa 1 student, các dữ liệu của table StudentSubject cũng sẽ bị xóa theo

-- e) Viết 1 thủ tục (có 2 parameters: student name, mark). 
-- 		Thủ tục sẽ xóa tất cả các thông tin liên quan tới học sinh có cùng tên như parameter và tất cả các điểm nhỏ hơn của các học sinh đó.  
-- 		Trong trường hợp nhập vào "*" thì thủ tục sẽ xóa tất cả các học sinh 
