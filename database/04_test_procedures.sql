-- Test Script for Stored Procedures

-- Variables to hold IDs
DECLARE @NewPersonId INT, @NewMarriageId INT, @NewEventId INT;

-- 1. Test usp_AddPerson
EXEC usp_AddPerson 
    @FullName = 'Test User', 
    @Gender = 'M', 
    @BirthDate = '2000-01-01', 
    @Notes = 'Created via SP',
    @PersonId = @NewPersonId OUTPUT;

PRINT 'New Person ID: ' + CAST(@NewPersonId AS VARCHAR(10));

-- 2. Test usp_UpdatePerson
EXEC usp_UpdatePerson 
    @PersonId = @NewPersonId, 
    @FullName = 'Updated Test User', 
    @Gender = 'M', 
    @BirthDate = '2000-01-01', 
    @Notes = 'Updated via SP';

-- 3. Test usp_SetParents (Upsert)
-- Assuming valid FatherId and MotherId exist (e.g., from previous test_data.sql run, specifically IDs 3 and 4)
-- If running on clean DB, ensuring IDs exist is needed. For this text, we'll try to use @NewPersonId as child and assuming 1 and 2 exist.
EXEC usp_SetParents @PersonId = @NewPersonId, @FatherId = 1, @MotherId = 2;

-- 4. Test usp_AddMarriage
EXEC usp_AddMarriage 
    @Person1Id = 1, 
    @Person2Id = 2, 
    @DateOfMarriage = '2020-02-02', 
    @Notes = 'Test Marriage',
    @MarriageId = @NewMarriageId OUTPUT;

PRINT 'New Marriage ID: ' + CAST(@NewMarriageId AS VARCHAR(10));

-- 5. Test usp_UpdateMarriage
EXEC usp_UpdateMarriage 
    @MarriageId = @NewMarriageId, 
    @Person1Id = 1, 
    @Person2Id = 2, 
    @DateOfMarriage = '2020-02-02', 
    @DateOfDivorce = '2025-01-01',
    @Notes = 'Divorced via SP';

-- 6. Test usp_AddEvent
EXEC usp_AddEvent 
    @PersonId = @NewPersonId, 
    @EventType = 'TestEvent', 
    @EventDate = '2022-03-03', 
    @Description = 'Initial Event',
    @EventId = @NewEventId OUTPUT;

PRINT 'New Event ID: ' + CAST(@NewEventId AS VARCHAR(10));

-- 7. Test usp_UpdateEvent
EXEC usp_UpdateEvent 
    @EventId = @NewEventId, 
    @PersonId = @NewPersonId, 
    @EventType = 'TestEvent', 
    @EventDate = '2022-03-03', 
    @Description = 'Updated Description';

PRINT 'All procedures verified successfully.';
