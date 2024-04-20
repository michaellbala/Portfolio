CREATE DATABASE Brohollo

CREATE TABLE MsRanks (
RanksID CHAR(5) NOT NULL PRIMARY KEY CHECK(RanksID LIKE 'RK[0-9][0-9][0-9]'),
RankName VARCHAR(20) NOT NULL,
HighestRank VARCHAR(10) NOT NULL 
)

CREATE TABLE MsUsers (
UsersID CHAR(5) NOT NULL PRIMARY KEY CHECK(UsersID LIKE 'US[0-9][0-9][0-9]'),
RanksID CHAR(5) NOT NULL FOREIGN KEY REFERENCES MsRanks(RanksID),
UsersName VARCHAR(20) NOT NULL CHECK(LEN(UsersName) - LEN(REPLACE(UsersName, ' ', ' ')) LIKE 1),
UsersEmail VARCHAR(20) NOT NULL CHECK(UsersEmail LIKE '%@%.com'),
UsersAddress VARCHAR(50) NOT NULL CHECK(UsersAddress LIKE '% Street'),
UsersGender CHAR(1) NOT NULL CHECK(UsersGender BETWEEN 'Female' AND 'Male'),
UsersDOB DATE NOT NULL,
MammothCoin INT NOT NULL,
SkillRate INT NOT NULL CHECK(SkillRate >= 750) 
)

ALTER TABLE MsRanks
ADD CONSTRAINT CheckRank CHECK(HighestRank LIKE RankName + 750)

CREATE TABLE MsLegends (
LegendsID CHAR(5) NOT NULL PRIMARY KEY CHECK(LegendsID LIKE 'LG[0-9][0-9][0-9]'),
LegendsName VARCHAR(10) NOT NULL CHECK(LEN(LegendsName) > 5),
LegendsPrice INT NOT NULL,
LegendsStrength INT NOT NULL,
LegendsDexterity INT NOT NULL,
LegendsSpeed INT NOT NULL,
LegendsDefense INT NOT NULL,
)

ALTER TABLE MsLegends
ADD CONSTRAINT CheckStatus CHECK (LegendsStrength + LegendsDexterity + LegendsSpeed + LegendsDefense = 20)

CREATE TABLE TrTransaction (
TransactionID CHAR(5) NOT NULL PRIMARY KEY CHECK(TransactionID LIKE 'SP[0-9][0-9][0-9]'),
UsersID CHAR(5) FOREIGN KEY REFERENCES MsUsers(UsersID),
TransactionDate DATE NOT NULL 
)

CREATE TABLE LegendsDetailTransaction (
LegendsID CHAR(5) NOT NULL FOREIGN KEY REFERENCES MsLegends(LegendsID),
TransactionID CHAR(5) NOT NULL FOREIGN KEY REFERENCES TrTransaction(TransactionID)
)

CREATE TABLE MsMammothCoinPackage (
MammothCoinPackageID CHAR(5) NOT NULL PRIMARY KEY CHECK(MammothCoinPackageID LIKE 'MC[0-9][0-9][0-9]'),
MammothCoinBalance INT NOT NULL,
MammothCoinPrice INT NOT NULL )

CREATE TABLE TrRecharge (
RechargeID CHAR(5) NOT NULL PRIMARY KEY CHECK(RechargeID LIKE 'RC[0-9][0-9][0-9]'),
UsersID CHAR(5) FOREIGN KEY REFERENCES MsUsers(UsersID),
RechargeDate DATE NOT NULL 
)

CREATE TABLE RechargeDetailTransaction (
MammothCoinPackageID CHAR(5) NOT NULL FOREIGN KEY REFERENCES MsMammothCoinPackage(MammothCoinPackageID),
RechargeID CHAR(5) NOT NULL FOREIGN KEY REFERENCES TrRecharge(RechargeID),
MammothCoinQty INT NOT NULL
)

