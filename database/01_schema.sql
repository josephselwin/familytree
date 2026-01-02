-- Create People Table
CREATE TABLE People (
    PersonId INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')), -- 'M', 'F'
    BirthDate DATE NOT NULL,
    DeathDate DATE,
    Notes NVARCHAR(MAX),
    CONSTRAINT CK_People_DeathDate CHECK (DeathDate >= BirthDate)
);

-- Create Relationships Table (Parentage)
CREATE TABLE Relationships (
    PersonId INT NOT NULL,
    FatherId INT,
    MotherId INT,
    PRIMARY KEY (PersonId),
    FOREIGN KEY (PersonId) REFERENCES People(PersonId),
    FOREIGN KEY (FatherId) REFERENCES People(PersonId),
    FOREIGN KEY (MotherId) REFERENCES People(PersonId),
    CONSTRAINT CK_Relationships_NoSelfParent CHECK (PersonId <> FatherId AND PersonId <> MotherId),
    CONSTRAINT CK_Relationships_DifferentParents CHECK (FatherId <> MotherId)
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
    FOREIGN KEY (Person2Id) REFERENCES People(PersonId),
    CONSTRAINT CK_Marriages_CanonicalOrder CHECK (Person1Id < Person2Id),
    CONSTRAINT CK_Marriages_DivorceDate CHECK (DateOfDivorce >= DateOfMarriage)
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
