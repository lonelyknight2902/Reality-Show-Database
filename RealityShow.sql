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

DROP TABLE IF EXISTS Trainee;
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

DROP TABLE IF EXISTS Song;
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

DROP TABLE IF EXISTS Song_seq;
CREATE TABLE Song_seq
(
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY
);

DROP TRIGGER IF EXISTS Song_insert;
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

DELETE FROM Company;
INSERT INTO Company VALUES ('C001', 'VNG', '02839623888', STR_TO_DATE ('09,09,2004','%d,%m,%Y')),
                           ('C002', 'Google LLC', '18004190157', STR_TO_DATE ('04,09,1998','%d,%m,%Y')),
                           ('C003', 'Meta', '17815754340', STR_TO_DATE ('04,02,2004','%d,%m,%Y')),
                           ('C004', 'Microsoft', '18004004700', STR_TO_DATE ('04,04,1975','%d,%m,%Y')),
                           ('C005', 'Pawtucket Patriot Brewery', '18003234334', STR_TO_DATE ('25,09,2005','%d,%m,%Y')),
                           ('C006', 'American Airlines', '18004337300', STR_TO_DATE ('15,04,1926','%d,%m,%Y')),
                           ('C007', 'Springfield Nuclear Power Plant', '18004324231', STR_TO_DATE ('29,01,1968','%d,%m,%Y')),
                           ('CC08', 'Quahog Police Department', '18001324323', STR_TO_DATE ('05,01,1756','%d,%m,%Y'));
DELETE FROM Person;
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
                          ('439568723245', 'Seth', 'MacFarlane', '10201 West Pico Blvd. Los Angeles, CA', '3238578800'),
                          ('858294949452', 'Alan', 'Walker', NULL, '4759447302'),
                          ('122322345434', 'George', 'Lucas', '5858 Lucas Valley Rd., Nicasio, CA', '4156621800'),
                          ('135332567745', 'Steven', 'Spielberg', '1000 Flower Street, Glendale CA',  '8187339300'),
                          ('175543236668', 'Peter', 'Jackson', '9-11 Manuka Street, Miramar, Wellington', '4049096000'),
                          ('000000003130', 'Rosella', 'Burks', NULL, '9635551253'),
                          ('000000003297', 'Damien', 'Avila', NULL, '9635551352'),
                          ('000000003547', 'Robin', 'Olsen', NULL, '9635551378'),
                          ('000000001538', 'Edgar', 'Moises', NULL, '9635552731'),
                          ('000000002941', 'Heath', 'Brian', NULL, '9635552800'),
                          ('000000002401', 'Elvin', 'Claude', NULL, '9635552902'),
                          ('000000002070', 'Edmund', 'Mosley', NULL, '9635552945'),
                          ('000000002561', 'Antoine', 'Derek', NULL, '9635552992'),
                          ('000000001625', 'Callie', 'Hawkins', NULL, '9635553350'),
                          ('000000001307', 'Andrea', 'Pate', NULL, '9635553723'),
                          ('000000002342', 'Liz', 'Austin', NULL, '9635554305'),
                          ('000000002755', 'Reba', 'Kendrick', NULL, '9635554618'),
                          ('000000004150', 'Angelina', 'Sims', NULL, '9635555278'),
                          ('000000003544', 'Kimberly', 'Mullins', NULL, '9635555471'),
                          ('000000002096', 'Lloyd', 'Chuck', NULL, '9635555568'),
                          ('000000001089', 'Ladonna', 'Payne', NULL, '9635555639'),
                          ('000000002948', 'Johnathan', 'Baxter', NULL, '9635555902'),
                          ('000000004539', 'Gilbert', 'Weiss', NULL, '9635555969'),
                          ('000000002811', 'Florence', 'Deirdre', NULL, '9635556319'),
                          ('000000004580', 'Toby', 'Fernando', NULL, '9635556469'),
                          ('000000002895', 'Patrica', 'Garrison', NULL, '9635556760'),
                          ('000000002254', 'Leila', 'Effie', NULL, '9635556824'),
                          ('000000002389', 'Rose', 'Buckley', NULL, '9635556855'),
                          ('000000001699', 'Kathie', 'Stanton', NULL, '9635557095'),
                          ('000000001567', 'Shannon', 'Banks', NULL, '9635557198'),
                          ('000000003066', 'Cleo', 'Barnes', NULL, '9635557463'),
                          ('000000002426', 'Nellie', 'Brady', NULL, '9635557569'),
                          ('000000002217', 'Ruben', 'Katheryn', NULL, '9635557578'),
                          ('000000001968', 'Dianne', 'Michael', NULL, '9635557592'),
                          ('000000003012', 'Adam', 'Grant', NULL, '9635557775'),
                          ('000000001824', 'Kurtis', 'Head', NULL, '9635557882'),
                          ('000000003929', 'Jami', 'Berger', NULL, '9635558158'),
                          ('000000002682', 'Jamie', 'Earline', NULL, '9635558357'),
                          ('000000003112', 'Summer', 'Evelyn', NULL, '9635558895'),
                          ('000000002303', 'Sam', 'Quentin', NULL, '9635558921'),
                          ('000000003903', 'Ann', 'Dunlap', NULL, '9635559067'),
                          ('000000003095', 'Rich', 'Shields', NULL, '9635559197'),
                          ('000000002383', 'Winnie', 'Page', NULL, '9635559366'),
                          ('000000002146', 'Ezra', 'Sparks', NULL, '9635559390'),
                          ('000000003958', 'Elba', 'Kaufman', NULL, '9635559507');

