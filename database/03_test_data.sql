-- Test Data Script for FamilyTree Database

DECLARE @Grandpa INT, @Grandma INT, @Dad INT, @Mom INT, @Kid INT;

-- Insert Grandparents
INSERT INTO People (FullName, Gender, BirthDate, Notes) VALUES ('John Doe', 'M', '1950-01-01', 'Grandfather');
SET @Grandpa = SCOPE_IDENTITY();

INSERT INTO People (FullName, Gender, BirthDate, Notes) VALUES ('Jane Doe', 'F', '1952-02-02', 'Grandmother');
SET @Grandma = SCOPE_IDENTITY();

-- Insert Parents
INSERT INTO People (FullName, Gender, BirthDate, Notes) VALUES ('Bob Doe', 'M', '1980-03-03', 'Father');
SET @Dad = SCOPE_IDENTITY();

INSERT INTO People (FullName, Gender, BirthDate, Notes) VALUES ('Alice Smith', 'F', '1982-04-04', 'Mother');
SET @Mom = SCOPE_IDENTITY();

-- Insert Child
INSERT INTO People (FullName, Gender, BirthDate, Notes) VALUES ('Charlie Doe', 'M', '2010-05-05', 'Son');
SET @Kid = SCOPE_IDENTITY();

-- Relationships (Parentage)
-- Link Bob to Grandparents
INSERT INTO Relationships (PersonId, FatherId, MotherId) VALUES (@Dad, @Grandpa, @Grandma);

-- Link Charlie to Parents
INSERT INTO Relationships (PersonId, FatherId, MotherId) VALUES (@Kid, @Dad, @Mom);

-- Marriages
INSERT INTO Marriages (Person1Id, Person2Id, DateOfMarriage, Notes) VALUES (@Grandpa, @Grandma, '1975-06-01', '50+ years');
INSERT INTO Marriages (Person1Id, Person2Id, DateOfMarriage, Notes) VALUES (@Dad, @Mom, '2005-07-07', 'Happy couple');

-- Events
INSERT INTO Events (PersonId, EventType, EventDate, Description) VALUES (@Kid, 'Birth', '2010-05-05', 'Born at City Hospital');
INSERT INTO Events (PersonId, EventType, EventDate, Location, Description) VALUES (@Dad, 'Graduation', '2002-05-20', 'University', 'BS in CS');

PRINT 'Test data inserted successfully.';
