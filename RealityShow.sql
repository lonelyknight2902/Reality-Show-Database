DROP DATABASE IF EXISTS REALITYSHOW;
CREATE DATABASE REALITYSHOW;

--@block
USE REALITYSHOW;
--@block

DROP TABLE IF EXISTS Company;
CREATE TABLE Company
(
    cnumber     CHAR(4) PRIMARY KEY,
    name        VARCHAR(50) NOT NULL,
    phone       CHAR(11) UNIQUE NOT NULL,
    edate       DATE
);

DROP TABLE IF EXISTS Person;
CREATE TABLE Person
(
    ssn         CHAR(12) PRIMARY KEY,
    fname       VARCHAR(10) NOT NULL,
    lname       VARCHAR(10) NOT NULL,
    address     VARCHAR(100),
    phone       CHAR(10) UNIQUE NOT NULL
);

DROP TABLE IF EXISTS Trainee
CREATE TABLE Trainee
(
    ssn         CHAR(12) PRIMARY KEY,
    dob         DATE,
    photo       VARCHAR(200),
    company_id  CHAR(4),
    CONSTRAINT  fk_trainee_ssn FOREIGN KEY(ssn)
                REFERENCES Person(ssn),
    CONSTRAINT  fk_company_id FOREIGN KEY(company_id)
                REFERENCES Company(cnumber)
);

CREATE TABLE MC
(
    ssn         CHAR(12) PRIMARY KEY,
    CONSTRAINT  fk_mc_ssn FOREIGN KEY(ssn)
                REFERENCES Person(ssn)
);

CREATE TABLE Mentor
(
    ssn         CHAR(12) PRIMARY KEY,
    CONSTRAINT  fk_mentor_ssn FOREIGN KEY(ssn)
                REFERENCES Person(ssn)
);

CREATE TABLE Singer
(
    ssn         CHAR(12) PRIMARY KEY,
    guest_id    INT
);

DROP TABLE IF EXISTS Song
CREATE TABLE Song
(
    number          VARCHAR(5) PRIMARY KEY,
    released_year   YEAR,
    name            VARCHAR(50),
    singer_ssn_first_performed  CHAR(12),
    CONSTRAINT      fk_song_singer_ssn  FOREIGN KEY (singer_ssn_first_performed)
                    REFERENCES Singer(ssn)
);

CREATE TABLE ThemeSong
(
    song_id         VARCHAR(5) PRIMARY KEY,
    CONSTRAINT      fk_theme_song_id FOREIGN KEY (song_id)
                    REFERENCES Song(number)
);

CREATE TABLE SongWriter
(
    ssn         CHAR(12) PRIMARY KEY,
    CONSTRAINT  fk_songwriter_ssn FOREIGN KEY(ssn)
                REFERENCES Mentor(ssn)
);

CREATE TABLE SongComposedBy
(
    song_id         VARCHAR(5),
    composer_ssn    CHAR(12),
    CONSTRAINT      fk_composed_song_id FOREIGN KEY (song_id)
                    REFERENCES Song(number),
    CONSTRAINT      fk_song_composer_ssn FOREIGN KEY (composer_ssn)
                    REFERENCES SongWriter(ssn),
    PRIMARY KEY (song_id, composer_ssn)
);


CREATE TABLE SingerSignatureSong
(
    ssn         CHAR(12),
    song_name   VARCHAR(20),
    CONSTRAINT  fk_singer_song_ssn FOREIGN KEY(ssn)
                REFERENCES Singer(ssn),
    PRIMARY KEY (ssn, song_name)
);

CREATE TABLE Producer
(
    ssn         CHAR(12) PRIMARY KEY,
    CONSTRAINT  fk_producer_ssn FOREIGN KEY(ssn)
                REFERENCES Mentor(ssn)
);

CREATE TABLE ProducerProgram
(
    ssn             CHAR(12),
    program_name    VARCHAR(20),
    CONSTRAINT      fk_producer_program_ssn FOREIGN KEY (ssn)
                    REFERENCES Producer(ssn),
    PRIMARY KEY (ssn, program_name)
);



CREATE TABLE Season
(
    year            YEAR PRIMARY KEY,
    location        VARCHAR(50),
    themesong_id    VARCHAR(5),
    mc_ssn             CHAR(12),
    CONSTRAINT      fk_season_mc_ssn FOREIGN KEY (mc_ssn)
                    REFERENCES MC(ssn),
    CONSTRAINT      fk_season_theme_song_id FOREIGN KEY (themesong_id)
                    REFERENCES ThemeSong(song_id)
);

