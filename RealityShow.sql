DROP DATABASE IF EXISTS REALITYSHOW;
CREATE DATABASE REALITYSHOW;

USE REALITYSHOW;

DROP TABLE IF EXISTS Company;
CREATE TABLE Company
(
    cnumber     CHAR(4) PRIMARY KEY,
    name        VARCHAR(50) NOT NULL,
    phone       CHAR(10) UNIQUE NOT NULL,
    edate       DATE
);

CREATE TABLE Person
(
    ssn         CHAR(12) PRIMARY KEY,
    fname       VARCHAR(10) NOT NULL,
    lname       VARCHAR(10) NOT NULL,
    address     VARCHAR(100),
    phone       CHAR(10) UNIQUE NOT NULL
);

CREATE TABLE Trainee
(
    ssn         CHAR(12) PRIMARY KEY,
    dob         DATE,
    photo       VARCHAR(100),
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

CREATE TABLE Song
(
    number          VARCHAR(5) PRIMARY KEY,
    released_year   YEAR,
    name            VARCHAR(20),
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