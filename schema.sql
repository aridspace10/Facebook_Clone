DROP DATABASE facebook;

CREATE DATABASE facebook;
USE facebook;

CREATE TABLE users (
	id integer PRIMARY KEY auto_increment,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL,
    DOB text not null,
    address text not null,
    email text not null,
    phone double,
    bio TEXT,
    relationship integer REFERENCES users(id),
    password TEXT NOT NULL
);

CREATE TABLE posts (
	id integer PRIMARY KEY auto_increment,
    userid integer REFERENCES users(id),
    content TEXT NOT NULL,
    likes integer not null,
    created TIMESTAMP not null);

CREATE TABLE comments (
    userid integer REFERENCES users(id),
    postid integer REFERENCES posts(id),
    content TEXT NOT NULL,
    created TIMESTAMP not null
);

CREATE TABLE friends (
	fuserid integer references users(id),
    suserid integer references users(id),
    date TIMESTAMP not null
);

CREATE TABLE requests (
    ruserid integer references users(id),
    suserid integer references users(id),
    date TIMESTAMP not null
);

INSERT INTO requests (ruserid, suserid, date) VALUES (1, 3, '2024-01-15 09:00:00');

CREATE TABLE buisness (
	id integer PRIMARY KEY auto_increment,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    phone INTEGER NOT NULL,
    email TEXT NOT NULL,
    website TEXT
);

CREATE TABLE group_info (
	id integer PRIMARY KEY auto_increment,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    created date NOT NULL,
    type TEXT NOT NULL,
    location TEXT NOT NULL,
    CONSTRAINT correctType2 CHECK (type IN ('Public', 'Private'))
);

INSERT INTO group_info (name, description, created, type, location)
VALUES 
  ('Tech Enthusiasts', 'Discuss the latest in technology', '2024-01-22', 'Public', 'San Francisco'),
  ('Fitness Freaks', 'Share workout tips and fitness goals', '2024-01-22', 'Public', 'New York'),
  ('Photography Lovers', 'Showcase and discuss photography skills', '2024-01-22', 'Private', 'Paris'),
  ('Book Club', 'Explore and discuss literature', '2024-01-22', 'Private', 'London'),
  ('Travel Explorers', 'Share travel experiences and tips', '2024-01-22', 'Public', 'Tokyo'),
  ('DIY Crafters', 'Get creative with DIY projects', '2024-01-22', 'Private', 'Berlin');

CREATE TABLE group_members( 
	groupid integer references group_info(id),
    userid integer references users(id),
    role TEXT NOT NULL,
    constraint correctRole CHECK (role IN ('Member', 'Admin', 'Moderators'))
);

INSERT INTO group_members (groupid, userid, role) VALUES (1,1,'Admin'),(1,2,'Member'),(2,3,'Admin'),(2,4,'Member'),(3,5,'Admin'),(3,6,'Member'),(4,1,'Member'),(5,4,"Member"),(5,3,"Admin");

CREATE TABLE groups_post(
	id integer PRIMARY KEY auto_increment,
	groupid integer references group_info(id),
    userid integer references users(id),
    content TEXT NOT NULL,
    created date NOT NULL
);

INSERT INTO groups_post (groupid, userid, content, created) VALUES (1,2,"Happy to be apart of the group",'2024-01-15 09:00:00'),(2,4,"Happy to be apart of the group",'2024-01-15 09:00:00'),(3,6,"Happy to be apart of the group",'2024-01-15 09:00:00'),
(4,1,"Happy to be apart of the group",'2024-01-15 09:00:00'),(5,4,"Happy to be apart of the group",'2024-01-15 09:00:00'); 

CREATE TABLE group_posts_comments(
	postid integer references groups_post(id),
    userid integer references users(id),
    content TEXT NOT NULL,
    created date NOT NULL
);

INSERT INTO group_posts_comments (postid, userid, content, created) VALUES (1,1,"Happy to be apart of the group","2024-01-22"),(2,3,"Happy to be apart of the group","2024-01-22"),(3,5,"Happy to be apart of the group","2024-01-22"),
(4,1,"Happy to be apart of the group","2024-01-22"),(5,4,"Happy to be apart of the group","2024-01-22"); 

CREATE TABLE works (
	userid integer references users(id),
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    position TEXT,
    startdate TEXT NOT NULL,
    enddate TEXT,
    location TEXT,
    profileID integer references buisness(id),
    CONSTRAINT correctType CHECK (type IN ('University','High School','Work'))
);