DELETE FROM Trainee;
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

DELETE FROM MC;
INSERT INTO MC VALUES ('123430495834'),
                      ('232462736227'),
                      ('142456234424'),
                      ('165367734345');

DELETE FROM Mentor;
INSERT INTO Mentor VALUES ('125367424542'),
                          ('165779803235'),
                          ('653245653453'),
                          ('934722246765'),
                          ('439568723245'),
                          ('858294949452'),
                          ('122322345434'),
                          ('135332567745'),
                          ('175543236668');

DELETE FROM Song;
INSERT INTO Song(released_year, name, singer_ssn_first_performed) VALUES (2019, 'Are You Bored Yet?', '245546508395'),
                                                                         (1961, 'Meet the Flintstones', '568470008000'),
                                                                         (1963, 'Surfin'' Bird', '324461828345'),
                                                                         (1994, 'Baby I Love Your Way', '324294724455'),
                                                                         (2011, 'Giggity-Goo', '124543143556'),
                                                                         (1987 ,'Never Gonna Give You Up', '342762497115'),
                                                                         (2005, 'Theme from "Family Guy"', '342923879219'),
                                                                         (1967, 'What a Wonderful World', '753820299420'),
                                                                         (2022, 'Bùa Chú', '234942942404'),
                                                                         (2016, 'The FCC Song', '235423452345'),
                                                                         (2014, 'Faded', '342453534135'),
                                                                         (2019, 'On My Way', '123343423556');
DELETE FROM ThemeSong;
INSERT INTO ThemeSong VALUES ('S7'),
                             ('S2'),
                             ('S8'),
                             ('S5'),
                             ('S9');

DELETE FROM SongComposedBy;
INSERT INTO SongComposedBy VALUES ('S1', '165779803235'),
                                  ('S6', '653245653453'),
                                  ('S3', '934722246765'),
                                  ('S7', '439568723245'),
                                  ('S10', '439568723245');

DELETE FROM Singer;
INSERT INTO Singer VALUES ('125367424542', NULL),
                          ('165779803235', NULL),
                          ('653245653453', NULL),
                          ('439568723245', NULL);

INSERT INTO SingerSignatureSong VALUES ();

INSERT INTO Producer VALUES ('439568723245'),
                            ('122322345434'),
                            ('135332567745'),
                            ('175543236668');

INSERT INTO ProducerProgram VALUES ('439568723245', 'Family Guy'),
                                   ('122322345434', 'Star Wars'),
                                   ('175543236668', 'Back to the Future'),
                                   ('175543236668', 'The Lord of the Rings');

INSERT INTO SongWriter VALUES ('165779803235'),
                              ('653245653453'),
                              ('439568723245'),
                              ('858294949452');

INSERT INTO Season VALUES (2021, 'Quahog', 'S7', '232462736227'),
                          (2022, 'Ho Chi Minh City', 'S9', '142456234424');

INSERT INTO SeasonMentor VALUES (2022, '135332567745'),
                                (2022, '858294949452'),
                                (2022, '439568723245'),
                                (2022, '653245653453'),
                                (2021, '165779803235'),
                                (2021, '439568723245'),
                                (2021, '934722246765'),
                                (2021, '175543236668');

