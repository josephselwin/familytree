-- Non-Clustered Indexes for FamilyTree Database Performance

-- Relationships (Optimize joins on parents)
CREATE NONCLUSTERED INDEX IX_Relationships_FatherId ON Relationships(FatherId);
CREATE NONCLUSTERED INDEX IX_Relationships_MotherId ON Relationships(MotherId);

-- Marriages (Optimize joins on spouses)
CREATE NONCLUSTERED INDEX IX_Marriages_Person1Id ON Marriages(Person1Id);
CREATE NONCLUSTERED INDEX IX_Marriages_Person2Id ON Marriages(Person2Id);

-- People (Optimize search and sorting)
CREATE NONCLUSTERED INDEX IX_People_FullName ON People(FullName);
CREATE NONCLUSTERED INDEX IX_People_BirthDate ON People(BirthDate);

-- Events (Optimize timeline retrieval)
CREATE NONCLUSTERED INDEX IX_Events_PersonId ON Events(PersonId);
CREATE NONCLUSTERED INDEX IX_Events_EventDate ON Events(EventDate);