CREATE TABLE likes (
	postid integer references posts(id),
    userid integer references users(id)
);

CREATE TABLE groupLikes (
	postid integer references posts(id),
    userid integer references users(id)
);

CREATE TABLE event_info(
	id integer PRIMARY KEY auto_increment,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    DOC date NOT NULL,
    type TEXT NOT NULL,
    location TEXT NOT NULL,
    privacy TEXT NOT NULL,
    CONSTRAINT correctPrivacy CHECK(privacy IN ('Public', 'Private'))
);

CREATE TABLE event_post(
	id integer PRIMARY KEY auto_increment,
	eventid integer references event_info(id),
    userid integer references users(id),
    content TEXT NOT NULL,
    created date NOT NULL
);

INSERT INTO event_post (eventid, userid, content, created) VALUES (1,2,"Happy to be apart of the group","2024-01-22"),(2,4,"Happy to be apart of the group","2024-01-22"),(3,6,"Happy to be apart of the group","2024-01-22"),
(4,1,"Happy to be apart of the group","2024-01-22"),(5,4,"Happy to be apart of the group","2024-01-22"); 

CREATE TABLE event_posts_comments(
	postid integer references event_post(id),
    userid integer references users(id),
    content TEXT NOT NULL,
    created date NOT NULL
);


INSERT INTO likes (postid, userid) VALUES (1,1),(1,2),(1,3),(1,4),(1,5),(2,1),(3,2),(4,3),(5,4),(6,5);