INSERT INTO SeasonTrainee VALUES (2021, '568470008000'),
                                 (2021, '324461828345'),
                                 (2021, '324294724455'),
                                 (2021, '124543143556'),
                                 (2021, '342762497115'),
                                 (2021, '342923879219'),
                                 (2021, '245546508395'),
                                 (2021, '000000003130'),
                                 (2021, '000000003297'),
                                 (2021, '000000003547'),
                                 (2021, '000000001538'),
                                 (2021, '000000002941'),
                                 (2021, '000000002401'),
                                 (2021, '000000002070'),
                                 (2021, '000000002561'),
                                 (2021, '000000001625'),
                                 (2021, '000000001307'),
                                 (2021, '000000002342'),
                                 (2021, '000000002755'),
                                 (2021, '000000004150'),
                                 (2021, '000000003544'),
                                 (2021, '000000002096'),
                                 (2021, '000000001089'),
                                 (2021, '000000002948'),
                                 (2021, '000000004539'),
                                 (2021, '000000002811'),
                                 (2021, '000000004580'),
                                 (2021, '000000002895'),
                                 (2021, '000000002254'),
                                 (2021, '000000002389'),
                                 (2021, '000000001699'),
                                 (2021, '000000001567'),
                                 (2021, '000000003066'),
                                 (2021, '000000002426'),
                                 (2021, '000000002217'),
                                 (2021, '000000001968'),
                                 (2021, '000000003012'),
                                 (2021, '000000001824'),
                                 (2021, '000000003929'),
                                 (2021, '000000002682'),
                                 (2021, '000000003112'),
                                 (2021, '000000002303'),
                                 (2021, '000000003903'),
                                 (2021, '000000003095'),
                                 (2021, '000000002383'),
                                 (2021, '000000002146'),
                                 (2021, '000000003958'),
                                 (2022, '234942942404'),
                                 (2022, '324461828345'),
                                 (2022, '324294724455'),
                                 (2022, '124543143556'),
                                 (2022, '235423452345'),
                                 (2022, '753820299420'),
                                 (2022, '245546508395'),
                                 (2022, '000000003130'),
                                 (2022, '000000003297'),
                                 (2022, '000000003547'),
                                 (2022, '000000001538'),
                                 (2022, '000000002941'),
                                 (2022, '000000002401'),
                                 (2022, '000000002070'),
                                 (2022, '000000002561'),
                                 (2022, '000000001625'),
                                 (2022, '000000001307'),
                                 (2022, '000000002342'),
                                 (2022, '000000002755'),
                                 (2022, '000000004150'),
                                 (2022, '000000003544'),
                                 (2022, '000000002096'),
                                 (2022, '000000001089'),
                                 (2022, '000000002948'),
                                 (2022, '000000004539'),
                                 (2022, '000000002811'),
                                 (2022, '000000004580'),
                                 (2022, '000000002895'),
                                 (2022, '000000002254'),
                                 (2022, '000000002389'),
                                 (2022, '000000001699'),
                                 (2022, '000000001567'),
                                 (2022, '000000003066'),
                                 (2022, '000000002426'),
                                 (2022, '000000002217'),
                                 (2022, '000000001968'),
                                 (2022, '000000003012'),
                                 (2022, '000000001824'),
                                 (2022, '000000003929'),
                                 (2022, '000000002682'),
                                 (2022, '000000003112'),
                                 (2022, '000000002303'),
                                 (2022, '000000003903'),
                                 (2022, '000000003095'),
                                 (2022, '000000002383'),
                                 (2022, '000000002146'),
                                 (2022, '000000003958');