CREATE TABLE SeasonMentor
(
    year        YEAR,
    ssn_mentor  CHAR(12),
    CONSTRAINT  fk_season_mentor_year FOREIGN KEY (year)
                REFERENCES Season(year),
    CONSTRAINT  fk_season_mentor_ssn FOREIGN KEY (ssn_mentor)
                REFERENCES Mentor(ssn),
    PRIMARY KEY (year, ssn_mentor)
);

CREATE TABLE SeasonTrainee
(
    year        YEAR,
    ssn_trainee  CHAR(12),
    CONSTRAINT  fk_season_trainee_year FOREIGN KEY (year)
                REFERENCES Season(year),
    CONSTRAINT  fk_season_trainee_ssn FOREIGN KEY (ssn_trainee)
                REFERENCES Trainee(ssn),
    PRIMARY KEY (year, ssn_trainee)
);

CREATE TABLE MentorValuateTrainee
(
    year        YEAR,
    ssn_trainee CHAR(12),
    ssn_mentor  CHAR(12),
    score       INT,
    CONSTRAINT  fk_valuate_year FOREIGN KEY(year)
                REFERENCES Season(year),
    CONSTRAINT  fk_valuate_trainee_ssn FOREIGN KEY(ssn_trainee)
                REFERENCES Trainee(ssn),
    CONSTRAINT  fk_valuate_mentor_ssn FOREIGN KEY (ssn_mentor)
                REFERENCES Mentor(ssn),
    CONSTRAINT  score_constraint CHECK ( score >= 0 AND score <= 100 ),
    PRIMARY KEY (year, ssn_trainee, ssn_mentor)
);

CREATE TABLE Episode
(
    year        YEAR,
    no          INT,
    name        VARCHAR(20),
    datetime    DATETIME,
    duration    INT,
    CONSTRAINT  fk_episode_year FOREIGN KEY (year)
                REFERENCES Season(year),
    CONSTRAINT  episode_constraint CHECK ( no >= 1 AND no <= 5 ),
    PRIMARY KEY (year, no)
);

CREATE TABLE Stage
(
    year        YEAR,
    ep_no       INT,
    stage_no    INT,
    is_group    BOOLEAN NOT NULL,
    skill       INT DEFAULT 4,
    total_vote  INT,
    song_id     VARCHAR(5),
    CONSTRAINT  fk_stage_year_ep_no FOREIGN KEY (year, ep_no)
                REFERENCES Episode(year, no),
    CONSTRAINT  fk_stage_song_id FOREIGN KEY (song_id)
                REFERENCES Song(number),
    CONSTRAINT  skill_constraint CHECK ( skill >= 1 AND skill <= 4 ),
    PRIMARY KEY (year, ep_no, stage_no)
);

CREATE TABLE StageIncludeTrainee
(
    year        YEAR,
    ep_no       INT,
    stage_no    INT,
    ssn_trainee CHAR(12),
    role        INT DEFAULT 1,
    no_of_votes INT,
    CONSTRAINT  fk_stage_trainee_year FOREIGN KEY (year, ep_no, stage_no)
                REFERENCES Stage(year, ep_no, stage_no),
    CONSTRAINT  fk_stage_trainee_ssn FOREIGN KEY (ssn_trainee)
                REFERENCES Trainee(ssn),
    CONSTRAINT  role_constraint CHECK ( role >= 1 AND role <= 3 ),
    CONSTRAINT  votes_constraint CHECK ( no_of_votes >= 0 AND no_of_votes <= 500 ),
    PRIMARY KEY (year, ep_no, stage_no, ssn_trainee)
);

CREATE TABLE InvitedGuest
(
    guest_id    INT PRIMARY KEY AUTO_INCREMENT
);

CREATE TABLE GuestGroup
(
    gname           VARCHAR(20) PRIMARY KEY,
    no_of_member    INT,
    guest_id        INT,
    CONSTRAINT      fk_group_guest_id FOREIGN KEY (guest_id)
                    REFERENCES InvitedGuest(guest_id),
    CONSTRAINT      member_constraint CHECK ( no_of_member >= 1 AND no_of_member <= 20 )
);

CREATE TABLE GroupSignatureSong
(
    gname       VARCHAR(20),
    song_name   VARCHAR(20),
    CONSTRAINT  fk_group_song_gname FOREIGN KEY (gname)
                REFERENCES GuestGroup(gname),
    PRIMARY KEY (gname, song_name)
);

