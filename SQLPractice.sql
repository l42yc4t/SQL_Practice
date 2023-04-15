CREATE DATABASE `50p`;
SHOW DATABASES;
USE `50p`;
create table SC(SId varchar(10),CId varchar(10),score decimal(18,1));

create table Student(SId varchar(10),Sname varchar(10),Sage datetime,Ssex varchar(10));
insert into Student values('01' , '趙雷' , '1990-01-01' , '男');
insert into Student values('02' , '錢電' , '1990-12-21' , '男');
insert into Student values('03' , '孫風' , '1990-12-20' , '男');
insert into Student values('04' , '李雲' , '1990-12-06' , '男');
insert into Student values('05' , '周梅' , '1991-12-01' , '女');
insert into Student values('06' , '吳蘭' , '1992-01-01' , '女');
insert into Student values('07' , '鄭竹' , '1989-01-01' , '女');
insert into Student values('09' , '張三' , '2017-12-20' , '女');
insert into Student values('10' , '李四' , '2017-12-25' , '女');
insert into Student values('11' , '李四' , '2012-06-06' , '女');
insert into Student values('12' , '趙六' , '2013-06-13' , '女');
insert into Student values('13' , '孫七' , '2014-06-01' , '女');
insert into Student values('14' , '郭家暉' , '1996-12-11' , '男');
DESCRIBE Student;
SELECT *
FROM Student;

create table Course(CId varchar(10),Cname nvarchar(10),TId varchar(10));
insert into Course values('01' , '語文' , '02');
insert into Course values('02' , '數學' , '01');
insert into Course values('03' , '英語' , '03');
DESCRIBE Course;
SELECT *
FROM Course;

create table Teacher(TId varchar(10),Tname varchar(10));
insert into Teacher values('01' , '張三');
insert into Teacher values('02' , '李四');
insert into Teacher values('03' , '王五');
DESCRIBE Teacher;
SELECT *
FROM Teacher;

insert into SC values('01' , '01' , 80);
insert into SC values('01' , '02' , 90);
insert into SC values('01' , '03' , 99);
insert into SC values('02' , '01' , 70);
insert into SC values('02' , '02' , 60);
insert into SC values('02' , '03' , 80);
insert into SC values('03' , '01' , 80);
insert into SC values('03' , '02' , 80);
insert into SC values('03' , '03' , 80);
insert into SC values('04' , '01' , 50);
insert into SC values('04' , '02' , 30);
insert into SC values('04' , '03' , 20);
insert into SC values('05' , '01' , 76);
insert into SC values('05' , '02' , 87);
insert into SC values('06' , '01' , 31);
insert into SC values('06' , '03' , 34);
insert into SC values('07' , '02' , 89);
insert into SC values('07' , '03' , 98);
insert into SC values('14' , '03' , 100);
DESCRIBE SC;
SELECT *
FROM SC;
/*---------------註解-------------------*/
/*查詢" 01 "課程比" 02 "課程成績高的學生的資訊及課程分數*/
SELECT * 
FROM Student 
RIGHT JOIN (
	SELECT t1.SId, class1, class2 FROM
		(SELECT SId, score as class1 FROM SC WHERE SC.CId = '01') AS t1,
        (SELECT SId, score as class2 FROM SC WHERE SC.CId = '02') AS t2
	WHERE t1.SId = t2.SId AND t1.class1 > t2.class2
) AS r
ON Student.SId = r.SId;

SELECT *  /*不需要join*/
FROM Student 
, (
	SELECT t1.SId, class1, class2 FROM
		(SELECT SId, score as class1 FROM SC WHERE SC.CId = '01') AS t1,
        (SELECT SId, score as class2 FROM SC WHERE SC.CId = '02') AS t2
	WHERE t1.SId = t2.SId AND t1.class1 > t2.class2
) AS r
where Student.SId = r.SId;
/*先挑出所有滿足01課程>02課程分數的SC，再RIGHT JOIN*/
/*
SELECT * 
FROM Student 
RIGHT JOIN (
	SELECT * FROM
		(SELECT * FROM SC WHERE SC.CId = '01') AS t1,
        (SELECT * FROM SC WHERE SC.CId = '02') AS t2
	WHERE t1.SId = t2.SId AND t1.score > t2.score
) AS r
ON Student.SId = r.SId;
錯誤：Duplicate name `score`
*/