INSERT INTO works (userid, name, type, position, startdate, enddate, location, profileID)
VALUES
    (1, 'Tech Innovators Inc.', 'Work', 'Software Developer', '2024-06-01', NULL, 'Tech City', 121),
    (1, 'City High School', 'High School', 'Senior', '2018-09-01', '2021-05-30', 'City High School', 122),
    (1, 'Tech University', 'University', 'Computer Science Student', '2020-09-01', '2024-05-30', 'Tech University', 123),

    (2, 'Marketing Solutions Co.', 'Work', 'Marketing Specialist', '2021-06-01', NULL, 'Marketing City', 124),
    (2, 'Tech High School', 'High School', 'Junior', '2019-09-01', '2022-05-30', 'Tech High School', 125),
    (2, 'Business University', 'University', 'Marketing Student', '2019-09-01', '2023-05-30', 'Business University', 126),

    (3, 'Software Dynamics Ltd.', 'Work', 'Lead Software Engineer', '2024-06-01', NULL, 'Software City', 127),
    (3, 'Another High School', 'High School', 'Junior', '2020-09-01', '2023-05-30', 'Another High School', 128),
    (3, 'Bio University', 'University', 'Biology Student', '2021-09-01', '2025-05-30', 'Bio University', 129),

    (4, 'Financial Consultants Group', 'Work', 'Financial Analyst', '2023-06-01', NULL, 'Finance City', 130),
    (4, 'Yet Another High School', 'High School', 'Senior', '2020-09-01', '2023-05-30', 'Yet Another High School', 131),
    (4, 'Finance University', 'University', 'Finance Student', '2023-06-01', '2027-05-30', 'Finance University', 132),

    (5, 'Green Energy Solutions', 'Work', 'Environmental Scientist', '2022-06-01', NULL, 'Green City', 133),
    (5, 'Eco High School', 'High School', 'Junior', '2019-09-01', '2022-05-30', 'Eco High School', 134),
    (5, 'Tech Institute', 'University', 'Computer Science Student', '2021-06-01', '2025-05-30', 'Tech Institute', 135),

    (6, 'Healthcare Innovations LLC', 'Work', 'Medical Researcher', '2023-02-01', NULL, 'Medical Research Center', 136),
    (6, 'Art Institute', 'High School', 'Art Intern', '2019-09-01', '2022-05-30', 'Art High School', 137),
    (6, 'Medical University', 'University', 'Medical Student', '2020-09-01', '2024-05-30', 'Medical University', 138),

    (7, 'Design Studio Creations', 'Work', 'Graphic Designer', '2022-06-01', NULL, 'Design Studio', 139),
    (7, 'Art Institute', 'High School', 'Art Intern', '2020-09-01', '2023-05-30', 'Art High School', 140),
    (7, 'Art University', 'University', 'Graphic Design Student', '2021-08-01', '2025-05-30', 'Art University', 141),

    (8, 'Travel Adventure Agency', 'Work', 'Travel Consultant', '2023-06-01', NULL, 'Adventure Tours', 142),
    (8, 'Tech High School', 'High School', 'Junior', '2021-09-01', '2024-05-30', 'Tech High School', 143),
    (8, 'Adventure University', 'University', 'Travel Management Student', '2022-09-01', '2026-05-30', 'Adventure University', 144),

    (9, 'GreenTech Solutions', 'Work', 'Junior Developer', '2021-06-01', NULL, 'GreenTech City', 145),
    (9, 'Eco High School', 'High School', 'Senior', '2019-09-01', '2022-05-30', 'Eco High School', 146),
    (9, 'Tech University', 'University', 'Computer Science Student', '2020-09-01', '2024-05-30', 'Tech University', 147),

    (10, 'Financial Services Corporation', 'Work', 'Economist', '2024-06-01', NULL, 'Finance Corp', 148),
    (10, 'Economics Institute', 'University', 'Economics Student', '2020-09-01', '2024-05-30', 'Economics Institute', 149),
    (10, 'City High School', 'High School', 'Junior', '2018-09-01', '2021-05-30', 'City High School', 150),

    (11, 'Digital Marketing Experts', 'Work', 'Digital Marketing Specialist', '2021-06-01', NULL, 'Marketing Hub', 151),
    (11, 'Yet Another High School', 'High School', 'Senior', '2021-09-01', '2024-05-30', 'Yet Another High School', 152),
    (11, 'Marketing University', 'University', 'Marketing Student', '2022-06-01', '2026-05-30', 'Marketing University', 153),

    (12, 'BioHealth Research Institute', 'Work', 'Research Scientist', '2024-06-01', NULL, 'BioHealth Institute', 154),
    (12, 'Bio University', 'University', 'Biology Student', '2019-09-01', '2023-05-30', 'Bio University', 155),
    (12, 'Another High School', 'High School', 'Junior', '2018-09-01', '2021-05-30', 'Another High School', 156),

    (13, 'Global Consulting Group', 'Work', 'Management Consultant', '2022-06-01', NULL, 'Consulting Hub', 157),
    (13, 'Another High School', 'High School', 'Senior', '2019-09-01', '2022-05-30', 'Another High School', 158),
    (13, 'Business University', 'University', 'Business Student', '2021-06-01', '2025-05-30', 'Business University', 159),

    (14, 'Energy Solutions Corporation', 'Work', 'Energy Analyst', '2023-06-01', NULL, 'Energy Solutions', 160),
    (14, 'Energy High School', 'High School', 'Junior', '2021-09-01', '2024-05-30', 'Energy High School', 161),
    (14, 'Eco University', 'University', 'Environmental Science Student', '2022-09-01', '2026-05-30', 'Eco University', 162),

    (15, 'Advanced Technologies Ltd.', 'Work', 'Lead Engineer', '2024-06-01', NULL, 'Tech Hub', 163),
    (15, 'Engineering Institute', 'University', 'Engineering Student', '2021-08-01', '2025-05-30', 'Engineering Institute', 164),
    (15, 'Tech High School', 'High School', 'Senior', '2019-09-01', '2022-05-30', 'Tech High School', 165),

    (16, 'Artistic Designs Studio', 'Work', 'Art Director', '2023-06-01', NULL, 'Artistic Designs', 166),
    (16, 'Art High School', 'High School', 'Junior', '2021-09-01', '2024-05-30', 'Art High School', 167),
    (16, 'Art University', 'University', 'Graphic Design Student', '2022-06-01', '2026-05-30', 'Art University', 168),

    (17, 'Global Pharmaceuticals Inc.', 'Work', 'Pharmaceutical Researcher', '2021-06-01', NULL, 'Pharma Research Center', 169),
    (17, 'Pharma Institute', 'University', 'Pharmaceutical Student', '2020-09-01', '2024-05-30', 'Pharma Institute', 170),
    (17, 'Another High School', 'High School', 'Senior', '2018-09-01', '2021-05-30', 'Another High School', 171),

    (18, 'Urban Planning Solutions', 'Work', 'Urban Planner', '2023-06-01', NULL, 'Urban Planning Center', 172),
    (18, 'Tech High School', 'High School', 'Junior', '2022-09-01', '2025-05-30', 'Tech High School', 173),
    (18, 'Urban Planning University', 'University', 'Urban Planning Student', '2022-09-01', '2026-05-30', 'Urban Planning University', 174),

    (19, 'Media Productions Network', 'Work', 'Media Producer', '2024-06-01', NULL, 'Media Productions', 175),
    (19, 'Media High School', 'High School', 'Senior', '2022-09-01', '2025-05-30', 'Media High School', 176),
    (19, 'Tech University', 'University', 'Media Studies Student', '2023-06-01', '2027-05-30', 'Tech University', 177),

    (20, 'Global Marketing Agency', 'Work', 'Marketing Manager', '2025-06-01', NULL, 'Marketing Hub', 178),
    (20, 'Yet Another High School', 'High School', 'Junior', '2023-09-01', '2026-05-30', 'Yet Another High School', 179),
    (20, 'Yet Another University', 'University', 'Marketing Student', '2025-06-01', '2029-05-30', 'Yet Another University', 180);