INSERT INTO MentorValuateTrainee VALUES (2021, '568470008000', '165779803235', 50),
                                        (2021, '568470008000', '439568723245', 60),
                                        (2021, '568470008000', '934722246765', 60),
                                        (2021, '568470008000', '175543236668', 45),

                                        (2021, '324461828345', '165779803235', 70),
                                        (2021, '324461828345', '439568723245', 60),
                                        (2021, '324461828345', '934722246765', 65),
                                        (2021, '324461828345', '175543236668', 65),

                                        (2021, '324294724455', '165779803235', 55),
                                        (2021, '324294724455', '439568723245', 45),
                                        (2021, '324294724455', '934722246765', 30),
                                        (2021, '324294724455', '175543236668', 50),

                                        (2021, '124543143556', '165779803235', 90),
                                        (2021, '124543143556', '439568723245', 85),
                                        (2021, '124543143556', '934722246765', 75),
                                        (2021, '124543143556', '175543236668', 95),

                                        (2021, '342762497115', '165779803235', 15),
                                        (2021, '342762497115', '439568723245', 10),
                                        (2021, '342762497115', '934722246765', 20),
                                        (2021, '342762497115', '175543236668', 30),

                                        (2021, '342923879219', '165779803235', 50),
                                        (2021, '342923879219', '439568723245', 60),
                                        (2021, '342923879219', '934722246765', 50),
                                        (2021, '342923879219', '175543236668', 45),

                                        (2021, '245546508395', '165779803235', 55),
                                        (2021, '245546508395', '439568723245', 65),
                                        (2021, '245546508395', '934722246765', 50),
                                        (2021, '245546508395', '175543236668', 65),

                                        (2021, '000000003130', '165779803235', 53),
                                        (2021, '000000003130', '439568723245', 61),
                                        (2021, '000000003130', '934722246765', 55),
                                        (2021, '000000003130', '175543236668', 62),

                                        (2021, '000000003297', '165779803235', 78),
                                        (2021, '000000003297', '439568723245', 66),
                                        (2021, '000000003297', '934722246765', 86),
                                        (2021, '000000003297', '175543236668', 76),

                                        (2021, '000000003547', '165779803235', 87),
                                        (2021, '000000003547', '439568723245', 78),
                                        (2021, '000000003547', '934722246765', 78),
                                        (2021, '000000003547', '175543236668', 70),

                                        (2021, '000000001538', '165779803235', 34),
                                        (2021, '000000001538', '439568723245', 23),
                                        (2021, '000000001538', '934722246765', 45),
                                        (2021, '000000001538', '175543236668', 34),

                                        (2021, '000000002941', '165779803235', 45),
                                        (2021, '000000002941', '439568723245', 56),
                                        (2021, '000000002941', '934722246765', 52),
                                        (2021, '000000002941', '175543236668', 62),

                                        (2021, '000000002401', '165779803235', 67),
                                        (2021, '000000002401', '439568723245', 67),
                                        (2021, '000000002401', '934722246765', 64),
                                        (2021, '000000002401', '175543236668', 63),

                                        (2021, '000000002070', '165779803235', 89),
                                        (2021, '000000002070', '439568723245', 85),
                                        (2021, '000000002070', '934722246765', 88),
                                        (2021, '000000002070', '175543236668', 89),

                                        (2021, '000000002561', '165779803235', 65),
                                        (2021, '000000002561', '439568723245', 71),
                                        (2021, '000000002561', '934722246765', 72),
                                        (2021, '000000002561', '175543236668', 69),

                                        (2021, '000000001625', '165779803235', 45),
                                        (2021, '000000001625', '439568723245', 34),
                                        (2021, '000000001625', '934722246765', 38),
                                        (2021, '000000001625', '175543236668', 40),

                                        (2021, '000000001307', '165779803235', 98),
                                        (2021, '000000001307', '439568723245', 96),
                                        (2021, '000000001307', '934722246765', 93),
                                        (2021, '000000001307', '175543236668', 96),

                                        (2021, '000000002342', '165779803235', 90),
                                        (2021, '000000002342', '439568723245', 87),
                                        (2021, '000000002342', '934722246765', 89),
                                        (2021, '000000002342', '175543236668', 83),

                                        (2021, '000000002755', '165779803235', 23),
                                        (2021, '000000002755', '439568723245', 34),
                                        (2021, '000000002755', '934722246765', 30),
                                        (2021, '000000002755', '175543236668',32),

                                        (2021, '000000004150', '165779803235', 78),
                                        (2021, '000000004150', '439568723245', 74),
                                        (2021, '000000004150', '934722246765', 77),
                                        (2021, '000000004150', '175543236668', 70),

                                        (2021, '000000003544', '165779803235', 56),
                                        (2021, '000000003544', '439568723245', 36),
                                        (2021, '000000003544', '934722246765', 45),
                                        (2021, '000000003544', '175543236668', 58),

                                        (2021, '000000002096', '165779803235', 67),
                                        (2021, '000000002096', '439568723245', 72),
                                        (2021, '000000002096', '934722246765', 68),
                                        (2021, '000000002096', '175543236668', 74),

                                        (2021, '000000001089', '165779803235', 56),
                                        (2021, '000000001089', '439568723245', 45),
                                        (2021, '000000001089', '934722246765', 59),
                                        (2021, '000000001089', '175543236668', 47),

                                        (2021, '000000002948', '165779803235', 34),
                                        (2021, '000000002948', '439568723245', 37),
                                        (2021, '000000002948', '934722246765', 36),
                                        (2021, '000000002948', '175543236668', 35),

                                        (2021, '000000004539', '165779803235', 78),
                                        (2021, '000000004539', '439568723245', 74),
                                        (2021, '000000004539', '934722246765', 80),
                                        (2021, '000000004539', '175543236668', 78),

                                        (2021, '000000002811', '165779803235', 78),
                                        (2021, '000000002811', '439568723245', 72),
                                        (2021, '000000002811', '934722246765', 75),
                                        (2021, '000000002811', '175543236668', 75),

                                        (2021, '000000004580', '165779803235', 65),
                                        (2021, '000000004580', '439568723245', 61),
                                        (2021, '000000004580', '934722246765', 58),
                                        (2021, '000000004580', '175543236668', 59),

                                        (2021, '000000002895', '165779803235', 43),
                                        (2021, '000000002895', '439568723245', 38),
                                        (2021, '000000002895', '934722246765', 41),
                                        (2021, '000000002895', '175543236668', 39),

                                        (2021, '000000002254', '165779803235', 34),
                                        (2021, '000000002254', '439568723245', 28),
                                        (2021, '000000002254', '934722246765', 27),
                                        (2021, '000000002254', '175543236668', 31),

                                        (2021, '000000002389', '165779803235', 73),
                                        (2021, '000000002389', '439568723245', 73),
                                        (2021, '000000002389', '934722246765', 74),
                                        (2021, '000000002389', '175543236668', 77),

                                        (2021, '000000001699', '165779803235', 87),
                                        (2021, '000000001699', '439568723245', 89),
                                        (2021, '000000001699', '934722246765', 84),
                                        (2021, '000000001699', '175543236668', 81),

                                        (2021, '000000001567', '165779803235', 56),
                                        (2021, '000000001567', '439568723245', 65),
                                        (2021, '000000001567', '934722246765', 58),
                                        (2021, '000000001567', '175543236668', 57),

                                        (2021, '000000003066', '165779803235', 78),
                                        (2021, '000000003066', '439568723245', 82),
                                        (2021, '000000003066', '934722246765', 81),
                                        (2021, '000000003066', '175543236668', 75),

                                        (2021, '000000002426', '165779803235', 89),
                                        (2021, '000000002426', '439568723245', 94),
                                        (2021, '000000002426', '934722246765', 93),
                                        (2021, '000000002426', '175543236668', 96),

                                        (2021, '000000002217', '165779803235', 76),
                                        (2021, '000000002217', '439568723245', 74),
                                        (2021, '000000002217', '934722246765', 80),
                                        (2021, '000000002217', '175543236668', 76),

                                        (2021, '000000001968', '165779803235', 64),
                                        (2021, '000000001968', '439568723245', 55),
                                        (2021, '000000001968', '934722246765', 59),
                                        (2021, '000000001968', '175543236668', 60),

                                        (2021, '000000003012', '165779803235', 34),
                                        (2021, '000000003012', '439568723245', 35),
                                        (2021, '000000003012', '934722246765', 39),
                                        (2021, '000000003012', '175543236668', 30),

                                        (2021, '000000001824', '165779803235', 88),
                                        (2021, '000000001824', '439568723245', 82),
                                        (2021, '000000001824', '934722246765', 91),
                                        (2021, '000000001824', '175543236668', 85),

                                        (2021, '000000003929', '165779803235', 76),
                                        (2021, '000000003929', '439568723245', 72),
                                        (2021, '000000003929', '934722246765', 73),
                                        (2021, '000000003929', '175543236668', 74),

                                        (2021, '000000002682', '165779803235', 87),
                                        (2021, '000000002682', '439568723245', 84),
                                        (2021, '000000002682', '934722246765', 89),
                                        (2021, '000000002682', '175543236668', 85),

                                        (2021, '000000003112', '165779803235', 55),
                                        (2021, '000000003112', '439568723245', 55),
                                        (2021, '000000003112', '934722246765', 55),
                                        (2021, '000000003112', '175543236668', 50),

                                        (2021, '000000002303', '165779803235', 34),
                                        (2021, '000000002303', '439568723245', 38),
                                        (2021, '000000002303', '934722246765', 49),
                                        (2021, '000000002303', '175543236668', 29),

                                        (2021, '000000003903', '165779803235', 74),
                                        (2021, '000000003903', '439568723245', 65),
                                        (2021, '000000003903', '934722246765', 59),
                                        (2021, '000000003903', '175543236668', 57),

                                        (2021, '000000003095', '165779803235', 98),
                                        (2021, '000000003095', '439568723245', 100),
                                        (2021, '000000003095', '934722246765', 99),
                                        (2021, '000000003095', '175543236668', 99),

                                        (2021, '000000002383', '165779803235', 89),
                                        (2021, '000000002383', '439568723245', 88),
                                        (2021, '000000002383', '934722246765', 88),
                                        (2021, '000000002383', '175543236668', 93),

                                        (2021, '000000002146', '165779803235', 87),
                                        (2021, '000000002146', '439568723245', 78),
                                        (2021, '000000002146', '934722246765', 83),
                                        (2021, '000000002146', '175543236668', 84),

                                        (2021, '000000003958', '165779803235', 55),
                                        (2021, '000000003958', '439568723245', 62),
                                        (2021, '000000003958', '934722246765', 59),
                                        (2021, '000000003958', '175543236668', 58),

                                        (2022, '234942942404', '165779803235', 70),
                                        (2022, '234942942404', '439568723245', 80),
                                        (2022, '234942942404', '934722246765', 70),
                                        (2022, '234942942404', '175543236668', 75),

                                        (2022, '324461828345', '165779803235', 30),
                                        (2022, '324461828345', '439568723245', 50),
                                        (2022, '324461828345', '934722246765', 45),
                                        (2022, '324461828345', '175543236668', 40),

                                        (2022, '324294724455', '165779803235', 55),
                                        (2022, '324294724455', '439568723245', 55),
                                        (2022, '324294724455', '934722246765', 60),
                                        (2022, '324294724455', '175543236668', 55),

                                        (2022, '124543143556', '165779803235', 70),
                                        (2022, '124543143556', '439568723245', 70),
                                        (2022, '124543143556', '934722246765', 80),
                                        (2022, '124543143556', '175543236668', 75),

                                        (2022, '235423452345', '165779803235', 90),
                                        (2022, '235423452345', '439568723245', 80),
                                        (2022, '235423452345', '934722246765', 80),
                                        (2022, '235423452345', '175543236668', 85),

                                        (2022, '753820299420', '165779803235', 65),
                                        (2022, '753820299420', '439568723245', 70),
                                        (2022, '753820299420', '934722246765', 60),
                                        (2022, '753820299420', '175543236668', 60),

                                        (2022, '245546508395', '165779803235', 55),
                                        (2022, '245546508395', '439568723245', 65),
                                        (2022, '245546508395', '934722246765', 60),
                                        (2022, '245546508395', '175543236668', 45),

                                        (2022, '000000003130', '165779803235', 53),
                                        (2022, '000000003130', '439568723245', 61),
                                        (2022, '000000003130', '934722246765', 55),
                                        (2022, '000000003130', '175543236668', 62),

                                        (2022, '000000003297', '165779803235', 78),
                                        (2022, '000000003297', '439568723245', 66),
                                        (2022, '000000003297', '934722246765', 86),
                                        (2022, '000000003297', '175543236668', 76),

                                        (2022, '000000003547', '165779803235', 87),
                                        (2022, '000000003547', '439568723245', 78),
                                        (2022, '000000003547', '934722246765', 78),
                                        (2022, '000000003547', '175543236668', 70),

                                        (2022, '000000001538', '165779803235', 34),
                                        (2022, '000000001538', '439568723245', 23),
                                        (2022, '000000001538', '934722246765', 45),
                                        (2022, '000000001538', '175543236668', 34),

                                        (2022, '000000002941', '165779803235', 45),
                                        (2022, '000000002941', '439568723245', 56),
                                        (2022, '000000002941', '934722246765', 52),
                                        (2022, '000000002941', '175543236668', 62),

                                        (2022, '000000002401', '165779803235', 67),
                                        (2022, '000000002401', '439568723245', 67),
                                        (2022, '000000002401', '934722246765', 64),
                                        (2022, '000000002401', '175543236668', 63),

                                        (2022, '000000002070', '165779803235', 89),
                                        (2022, '000000002070', '439568723245', 85),
                                        (2022, '000000002070', '934722246765', 88),
                                        (2022, '000000002070', '175543236668', 89),

                                        (2022, '000000002561', '165779803235', 65),
                                        (2022, '000000002561', '439568723245', 71),
                                        (2022, '000000002561', '934722246765', 72),
                                        (2022, '000000002561', '175543236668', 69),

                                        (2022, '000000001625', '165779803235', 45),
                                        (2022, '000000001625', '439568723245', 34),
                                        (2022, '000000001625', '934722246765', 38),
                                        (2022, '000000001625', '175543236668', 40),

                                        (2022, '000000001307', '165779803235', 98),
                                        (2022, '000000001307', '439568723245', 96),
                                        (2022, '000000001307', '934722246765', 93),
                                        (2022, '000000001307', '175543236668', 96),

                                        (2022, '000000002342', '165779803235', 90),
                                        (2022, '000000002342', '439568723245', 87),
                                        (2022, '000000002342', '934722246765', 89),
                                        (2022, '000000002342', '175543236668', 83),

                                        (2022, '000000002755', '165779803235', 23),
                                        (2022, '000000002755', '439568723245', 34),
                                        (2022, '000000002755', '934722246765', 30),
                                        (2022, '000000002755', '175543236668',32),

                                        (2022, '000000004150', '165779803235', 78),
                                        (2022, '000000004150', '439568723245', 74),
                                        (2022, '000000004150', '934722246765', 77),
                                        (2022, '000000004150', '175543236668', 70),

                                        (2022, '000000003544', '165779803235', 56),
                                        (2022, '000000003544', '439568723245', 36),
                                        (2022, '000000003544', '934722246765', 45),
                                        (2022, '000000003544', '175543236668', 58),

                                        (2022, '000000002096', '165779803235', 67),
                                        (2022, '000000002096', '439568723245', 72),
                                        (2022, '000000002096', '934722246765', 68),
                                        (2022, '000000002096', '175543236668', 74),

                                        (2022, '000000001089', '165779803235', 56),
                                        (2022, '000000001089', '439568723245', 45),
                                        (2022, '000000001089', '934722246765', 59),
                                        (2022, '000000001089', '175543236668', 47),

                                        (2022, '000000002948', '165779803235', 34),
                                        (2022, '000000002948', '439568723245', 37),
                                        (2022, '000000002948', '934722246765', 36),
                                        (2022, '000000002948', '175543236668', 35),

                                        (2022, '000000004539', '165779803235', 78),
                                        (2022, '000000004539', '439568723245', 74),
                                        (2022, '000000004539', '934722246765', 80),
                                        (2022, '000000004539', '175543236668', 78),

                                        (2022, '000000002811', '165779803235', 78),
                                        (2022, '000000002811', '439568723245', 72),
                                        (2022, '000000002811', '934722246765', 75),
                                        (2022, '000000002811', '175543236668', 75),

                                        (2022, '000000004580', '165779803235', 65),
                                        (2022, '000000004580', '439568723245', 61),
                                        (2022, '000000004580', '934722246765', 58),
                                        (2022, '000000004580', '175543236668', 59),

                                        (2022, '000000002895', '165779803235', 43),
                                        (2022, '000000002895', '439568723245', 38),
                                        (2022, '000000002895', '934722246765', 41),
                                        (2022, '000000002895', '175543236668', 39),

                                        (2022, '000000002254', '165779803235', 34),
                                        (2022, '000000002254', '439568723245', 28),
                                        (2022, '000000002254', '934722246765', 27),
                                        (2022, '000000002254', '175543236668', 31),

                                        (2022, '000000002389', '165779803235', 73),
                                        (2022, '000000002389', '439568723245', 73),
                                        (2022, '000000002389', '934722246765', 74),
                                        (2022, '000000002389', '175543236668', 77),

                                        (2022, '000000001699', '165779803235', 87),
                                        (2022, '000000001699', '439568723245', 89),
                                        (2022, '000000001699', '934722246765', 84),
                                        (2022, '000000001699', '175543236668', 81),

                                        (2022, '000000001567', '165779803235', 56),
                                        (2022, '000000001567', '439568723245', 65),
                                        (2022, '000000001567', '934722246765', 58),
                                        (2022, '000000001567', '175543236668', 57),

                                        (2022, '000000003066', '165779803235', 78),
                                        (2022, '000000003066', '439568723245', 82),
                                        (2022, '000000003066', '934722246765', 81),
                                        (2022, '000000003066', '175543236668', 75),

                                        (2022, '000000002426', '165779803235', 89),
                                        (2022, '000000002426', '439568723245', 94),
                                        (2022, '000000002426', '934722246765', 93),
                                        (2022, '000000002426', '175543236668', 96),

                                        (2022, '000000002217', '165779803235', 76),
                                        (2022, '000000002217', '439568723245', 74),
                                        (2022, '000000002217', '934722246765', 80),
                                        (2022, '000000002217', '175543236668', 76),

                                        (2022, '000000001968', '165779803235', 64),
                                        (2022, '000000001968', '439568723245', 55),
                                        (2022, '000000001968', '934722246765', 59),
                                        (2022, '000000001968', '175543236668', 60),

                                        (2022, '000000003012', '165779803235', 34),
                                        (2022, '000000003012', '439568723245', 35),
                                        (2022, '000000003012', '934722246765', 39),
                                        (2022, '000000003012', '175543236668', 30),

                                        (2022, '000000001824', '165779803235', 88),
                                        (2022, '000000001824', '439568723245', 82),
                                        (2022, '000000001824', '934722246765', 91),
                                        (2022, '000000001824', '175543236668', 85),

                                        (2022, '000000003929', '165779803235', 76),
                                        (2022, '000000003929', '439568723245', 72),
                                        (2022, '000000003929', '934722246765', 73),
                                        (2022, '000000003929', '175543236668', 74),

                                        (2022, '000000002682', '165779803235', 87),
                                        (2022, '000000002682', '439568723245', 84),
                                        (2022, '000000002682', '934722246765', 89),
                                        (2022, '000000002682', '175543236668', 85),

                                        (2022, '000000003112', '165779803235', 55),
                                        (2022, '000000003112', '439568723245', 55),
                                        (2022, '000000003112', '934722246765', 55),
                                        (2022, '000000003112', '175543236668', 50),

                                        (2022, '000000002303', '165779803235', 34),
                                        (2022, '000000002303', '439568723245', 38),
                                        (2022, '000000002303', '934722246765', 49),
                                        (2022, '000000002303', '175543236668', 29),

                                        (2022, '000000003903', '165779803235', 74),
                                        (2022, '000000003903', '439568723245', 65),
                                        (2022, '000000003903', '934722246765', 59),
                                        (2022, '000000003903', '175543236668', 57),

                                        (2022, '000000003095', '165779803235', 98),
                                        (2022, '000000003095', '439568723245', 100),
                                        (2022, '000000003095', '934722246765', 99),
                                        (2022, '000000003095', '175543236668', 99),

                                        (2022, '000000002383', '165779803235', 89),
                                        (2022, '000000002383', '439568723245', 88),
                                        (2022, '000000002383', '934722246765', 88),
                                        (2022, '000000002383', '175543236668', 93),

                                        (2022, '000000002146', '165779803235', 87),
                                        (2022, '000000002146', '439568723245', 78),
                                        (2022, '000000002146', '934722246765', 83),
                                        (2022, '000000002146', '175543236668', 84),

                                        (2022, '000000003958', '165779803235', 55),
                                        (2022, '000000003958', '439568723245', 62),
                                        (2022, '000000003958', '934722246765', 59),
                                        (2022, '000000003958', '175543236668', 58);

