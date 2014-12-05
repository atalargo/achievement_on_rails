Feature: Achievements referential
In order that a website or application have an achievements system
A webapp which use this engine
Should obtains a referential achievements database
To progress in like a multi-root graph tree

    Scenario: Database structure is present
        Given the engine is loaded
        When I request the DB throw the Achievement class
            Or I request the DB throw the AchievementRelation class
        Then I have not an error

    Scenario: Database is empty when i launch the engine for the first time
        Given the engine is loaded
        When I request the DB to have all Achievements
            Or I request the DB to have all AchievementRelations
        Then I must have an empty result

    