/*1.1 查詢同時存在" 01 "課程和" 02 "課程的情況*/
SELECT * FROM
	(SELECT * FROM SC WHERE SC.CId = '01') as t1,
    (SELECT * FROM SC WHERE SC.CId = '02') as t2
WHERE t1.SId = t2.SId;
/*挑選出全部有修01跟02課程的學生，再去做判斷有沒有同時存在於這兩樣的學生*/

/*1.2 查詢存在" 01 "課程但可能不存在" 02 "課程的情況(不存在時顯示為 null )*/
SELECT * FROM
	(SELECT * FROM SC WHERE SC.CId = '01') as t1
    LEFT JOIN
    (SELECT * FROM SC WHERE SC.CId = '02') as t2
    ON t1.SId = t2.SId;

/*1.3 查詢不存在" 01 "課程但存在" 02 "課程的情況*/
SELECT * FROM SC
WHERE SC.SId NOT IN (
	SELECT SId FROM SC WHERE SC.CId = '01'
)
AND SC.CId = '02';
/*先挑出沒有修01的，再來從中挑出有修02的*/

/*查詢平均成績大於等於 60 分的同學的學生編號和學生姓名和平均成績*/
SELECT Student.SId, sname, ss FROM Student, (
	SELECT SId, AVG(score) AS ss FROM SC
    GROUP BY SId
    HAVING AVG(SCORE) > 60
    ) AS r
WHERE Student.SId = r.SId;
/*先挑出所有平均大於60的再GROUP BY按照SId*/

/*查詢在 SC 表存在成績的學生資訊*/
SELECT DISTINCT Student.* 
FROM Student, SC
WHERE Student.SId = SC.SId;
/*注意：求學生的DISTINCT全部，不能使用DISTINCT *而要用DISTINCT Student.*   */

/*4.查詢所有同學的學生編號、學生姓名、選課總數、所有課程的成績總和*/
/*GROUP BY 敘述句搭配聚合函數 (aggregation function) 使用*/
SELECT Student.SId, Student.sname, r.coursenumber, r.scoresum
FROM Student, (SELECT SC.SId,SUM(SC.score) AS scoresum, COUNT(SC.CId) AS coursenumber FROM SC GROUP BY SC.SId) AS r
WHERE Student.sid = r.sid;

/*查詢「李」姓老師的數量*/
SELECT COUNT(*)
FROM Teacher
WHERE Tname like '李%';

/*查詢學過「張三」老師授課的同學的資訊*/
SELECT Student.*
FROM Student, SC, Teacher, Course
WHERE Student.SId = SC.SId AND SC.CId = Course.CId AND Course.TId = Teacher.Tid and Tname = '張三';

/*查詢沒有學全所有課程的同學的資訊*/
SELECT * 
FROM Student
WHERE Student.SId NOT IN (
	SELECT SC.SId FROM SC GROUP BY SC.SId HAVING COUNT(SC.CId) = (SELECT COUNT(CId) FROM Course)
);
/*反面思考，要求“沒有修全部課程的同學”，先求出那些修全部課程的同學*/



/*查詢至少有一門課與學號為" 01 "的同學所學相同的同學的資訊*/
SELECT *
FROM Student
WHERE Student.SId in (
	SELECT SC.SId FROM SC WHERE SC.CId in (
		SELECT SC.CId FROM SC WHERE SC.SId = '01'
    )
);
/*別想太難，單純就是找與01同學有上同一門課的同學們，並不是找跟01完全修同樣課的同學，下一題才是*/

/*查詢和" 01 "號的同學學習的課程完全相同的其他同學的資訊*/
SELECT *
FROM Student
WHERE SId in (
	SELECT SId FROM SC GROUP BY SId HAVING GROUP_CONCAT(CId ORDER BY CId) = (
		SELECT group_concat(CId ORDER BY CId) AS STR FROM SC WHERE SId = '01'
    )
    AND SId <> '01'
);
/*用到GROUP_CONCAT的概念*/