CREATE TABLE GuestSupportStage
(
    guest_id    INT,
    year        YEAR,
    ep_no       INT,
    stage_no    INT,
    CONSTRAINT  fk_support_guest_id FOREIGN KEY (guest_id)
                REFERENCES InvitedGuest(guest_id),
    CONSTRAINT  fk_support_year FOREIGN KEY (year, ep_no, stage_no)
                REFERENCES Stage(year, ep_no, stage_no),
    PRIMARY KEY (year, ep_no, stage_no)
);

CREATE TABLE Song_seq
(
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY
);

DELIMITER //
CREATE TRIGGER Song_insert
BEFORE INSERT ON Song
FOR EACH ROW
BEGIN
  INSERT INTO Song_seq VALUES (NULL);
  SET NEW.number = CONCAT('S', LAST_INSERT_ID());
END//
DELIMITER ;

-- @block
SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM Company
INSERT INTO Company VALUES ('C001', 'VNG', '02839623888', STR_TO_DATE ('09,09,2004','%d,%m,%Y')),
                           ('C002', 'Google LLC', '18004190157', STR_TO_DATE ('04,09,1998','%d,%m,%Y')),
                           ('C003', 'Meta', '17815754340', STR_TO_DATE ('04,02,2004','%d,%m,%Y')),
                           ('C004', 'Microsoft', '18004004700', STR_TO_DATE ('04,04,1975','%d,%m,%Y')),
                           ('C005', 'Pawtucket Patriot Brewery', '18003234334', STR_TO_DATE ('25,09,2005','%d,%m,%Y')),
                           ('C006', 'American Airlines', '18004337300', STR_TO_DATE ('15,04,1926','%d,%m,%Y')),
                           ('C007', 'Springfield Nuclear Power Plant', '18004324231', STR_TO_DATE ('29,01,1968','%d,%m,%Y')),
                           ('CC08', 'Quahog Police Department', '18001324323', STR_TO_DATE ('05,01,1756','%d,%m,%Y'));
DELETE FROM Person
INSERT INTO Person VALUES ('568470008000', 'Homer', 'Simpson', '742 Evergreen Terrace, Springfield', '9395550113'),
                          ('324461828345', 'Peter', 'Griffin', '31 Spooner Street, Quahog, RI', '9019225231'),
                          ('324294724455', 'Lois', 'Griffin', '31 Spooner Street, Quahog, RI', '6012981814'),
                          ('124543143556', 'Glenn', 'Quagmire', '29 Spooner Street, Quahog, RI', '7163372038'),
                          ('342762497115', 'Joe', 'Swanson', '33 Spooner Street, Quahog, RI', '9185859491'),
                          ('342923879219', 'Cleveland', 'Brown', '30 Spooner Street, Quahog, RI', '7076482788'),
                          ('753820299420', 'Jonas', 'Kahnwald', '8 Feldweg, Winden', '9024513453'),
                          ('245546508395', 'Nathan', 'Do', '84 Le Van Sy, Ho Chi Minh City', '0901132384'),
                          ('234942942404', 'Talu', 'Nguyen', '32 Nguyen Van Linh, Ho Chi Minh City', '0923427373'),
                          ('235423452345', 'Claperon', 'Mendeleev', '45 Nguyen Van Troi, Ho Chi Minh City', '0902332245'),
                          ('123430495834', 'Steve', 'Harvey', '455 N Cityfront Plaza Dr. Chicago, IL', '8772978383'),
                          ('232462736227', 'Kevin', 'Hart', '6870 W. 52nd Avenue Suite 201. Arvada, CO', '8183582345'),
                          ('125367424542', 'Pharell', 'Williams', '10960 Wilshire Blvd. 5th Floor Los Angeles, CA', '8886554575'),
                          ('142456234424', 'Tran Thanh', 'Huynh', NULL, '0923456243'),
                          ('165367734345', 'Chris', 'Rock', 'P.O. Box 57593, Sherman Oaks, CA', '3105504000'),
                          ('165779803235', 'Braeden', 'Lemasters', NULL, '7342556456'),
                          ('653245653453', 'Rick', 'Ashley', NULL, '7607067425'),
                          ('934722246765', 'Tony' , 'Andreason', NULL, '3034287603'),
                          ('439568723245', 'Seth', 'MacFarlane', '10201 West Pico Blvd. Los Angeles, CA', '3238578800');

