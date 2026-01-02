-- PEOPLE Procedures

CREATE PROCEDURE usp_AddPerson
    @FullName NVARCHAR(200),
    @Gender CHAR(1),
    @BirthDate DATE,
    @DeathDate DATE = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @PersonId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO People (FullName, Gender, BirthDate, DeathDate, Notes)
    VALUES (@FullName, @Gender, @BirthDate, @DeathDate, @Notes);
    
    SET @PersonId = SCOPE_IDENTITY();
END;
GO

CREATE PROCEDURE usp_UpdatePerson
    @PersonId INT,
    @FullName NVARCHAR(200),
    @Gender CHAR(1),
    @BirthDate DATE,
    @DeathDate DATE = NULL,
    @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE People
    SET FullName = @FullName,
        Gender = @Gender,
        BirthDate = @BirthDate,
        DeathDate = @DeathDate,
        Notes = @Notes
    WHERE PersonId = @PersonId;
END;
GO

-- RELATIONSHIPS Procedures (Parentage)

CREATE PROCEDURE usp_SetParents
    @PersonId INT,
    @FatherId INT,
    @MotherId INT
AS
BEGIN
    SET NOCOUNT ON;
    MERGE Into Relationships AS Target
    USING (SELECT @PersonId AS PersonId) AS Source
    ON (Target.PersonId = Source.PersonId)
    WHEN MATCHED THEN
        UPDATE SET FatherId = @FatherId, MotherId = @MotherId
    WHEN NOT MATCHED THEN
        INSERT (PersonId, FatherId, MotherId)
        VALUES (@PersonId, @FatherId, @MotherId);
END;
GO

-- MARRIAGES Procedures

CREATE PROCEDURE usp_AddMarriage
    @Person1Id INT,
    @Person2Id INT,
    @DateOfMarriage DATE,
    @DateOfDivorce DATE = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @MarriageId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Swap IDs to ensure Canonical Order (Person1Id < Person2Id)
    IF @Person1Id > @Person2Id
    BEGIN
        DECLARE @TempId INT = @Person1Id;
        SET @Person1Id = @Person2Id;
        SET @Person2Id = @TempId;
    END

    INSERT INTO Marriages (Person1Id, Person2Id, DateOfMarriage, DateOfDivorce, Notes)
    VALUES (@Person1Id, @Person2Id, @DateOfMarriage, @DateOfDivorce, @Notes);
    
    SET @MarriageId = SCOPE_IDENTITY();
END;
GO

CREATE PROCEDURE usp_UpdateMarriage
    @MarriageId INT,
    @Person1Id INT,
    @Person2Id INT,
    @DateOfMarriage DATE,
    @DateOfDivorce DATE = NULL,
    @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Swap IDs to ensure Canonical Order (Person1Id < Person2Id)
    IF @Person1Id > @Person2Id
    BEGIN
        DECLARE @TempId2 INT = @Person1Id;
        SET @Person1Id = @Person2Id;
        SET @Person2Id = @TempId2;
    END

    UPDATE Marriages
    SET Person1Id = @Person1Id,
        Person2Id = @Person2Id,
        DateOfMarriage = @DateOfMarriage,
        DateOfDivorce = @DateOfDivorce,
        Notes = @Notes
    WHERE MarriageId = @MarriageId;
END;
GO

-- EVENTS Procedures

CREATE PROCEDURE usp_AddEvent
    @PersonId INT,
    @EventType NVARCHAR(100),
    @EventDate DATE,
    @Location NVARCHAR(255) = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @EventId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Events (PersonId, EventType, EventDate, Location, Description)
    VALUES (@PersonId, @EventType, @EventDate, @Location, @Description);
    
    SET @EventId = SCOPE_IDENTITY();
END;
GO

CREATE PROCEDURE usp_UpdateEvent
    @EventId INT,
    @PersonId INT,
    @EventType NVARCHAR(100),
    @EventDate DATE,
    @Location NVARCHAR(255) = NULL,
    @Description NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Events
    SET PersonId = @PersonId,
        EventType = @EventType,
        EventDate = @EventDate,
        Location = @Location,
        Description = @Description
    WHERE EventId = @EventId;
END;
GO