INSERT INTO Episode VALUES (2021, 1, 'Chitty Chitty Death Bang', STR_TO_DATE ('03,10,2021','%d,%m,%Y'), 60),
                           (2021, 2, 'Fifteen Minutes of Shame', STR_TO_DATE ('10,10,2021','%d,%m,%Y'), 90),
                           (2021, 3, 'Hannah Banana', STR_TO_DATE ('17,10,2021','%d,%m,%Y'), 90),
                           (2021, 4, 'Killer Queen', STR_TO_DATE ('24,10,2021','%d,%m,%Y'), 90),
                           (2021, 5, 'Hell Comes to Quahog', STR_TO_DATE ('31,10,2021','%d,%m,%Y'), 180),
                           (2022, 1, 'The Splendid Source', STR_TO_DATE ('02,10,2022','%d,%m,%Y'), 60),
                           (2022, 2, 'Something, Something, Something, Dark Side', STR_TO_DATE ('09,10,2022','%d,%m,%Y'), 90),
                           (2022, 3, 'American Gigg-olo', STR_TO_DATE ('16,10,2022','%d,%m,%Y'), 90),
                           (2022, 4, 'Switch the Flip', STR_TO_DATE ('23,10,2022','%d,%m,%Y'), 90),
                           (2022, 5, 'Bend or Blockbuster', STR_TO_DATE ('30,10,2022','%d,%m,%Y'), 180);

