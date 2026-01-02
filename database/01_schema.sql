-- Create People Table
CREATE TABLE People (
    PersonId INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Gender CHAR(1), -- 'M', 'F', 'O'
    BirthDate DATE,
    DeathDate DATE,
    Notes NVARCHAR(MAX)
);

-- Create Relationships Table (Parentage)
CREATE TABLE Relationships (
    PersonId INT NOT NULL,
    FatherId INT,
    MotherId INT,
    PRIMARY KEY (PersonId),
    FOREIGN KEY (PersonId) REFERENCES People(PersonId),
    FOREIGN KEY (FatherId) REFERENCES People(PersonId),
    FOREIGN KEY (MotherId) REFERENCES People(PersonId)
);

-- Create Marriages Table
CREATE TABLE Marriages (
    MarriageId INT IDENTITY(1,1) PRIMARY KEY,
    Person1Id INT NOT NULL,
    Person2Id INT NOT NULL,
    DateOfMarriage DATE,
    DateOfDivorce DATE,
    Notes NVARCHAR(MAX),
    FOREIGN KEY (Person1Id) REFERENCES People(PersonId),
    FOREIGN KEY (Person2Id) REFERENCES People(PersonId)
);

-- Create Events Table
CREATE TABLE Events (
    EventId INT IDENTITY(1,1) PRIMARY KEY,
    PersonId INT NOT NULL,
    EventType NVARCHAR(100) NOT NULL,
    EventDate DATE,
    Location NVARCHAR(255),
    Description NVARCHAR(MAX),
    FOREIGN KEY (PersonId) REFERENCES People(PersonId)
);