INSERT INTO requests (ruserid, suserid, date) VALUES
(1, 2, '2024-01-16 12:00:00'),
(3, 4, '2024-01-16 13:30:00'),
(2, 5, '2024-01-16 14:45:00'),
(4, 1, '2024-01-16 16:00:00'),
(5, 3, '2024-01-16 17:15:00');

INSERT INTO users (fname, lname, DOB, address, email, phone, bio, relationship, password) VALUES
('John', 'Doe', '1990-05-15', '123 Main St', 'john@example.com', 1234567890, 'Some bio text', 1, 'password1'),
    ('Jane', 'Smith', '1985-12-02', '456 Oak St', 'jane@example.com', 9876543210, 'Another bio text', 2, 'password2'),
    ('Alice', 'Johnson', '1998-08-20', '789 Pine St', 'alice@example.com', 5555555555, 'Yet another bio text', NULL, 'password3'),
    ('Michael', 'Clark', '1993-02-18', '234 Maple St', 'michael@example.com', 8888888888, 'Bio for Michael', NULL, 'password4'),
    ('Emily', 'Taylor', '1991-07-27', '567 Birch St', 'emily@example.com', 3333333333, 'Bio for Emily', NULL, 'password5'),
    ('David', 'Martin', '1987-09-08', '890 Cedar St', 'david@example.com', 4444444444, 'Bio for David', NULL, 'password6'),
    ('Sophia', 'Anderson', '1995-12-12', '123 Oak St', 'sophia@example.com', 7777777777, 'Bio for Sophia', NULL, 'password7'),
    ('Daniel', 'Miller', '1989-04-25', '456 Pine St', 'daniel@example.com', 6666666666, 'Bio for Daniel', NULL, 'password8'),
    ('Olivia', 'Brown', '1996-11-05', '789 Elm St', 'olivia@example.com', 2222222222, 'Bio for Olivia', NULL, 'password9'),
    ('Liam', 'Jones', '1992-03-30', '987 Birch St', 'liam@example.com', 9999999999, 'Bio for Liam', NULL, 'password10'),
    ('Ava', 'Garcia', '1994-06-14', '234 Oak St', 'ava@example.com', 6666666666, 'Bio for Ava', NULL, 'password11'),
    ('Ethan', 'Johnson', '1997-09-01', '567 Cedar St', 'ethan@example.com', 3333333333, 'Bio for Ethan', NULL, 'password12'),
    ('Emma', 'Smith', '1999-01-22', '890 Pine St', 'emma@example.com', 4444444444, 'Bio for Emma', NULL, 'password13'),
    ('Mia', 'Davis', '1990-08-17', '123 Birch St', 'mia@example.com', 5555555555, 'Bio for Mia', NULL, 'password14'),
    ('Noah', 'Taylor', '1988-12-05', '456 Elm St', 'noah@example.com', 7777777777, 'Bio for Noah', NULL, 'password15'),
    ('Isabella', 'Clark', '1993-05-28', '789 Oak St', 'isabella@example.com', 1111111111, 'Bio for Isabella', NULL, 'password16'),
    ('Aiden', 'Wilson', '1991-10-10', '987 Maple St', 'aiden@example.com', 2222222222, 'Bio for Aiden', NULL, 'password17'),
    ('Abigail', 'Moore', '1986-04-02', '234 Cedar St', 'abigail@example.com', 3333333333, 'Bio for Abigail', NULL, 'password18'),
    ('Logan', 'Thomas', '1995-02-14', '567 Maple St', 'logan@example.com', 4444444444, 'Bio for Logan', NULL, 'password19'),
    ('Ella', 'Hill', '1998-07-08', '890 Elm St', 'ella@example.com', 5555555555, 'Bio for Ella', NULL, 'password20');
-- Sample data for friends table
INSERT INTO friends (fuserid, suserid, date) VALUES
(1, 2, '2024-01-14 08:30:00');