DELIMITER //
CREATE TRIGGER Stage_total_vote
    BEFORE INSERT ON Stage
    FOR EACH ROW
    BEGIN
        DECLARE vote INT;

        SELECT SUM(no_of_votes)
            INTO vote
        FROM StageIncludeTrainee
            WHERE (ep_no = NEW.ep_no AND stage_no = NEW.stage_no);

        SET total_vote = vote;
    end //
DELIMITER ;

INSERT INTO Stage(year, ep_no, stage_no, is_group, skill, song_id) VALUES (2021, 1, 1, FALSE, 1, 'S7'),
                                                                          (2021, 2, 1, TRUE, 1, 'S6'),
                                                                          (2021, 2, 2, TRUE, 1, 'S3'),
                                                                          (2021, 2, 3, TRUE, 2, 'S4'),
                                                                          (2021, 2, 4, TRUE, 2, 'S10'),
                                                                          (2021, 2, 5, TRUE, 3, 'S11'),
                                                                          (2021, 2, 6, TRUE, 3, 'S12');

INSERT INTO StageIncludeTrainee VALUES (2021, 2, 1, )

SET FOREIGN_KEY_CHECKS = 1;
-- @block
DELIMITER //
CREATE TRIGGER Trainee_participation
BEFORE INSERT ON SeasonTrainee
FOR EACH ROW
BEGIN
	DECLARE num_of_seasons INT;

	SELECT COUNT(*)
	    INTO num_of_seasons
    FROM SeasonTrainee
        WHERE ssn_trainee = NEW.ssn_trainee;

	IF num_of_seasons = 3 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This trainee has already participated in 3 seasons';
    ELSE IF EXISTS(SELECT 1 FROM StageIncludeTrainee WHERE NEW.ssn_trainee = StageIncludeTrainee.ssn_trainee AND StageIncludeTrainee.ep_no = 5) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'This trainee has already participated in a debut night';
    end if //
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER Trainee_stage
    BEFORE INSERT ON StageIncludeTrainee
    FOR EACH ROW
    BEGIN

    end //
DELIMITER ;