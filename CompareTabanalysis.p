/*------------------------------------------------------------------------
    File        : DFParser.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : James Palmer / Consultingwerk Ltd.
    Created     : Mon Mar 12 15:56:57 GMT 2018
    Notes       :
  ----------------------------------------------------------------------*/

DEFINE VARIABLE File1 AS CHARACTER   NO-UNDO.
DEFINE VARIABLE File2 AS CHARACTER   NO-UNDO.

DEFINE TEMP-TABLE ttImport NO-UNDO
    FIELD TableName AS CHARACTER FORMAT 'x(30)'
    FIELD RecordCount AS CHARACTER
    INDEX xTab IS PRIMARY TableName.  

DEFINE TEMP-TABLE ttOld NO-UNDO
    FIELD TableName AS CHARACTER FORMAT 'x(30)'
    FIELD RecordCount AS INT64 FORMAT ">>>>>>>>>>>"
    INDEX xTab IS PRIMARY TableName. 

DEFINE TEMP-TABLE ttNew NO-UNDO
    FIELD TableName AS CHARACTER FORMAT 'x(30)'
    FIELD RecordCount AS INT64 FORMAT ">>>>>>>>>>>"
    INDEX xTab IS PRIMARY TableName. 

ASSIGN 
    File1 = "C:\DB\Old\SmartDB\SmartDB.tabana"
    File2 = "C:\DB\New\SmartDB\SmartDB.tabana".

 

INPUT from value(File1). 

REPEAT:
    CREATE ttImport. 
    IMPORT ttImport. 
END.

INPUT close. 

FOR EACH ttImport
    WHERE ttImport.TableName BEGINS 'PUB.'
    OR ttImport.TableName BEGINS '_':
    CREATE ttOld. 
    ASSIGN 
        ttOld.TableName = ttImport.TableName
        ttOld.RecordCount = int(ttImport.RecordCount).
END.

EMPTY TEMP-TABLE ttImport. 

INPUT from value(File2). 

REPEAT:
    CREATE ttImport. 
    IMPORT ttImport. 
END.

INPUT close. 

FOR EACH ttImport
    WHERE ttImport.TableName BEGINS 'PUB.'
    OR ttImport.TableName BEGINS '_':
    CREATE ttNew. 
    ASSIGN 
        ttNew.TableName = ttImport.TableName
        ttNew.RecordCount = int(ttImport.RecordCount).
END.

FOR EACH ttOld:
    FIND ttNew
        WHERE ttNew.TableName EQ ttOld.TableName NO-ERROR. 
    IF AVAILABLE ttNew AND ttNew.RecordCount NE ttOld.RecordCount THEN
        DISP 
            ttOld.TableName 
            ttOld.RecordCount 
            ttNew.RecordCount 
            ttOld.RecordCount - ttNew.RecordCount WITH 1 COL. 

    IF NOT AVAILABLE ttNew THEN
        DISP ttOld.TableName ttOld.RecordCount.
END.