DELETE FROM Trainee
INSERT INTO Trainee VALUES ('568470008000', STR_TO_DATE ('12,05,1956','%d,%m,%Y'), 'https://www.gannett-cdn.com/-mm-/fd5c5b5393c72a785789f0cd5bd20acedd2d2804/c=0-350-2659-1850/local/-/media/Phoenix/BillGoodykoontz/2014/04/24//1398388295000-Homer-Simpson.jpg', 'C007'),
                           ('324461828345', STR_TO_DATE ('20,12,1956','%d,%m,%Y'), 'https://www.liveabout.com/thmb/APMQQFMHcHHnJyXnZntsFDu0RLo=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/peter_2008_v2F_hires1-56a00f083df78cafda9fdcb6.jpg', 'C005'),
                           ('324294724455', STR_TO_DATE ('03,06,1958','%d,%m,%Y'), 'https://ichef.bbci.co.uk/images/ic/1200x675/p05pkmhp.jpg', 'CC05'),
                           ('124543143556', STR_TO_DATE ('25,03,1948','%d,%m,%Y'), 'https://i.pinimg.com/736x/aa/e8/92/aae892d46777024facfb01dabe88fd86--glenn-quagmire-family-tv.jpg', 'C006'),
                           ('342762497115', STR_TO_DATE ('07,11,1953','%d,%m,%Y'), 'https://pbs.twimg.com/media/EcaeWM5XYAIAVLU.jpg', 'C008'),
                           ('342923879219', STR_TO_DATE ('30,07,1957','%d,%m,%Y'), 'https://static.wikia.nocookie.net/cleveland/images/4/43/Cleveland_ClevelandDance_v3F.jpg/revision/latest?cb=20180301102227', 'C006'),
                           ('753820299420', STR_TO_DATE ('02,03,2003','%d,%m,%Y'), 'https://64.media.tumblr.com/9443bd94b95ef0ecdaefacc3ee61aae2/tumblr_p7ey21Mfbt1r09d6po2_540.png', 'C001'),
                           ('245546508395', STR_TO_DATE ('02,09,2002','%d,%m,%Y'), 'https://media-exp1.licdn.com/dms/image/C5603AQGmzCAQltMiww/profile-displayphoto-shrink_200_200/0/1659430741203?e=1675296000&v=beta&t=h7zBuJYIxmFT3F6oWNKe1O364m31FQUpejUXguK9BHA', 'C003'),
                           ('234942942404', STR_TO_DATE ('01,01,2002','%d,%m,%Y'), NULL, 'C002'),
                           ('235423452345', STR_TO_DATE ('23,05,2002','%d,%m,%Y'), NULL, 'C004');

DELETE FROM MC
INSERT INTO MC VALUES ('123430495834'),
                      ('232462736227'),
                      ('142456234424'),
                      ('165367734345');

DELETE FROM Mentor
INSERT INTO Mentor VALUES ('125367424542'),
                          ('165779803235'),
                          ('653245653453'),
                          ('439568723245');

DELETE FROM Song
INSERT INTO Song(released_year, name, singer_ssn_first_performed) VALUES (2019, 'Are You Bored Yet?', '245546508395'),
                                                                         (1961, 'Meet the Flintstones', '568470008000'),
                                                                         (1963, 'Surfin'' Bird', '324461828345'),
                                                                         (1994, 'Baby I Love Your Way', '324294724455'),
                                                                         (2011, 'Giggity-Goo', '124543143556'),
                                                                         (1987 ,'Never Gonna Give You Up', '342762497115'),
                                                                         (2005, 'Theme from "Family Guy"', '342923879219'),
                                                                         (1967, 'What a Wonderful World', '753820299420'),
                                                                         (2022, 'Bùa Chú', '234942942404'),
                                                                         (2016, 'The FCC Song', '235423452345');
DELETE FROM ThemeSong
INSERT INTO ThemeSong VALUES ('S7'),
                             ('S3'),
                             ('S5'),
                             ('S10');

DELETE FROM SongComposedBy
INSERT INTO SongComposedBy VALUES ('S1', '165779803235'),
                                  ('S6', '653245653453'),
                                  ('S3', '934722246765'),
                                  ('S7', '439568723245'),
                                  ('S10', '439568723245');

DELETE FROM Singer
INSERT INTO Singer VALUES ('125367424542', NULL),
                          ('165779803235', NULL),
                          ('653245653453', NULL),
                          ('439568723245', NULL);

SET FOREIGN_KEY_CHECKS = 1;
-- @block
--DELIMITER //
--CREATE TRIGGER Trainee_participation
--BEFORE INSERT ON SeasonTrainee
--FOR EACH ROW
--BEGIN
--	IF 
--END//
--DELIMITER ;