/*10.查詢沒學過"張三"老師講授的任一門課程的學生姓名*/
SELECT Student.SId
FROM Student, SC, Course, Teacher
WHERE Student.SId = SC.SId AND SC.CId = Course.CId AND Course.TId <> Teacher.TId;
/*以上Wrong solution*/
SELECT Student.SId
FROM Student
WHERE Student.SId NOT IN (
	SELECT SC.SId FROM SC WHERE SC.CId in (
		SELECT Course.CId FROM course WHERE Course.TId IN (
			SELECT Teacher.TId FROM Teacher WHERE Tname = '張三'
        )
    )
);
/*使用NOT IN就可以連那些這學期完全沒修課的學生都找出來*/

/*11.查詢兩門及其以上不及格課程的同學的學號，姓名及其平均成績*/
SELECT Student.SId, Student.Sname, AVG(SC.score)
FROM Student, SC
WHERE Student.SId = SC.SId AND SC.Score < 60
GROUP BY SC.SId 
HAVING COUNT(*) > 1;

SELECT Student.SId, SUM(SC.score)
FROM Student, SC
GROUP BY SC.SId;

select student.sid, student.sname, AVG(sc.score) from student,sc
where 
    student.sid = sc.sid and sc.score<60
group by sc.sid 
having count(*)>1;
/*怪怪的，跑不出結果.................................................................*/

/*檢索" 01 "課程分數小於 60，按分數降序排列的學生資訊*/
SELECT Student.*, SC.score 
FROM Student, SC
WHERE Student.SId = SC.SId AND SC.CId = '01' AND SC.score < 60
ORDER BY SC.score DESC; /*Default = "ASC"*/

/*按平均成績從高到低顯示所有學生的所有課程的成績以及平均成績*/
SELECT *
FROM SC LEFT JOIN ( SELECT SId, AVG(score) as avscore FROM SC GROUP BY SId) AS r
ON SC.SId = r.Sid
ORDER BY avscore DESC;

/*查詢各科成績最高分、最低分和平均分*/
SELECT 
SC.CId,
MAX(SC.score) AS maxscore,
MIN(SC.score) AS minscore,
AVG(SC.score) AS avgscore,
COUNT(*) AS num,
SUM(CASE WHEN SC.score >= 60 THEN 1 ELSE 0 END) / COUNT(*) as pass,
SUM(CASE WHEN SC.score >= 70 AND SC.score<80 THEN 1 ELSE 0 END) / COUNT(*) as midium,
SUM(CASE WHEN SC.score >= 80 AND SC.score<90 THEN 1 ELSE 0 END) / COUNT(*) as good,
SUM(CASE WHEN SC.score >= 90 THEN 1 ELSE 0 END) / COUNT(*) as verygood
FROM SC
GROUP BY SC.CId
ORDER BY COUNT(*) DESC, SC.CId ASC;

/*按各科成績進行排序，並顯示排名， Score 重複時保留名次空缺*/
SELECT a.CId, a.SId, a.score, COUNT(b.score)+1 AS rank_
FROM SC AS a LEFT JOIN SC AS b ON a.score < b.score AND a.CId = b.CId
GROUP BY a.SId, a.CId, a.score
ORDER BY a.cid,rank_ ASC;

/*查詢學生的總成績，並進行排名，總分重複時不保留名次空缺*/
SET @crank := 0;
SELECT q.sid, total, @crank := @crank + 1 as rank_ 
FROM (SELECT SC.SId, sum(SC.score) AS total FROM SC GROUP BY SC.SId ORDER BY total DESC) AS q;

/*查詢各科成績前三名的記錄*/
SELECT * 
FROM SC AS a
WHERE (SELECT COUNT(*) FROM SC AS b WHERE a.CId = b.CId AND a.score < b.score) < 3
ORDER BY a.CId ASC, a.score;
/*利用前面前面的那題解法*/
SELECT a.CId, a.SId, a.score, COUNT(b.score)+1 AS rank_
FROM SC AS a LEFT JOIN SC AS b ON a.score < b.score AND a.CId = b.CId
GROUP BY a.SId, a.CId, a.score
HAVING count(b.score) < 3
ORDER BY a.cid,rank_ ASC;

/*以下結果較好*/
SELECT a.SId, a.CId, a.score 
FROM SC AS a LEFT JOIN SC AS b ON a.CId = b.CId AND a.score < b.score
GROUP BY a.CId, a.SId
HAVING COUNT(b.CId) < 3
ORDER BY a.CId;

/*查詢每門課程被選修的學生數*/
SELECT CId, COUNT(SId) 
FROM SC
GROUP BY CId;