INSERT INTO friends (fuserid, suserid, date) VALUES
(1, 6, '2024-01-14 08:30:00');

INSERT INTO friends (fuserid, suserid, date) VALUES
(1, 9, '2024-01-14 08:30:00');

INSERT INTO friends (fuserid, suserid, date) VALUES
(3, 4, '2024-01-14 10:45:00');

INSERT INTO friends (fuserid, suserid, date) VALUES
(5, 6, '2024-01-14 12:15:00');

INSERT INTO friends (fuserid, suserid, date) VALUES
(7, 8, '2024-01-14 14:00:00');

INSERT INTO friends (fuserid, suserid, date) VALUES
(9, 10, '2024-01-14 16:20:00');

-- Additional sample data

INSERT INTO friends (fuserid, suserid, date) VALUES
(2, 4, '2024-01-15 11:30:00');

INSERT INTO friends (fuserid, suserid, date) VALUES
(5, 8, '2024-01-15 13:45:00');

INSERT INTO friends (fuserid, suserid, date) VALUES
(6, 9, '2024-01-15 15:10:00');

INSERT INTO friends (fuserid, suserid, date) VALUES
(7, 10, '2024-01-15 17:30:00');

INSERT INTO posts (userid, content, likes, created) VALUES
(1, 'This is my first post!', 15, '2024-01-14 09:00:00');

INSERT INTO posts (userid, content, likes, created) VALUES
(2, 'Just sharing some thoughts...', 20, '2024-01-14 10:30:00');

INSERT INTO posts (userid, content, likes, created) VALUES
(2, 'Creating a new project', 10, '2024-01-20 10:30:00');

INSERT INTO posts (userid, content, likes, created) VALUES
(3, 'Hello world! #NewBeginnings', 10, '2024-01-14 12:45:00');

INSERT INTO posts (userid, content, likes, created) VALUES
(4, 'Feeling blessed today!', 25, '2024-01-14 14:20:00');

INSERT INTO posts (userid, content, likes, created) VALUES
(5, 'Exploring new horizons...', 18, '2024-01-14 16:10:00');

-- Additional sample data
INSERT INTO posts (userid, content, likes, created) VALUES
(6, 'Friday vibes! #WeekendIsHere', 30, '2024-01-15 08:45:00');

INSERT INTO posts (userid, content, likes, created) VALUES
(7, 'Natures beauty is unparalleled.', 22, '2024-01-15 11:00:00');

INSERT INTO posts (userid, content, likes, created) VALUES
(8, 'Coding marathon in progress...', 15, '2024-01-15 13:15:00');

INSERT INTO posts (userid, content, likes, created) VALUES
(9, 'Cooking up a storm in the kitchen!', 28, '2024-01-15 15:30:00');

INSERT INTO posts (userid, content, likes, created) VALUES
(10, 'Chasing dreams and making memories.', 35, '2024-01-15 17:00:00');

INSERT INTO comments (userid, postid, content, created) VALUES
(1, 1, 'Great first post!', '2024-01-14 09:15:00');

INSERT INTO comments (userid, postid, content, created) VALUES
(2, 1, 'Looking forward to more posts from you!', '2024-01-14 09:45:00');

INSERT INTO comments (userid, postid, content, created) VALUES
(3, 2, 'Interesting thoughts! Keep sharing.', '2024-01-14 10:45:00');

INSERT INTO comments (userid, postid, content, created) VALUES
(4, 3, 'Welcome to the platform! #NewBeginnings', '2024-01-14 13:00:00');

INSERT INTO comments (userid, postid, content, created) VALUES
(5, 4, 'Feeling blessed as well. Cheers!', '2024-01-14 14:45:00');

-- Additional sample data
INSERT INTO comments (userid, postid, content, created) VALUES
(6, 6, 'Enjoy your weekend!', '2024-01-15 09:30:00');

INSERT INTO comments (userid, postid, content, created) VALUES
(7, 7, 'Natures beauty is indeed incredible.', '2024-01-15 11:45:00');

INSERT INTO comments (userid, postid, content, created) VALUES
(8, 8, 'Good luck with your coding marathon!', '2024-01-15 13:30:00');

INSERT INTO comments (userid, postid, content, created) VALUES
(9, 9, 'That sounds delicious! Share the recipe?', '2024-01-15 16:00:00');

INSERT INTO comments (userid, postid, content, created) VALUES
(10, 10, 'Wishing you success on your journey!', '2024-01-15 17:30:00');