--1
SELECT l.LegendsID, l.LegendsName, [Purchased] = CAST(COUNT(TransactionID) AS INT) + ' stock(s)'
FROM TrTransaction t JOIN LegendsDetailTransaction ldt
ON t.TransactionID = ldt.TransactionID JOIN MsLegends l
ON ldt.LegendsID = l.LegendsID
ORDER BY [Purchased] DESC

--2 
SELECT UsersName, [UsersGender] = UPPER(LEFT(UsersGender,1)), SkillRate, [User Legend Count] = COUNT(l.LegendsID)
FROM MsUsers u JOIN TrTransaction t 
ON u.UsersID = t.UsersID JOIN LegendsDetailTransaction ldt 
ON t.TransactionID = ldt.TransactionID JOIN MsLegends l
ON ldt.LegendsID = l.LegendsID
WHERE COUNT(l.LegendsID) > 2

--3 
SELECT [First Name] = (SELECT SUBSTRING(UsersName,1, CHARINDEX(' ', UsersName)),
		[Total Package Purchased] = COUNT (mcp.MammothCoinPackageID),
		[Total Money Spent] = SUM (MammothCoinPrice)
FROM MsUsers u JOIN TrRecharge r 
ON u.UsersID = r.UsersID JOIN RechargeDetailTransaction rdt 
ON r.RechargeID = rdt.RechargeID JOIN MsMammothCoinPackage mcp 
ON rdt.MammothCoinPackageID = mcp.MammothCoinPackageID
WHERE SkillRate >= 1500 AND SUM(MammothCoinPrice) > 1000000

--4
SELECT l.LegendsID, 
		[LegendsQuantity] =  COUNT(l.LegendsID) + COUNT(UsersID) + ' stock(s)',
		[Total Coin] = SUM(LegendsPrice) + ' coin(s)'
FROM TrTransaction t JOIN LegendsDetailTransaction ldt
ON t.TransactionID = ldt.TransactionID JOIN MsLegends l
ON ldt.LegendsID = l.LegendsID
WHERE COUNT(l.LegendsID) <= 5
GROUP BY l.LegendsID
ORDER BY [LegendsQuantity] ASC

--5 
SELECT UsersID, 
		[LastName] = (SELECT SUBSTRING(UsersName,CHARINDEX(' ', UsersName),LEN(UsersName))
						FROM MsUsers),
		[User Next Rank] = (SELECT UsersName
							FROM MsUsers u JOIN MsRanks r
							ON u.RanksID = r.RanksID
							WHERE HighestRank = MAX(HighestRank)) 
FROM MsUsers u JOIN MsRanks r
ON u.RanksID = r.RanksID
WHERE SkillRate > HighestRank

--6 
SELECT l.LegendsID, LegendsName,
		[Discounted Price] = (LegendsPrice - (LegendsPrice * 0.2))
FROM TrTransaction t JOIN LegendsDetailTransaction ldt
ON t.TransactionID = ldt.TransactionID JOIN MsLegends l
ON ldt.LegendsID = l.LegendsID
WHERE COUNT(L.LegendsID) <= 10

--7 
SELECT u.UsersID,
		 [UsersName] = (SELECT LEFT(UsersName, 1) AS FirstNames
							FROM MsUsers
							WHERE FirstNames LIKE 'A'),
		[Total Transaction] = (SELECT COUNT(u.UsersID)  + ' recharge(s)')
FROM MsUsers u JOIN TrRecharge r
ON u.UsersID = r.UsersID
WHERE SkillRate > AVG(SkillRate) AND UsersDOB = RechargeDate

--8
SELECT [Legend Number] = (SELECT RIGHT(LegendsID, 3)
							FROM MsLegends),
		LegendsName,
		[Users Count] = (COUNT(u.UsersID) + ' user(s)')
FROM MsLegends l JOIN LegendsDetailTransaction ldt 
ON l.LegendsID = ldt.LegendsID JOIN TrTransaction t 
ON ldt.TransactionID = t.TransactionID JOIN MsUsers u
ON t.UsersID = u.UsersID	
WHERE COUNT(l.LegendsID) < 5

--9
GO
CREATE VIEW MammothCoinReport AS
SELECT MammothCoinBalance,
		[Max Quantity Sold] = (MAX(MammothCoinQty)),
		[Min Quantity Sold] = (MIN(MammothCoinQty))
FROM MsMammothCoinPackage mcp JOIN RechargeDetailTransaction rdt
ON mcp.MammothCoinPackageID = rdt.MammothCoinPackageID JOIN TrRecharge r
ON rdt.RechargeID = r.RechargeID
WHERE RechargeDate >= CAST(DATEPART(yyyy,DATEADD(yyyy,-1,GETDATE())) as int)

--10
GO
CREATE VIEW LegendReport AS
SELECT LegendsName, 
		[Total Mammoth Coin Income] = (SELECT LegendsName,
											LegendsPrice
										FROM TrTransaction t JOIN LegendsDetailTransaction ldt
										ON t.TransactionID = ldt.TransactionID
										WHERE LegendsPrice = SUM(LegendsPrice)),
		[Total Legend Purchased] = (COUNT(l.LegendsID))
FROM MsLegends l JOIN LegendsDetailTransaction ldt
ON l.LegendsID = ldt.LegendsID JOIN TrTransaction t
ON ldt.TransactionID = t.TransactionID
WHERE TransactionDate >= CAST(DATEPART(mm,DATEADD(mm,-1,GETDATE())) AS INT)

GO

---INSERT INTO MASTER TABLE (10 DATA)
INSERT INTO Users VALUES (
'US001','Michael B. Koban','Mich213@gmail.com','Margonda Street','Male','08/12/2000',0,800
'US002','Trevor Jo','JoTrev9@gmail.com','Bungur Street','Male','07/15/1999',0,1000
'US003','Ravee Alfre','RAlfre@gmail.com','Slipi Street','Male','11/05/2000',0,950
'US004','Cindy Trump','Cindytr@yahoo.com','Kemanggisan Street','Female','06/25/2001',0,850
'US005','Daisy Kenneth','Daisykenn1@gmail.com','California Street','Female','05/18/1998',0,1050
'US006','Rebecca Yo Trun','RebeccaYot89@yahoo.com','San Fransisco Street','Male','12/29/1997',0,1250
'US007','Farra Lemkova','FarraLemkov@gmail.com','Beverly Street','Female','03/11/1996',0,770
'US008','Fayz Zaheer','FayzZah@gmail.com','Jatibening Street','Male','09/03/1998',0,900
'US009','Elvio Renaldi','Elviorenald@gmail.com','sisingamangaraja Street','Male','14/12/2000',0,870
'US100','jonathan alex','jonathanlex@gmail.com','higheels Street','Male','22/05/1999',0,1100
)

-- BELOM HIGHEST RANK
INSERT INTO Ranks VALUES (
'RK001','Silver'
'RK002','Platinum'
'RK003','Silver'
'RK004','Gold'
'RK005','Silver'
'RK006','Platinum'
'RK007','Silver'
'RK008','Gold'
'RK009','Silver'
'RK100','Platinum'
)

-- BELOM STATS, NAME
INSERT INTO Legends VALUES (
'LG001','',10000,[Stats],5,4,7,4
'LG002','',15000,[Stats],4,5,7,4
'LG003','',20000,[Stats],5,4,4,7
'LG004','',25000,[Stats],3,4,9,4
'LG005','',30000,[Stats],8,4,7,1
'LG006','',35000,[Stats],7,5,7,1
'LG007','',40000,[Stats],5,9,4,2
'LG008','',45000,[Stats],1,4,7,8
'LG009','',50000,[Stats],3,5,7,5
'LG100','',55000,[Stats],3,7,4,6
)


---INSERT INTO TRANSACTION TABLE (15 DATA)
-- BELOM BALANCE
INSERT INTO MammothCoinPackage VALUES (
'MC001',[Balance],80000
'MC002',[Balance],90000
'MC003',[Balance],70000
'MC004',[Balance],60000
'MC005',[Balance],50000
'MC006',[Balance],40000
'MC007',[Balance],50000
'MC008',[Balance],20000
'MC009',[Balance],80000
'MC100',[Balance],50000
'MC101',[Balance],20000
'MC102',[Balance],60000
'MC103',[Balance],70000
'MC104',[Balance],90000
'MC105',[Balance],80000
)

INSERT INTO Recharge ()VALUES (
'RC001','US001','Michael B. Koban','MC001',1,'22/05/2000','22/05/2001'
'RC002','US002','Trevor Jo','MC002',2,'22/05/2000','22/05/2001'
'RC003','US003','Ravee Alfre','MC003',4,'22/05/2000','22/05/2001'
'RC004','US004','Cindy Trump','MC004',1,'22/05/2000','22/05/2001'
'RC005','US005','Daisy Kenneth','MC005',9,'22/05/2000','22/05/2001'
'RC006','US006','Rebecca Yo Trun','MC006',8,'22/05/2000','22/05/2001'
'RC007','US007','Farra Lemkova','MC007',3,'22/05/2000','22/05/2001'
'RC008','US008','Fayz Zaheer','MC008',5,'22/05/2000','22/05/2001'
'RC009','US009','Elvio Renaldi','MC009',7,'22/05/2000','22/05/2001'
'RC100','US100','jonathan alex','MC100',2,'22/05/2000','22/05/2001'
'RC101','US004','Cindy Trump','MC101',5,'22/05/2000','22/05/2001'
'RC102','US002','Trevor Jo','MC102',2,'22/05/2000','22/05/2001'
'RC103','US007','Farra Lemkova','MC103',3,'22/05/2000','22/05/2001'
'RC104','US001','Michael B. Koban','MC104',5,'22/05/2000','22/05/2001'
'RC105','US003','Ravee Alfre','MC105',8,'22/05/2000','22/05/2001'
)


---INSERT INTO TRANSACTION DETAIL TABLE (25 DATA)
INSERT INTO TrTransaction VALUES (
'SP001','US001','LG001','RC001','22/05/2000'
'SP002','US002','LG002','RC002','22/05/2000'
'SP003','US003','LG003','RC003','22/05/2000'
'SP004','US004','LG004','RC004','22/05/2000'
'SP005','US005','LG005','RC005','22/05/2000'
'SP006','US006','LG006','RC006','22/05/2000'
'SP007','US007','LG007','RC007','22/05/2000'
'SP008','US008','LG008','RC008','22/05/2000'
'SP009','US009','LG009','RC009','22/05/2000'
'SP010','US100','LG100','RC100','22/05/2000'
'SP011','US004','LG007','RC101','22/05/2000'
'SP012','US002','LG001','RC102','22/05/2000'
'SP013','US007','LG001','RC103','22/05/2000'
'SP014','US001','LG001','RC104','22/05/2000'
'SP015','US003','LG001','RC105','22/05/2000'
'SP016','US005','LG001','RC006','22/05/2000'
'SP017','US004','LG001','RC009','22/05/2000'
'SP018','US009','LG001','RC002','22/05/2000'
'SP019','US007','LG001','RC003','22/05/2000'
'SP020','US200','LG001','RC001','22/05/2000'
'SP021','US001','LG001','RC008','22/05/2000'
'SP022','US001','LG001','RC007','22/05/2000'
'SP023','US001','LG001','RC004','22/05/2000'
'SP024','US001','LG001','RC005','22/05/2000'
'SP025','US001','LG001','RC100','22/05/2000'
)