/*查詢出只選修兩門課程的學生學號和姓名*/
SELECT Student.SId, Student.Sname 
FROM Student
WHERE Student.SId IN (SELECT SC.SId FROM SC GROUP BY SC.SId HAVING COUNT(SC.CID) = 2);

/*查詢男生、女生人數*/
SELECT Ssex, COUNT(*) 
FROM Student
GROUP BY Ssex;

/*查詢名字中含有「風」字的學生資訊*/
SELECT *
FROM Student
WHERE Student.Sname LIKE '%風%';

/*查詢同名學生名單，並統計同名人數*/;
SELECT Sname, COUNT(*) 
FROM Student 
GROUP BY Sname
HAVING COUNT(*) > 1;

/*24.查詢 1990 年出生的學生名單*/
SELECT * 
FROM Student
WHERE YEAR(Student.Sage) = 1990;

/*25.查詢每門課程的平均成績，結果按平均成績降序排列，平均成績相同時，按課程編號升序排列*/
SELECT SC.CId, Course.Cname, AVG(SC.score) AS average 
FROM SC, Course
WHERE SC.CId = Course.CId 
GROUP BY SC.CId
ORDER BY average DESC, SC.CId ASC;

/*26.查詢平均成績大於等於 85 的所有學生的學號、姓名和平均成績*/
SELECT Student.SId, Student.Sname, AVG(SC.score) AS average 
FROM Student, SC
WHERE Student.SId = SC.SId
GROUP BY SC.SId
HAVING average > 85

/*查詢課程名稱為「數學」，且分數低於 60 的學生姓名和分數*/
SELECT Student.Sname, SC.score
FROM Student, SC, Course
WHERE Student.SId = SC.SId AND SC.CId = Course.CId AND Course.Cname = '數學' AND SC.score < 60;

/*查詢所有學生的課程及分數情況（存在學生沒成績，沒選課的情況）*/
SELECT Student.Sname, SC.CId, SC.score 
FROM Student LEFT JOIN SC ON Student.SId = SC.SId;

/*查詢任何一門課程成績在 70 分以上的姓名、課程名稱和分數*/
SELECT Student.Sname, Course.Cname, SC.score 
FROM Student, Course, SC 
WHERE Student.SId = SC.SId AND Course.CId = SC.CId AND SC.score > 70;

/*30.查詢存在不及格的課程*/
SELECT CId 
FROM SC
WHERE score < 60
GROUP BY CId;

/*31.查詢課程編號為 01 且課程成績在 80 分及以上的學生的學號和姓名*/
SELECT Student.SId, Student.Sname, SC.score
FROM Student, SC
WHERE Student.SId = SC.SId AND score >= 80 AND SC.CId = '01';

/*求每門課程的學生人數*/
SELECT CId, COUNT(*)
FROM SC
GROUP BY CId

/*查詢不同課程成績相同的學生的學生編號、課程編號、學生成績*/
SELECT a.CId, a.SId, a.score 
FROM SC as a INNER JOIN SC AS b ON a.SId = b.SId AND a.CId <> b.CId AND a.score = b.score
GROUP BY CId, SId;

/*36.查詢每門功成績最好的前兩名*/
SELECT a.SId, a.CId, a.score 
FROM SC AS a LEFT JOIN SC AS b ON a.CId = b.CId AND a.score < b.score
GROUP BY a.CId, a.SId
HAVING COUNT(b.CId) < 2
ORDER BY a.CId;

/*查詢選修了全部課程的學生資訊*/
SELECT Student.*
FROM Student, SC
WHERE Student.SId = SC.SId 
GROUP BY SC.SId
HAVING COUNT(*) = (SELECT DISTINCT COUNT(*) FROM Course);

/*按照出生日期來算，當前月日 < 出生年月的月日則，年齡減一*/
SELECT Student.SId AS num, Student.Sname AS nam, TIMESTAMPDIFF(YEAR, Student.Sage, CURDATE()) AS age
FROM Student;

/*42.查詢本週過生日的學生*/
SELECT * 
FROM Student
WHERE WEEKOFYEAR(student.Sage) = WEEKOFYEAR(CURDATE());

/*44.查詢本月過生日的學生*/
SELECT * 
FROM Student
WHERE MONTH(Student.Sage) = MONTH(CURDATE());






