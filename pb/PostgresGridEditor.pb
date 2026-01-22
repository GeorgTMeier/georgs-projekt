; PureBasic PostgreSQL Grid Editor
; Ein Programm zum Bearbeiten von PostgreSQL-Datenbanken in einem Grid

EnableExplicit

; Globale Variablen
Global dbConnection.i = 0
Global gridTable.s = ""
Global gridPrimaryKey.s = "id"
Global gridColumns.s = ""
Global gridData.s = ""
Global gridColumnCount.i = 0

; Fenster und Gadgets
Enumeration
  #WindowMain
  #GridData
  #ButtonConnect
  #ButtonRefresh
  #ButtonAdd
  #ButtonDelete
  #ButtonSave
  #TextConnection
  #TextTable
  #StringTable
  #TextStatus
EndEnumeration

; Verbindungsdialog
Enumeration
  #WindowConnect
  #StringHost
  #StringPort
  #StringDatabase
  #StringUser
  #StringPassword
  #ButtonConnectOK
  #ButtonConnectCancel
  #TextHost
  #TextPort
  #TextDatabase
  #TextUser
  #TextPassword
EndEnumeration

; PostgreSQL-Verbindung herstellen
Procedure ConnectToDatabase(host.s, port.s, database.s, user.s, password.s)
  Protected connectionString.s
  
  ; Alte Verbindung schließen, falls vorhanden
  If dbConnection
    CloseDatabase(dbConnection)
    dbConnection = 0
  EndIf
  
  ; PostgreSQL-Bibliothek verwenden
  UsePostgreSQLDatabase()
  
  ; PostgreSQL-Verbindungsstring erstellen (für DatabaseName Parameter)
  connectionString = "host=" + host + " port=" + port + " dbname=" + database
  
  ; Verbindung herstellen (PureBasic Syntax: OpenDatabase(#Database, DatabaseName$, User$, Password$, Type))
  dbConnection = OpenDatabase(#PB_Any, connectionString, user, password, #PB_Database_PostgreSQL)
  
  If dbConnection
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

; Verbindungsdialog anzeigen
Procedure ShowConnectionDialog()
  Protected host.s = "127.0.0.1"
  Protected port.s = "5432"
  Protected database.s = ""
  Protected user.s = ""
  Protected password.s = ""
  Protected event.i
  Protected quit.i = #False
  Protected result.i = #False
  
  If OpenWindow(#WindowConnect, 100, 100, 400, 250, "PostgreSQL Verbindung", #PB_Window_SystemMenu | #PB_Window_TitleBar)
    TextGadget(#TextHost, 20, 20, 100, 20, "Host:")
    StringGadget(#StringHost, 130, 18, 250, 22, host)
    
    TextGadget(#TextPort, 20, 50, 100, 20, "Port:")
    StringGadget(#StringPort, 130, 48, 250, 22, port)
    
    TextGadget(#TextDatabase, 20, 80, 100, 20, "Datenbank:")
    StringGadget(#StringDatabase, 130, 78, 250, 22, database)
    
    TextGadget(#TextUser, 20, 110, 100, 20, "Benutzer:")
    StringGadget(#StringUser, 130, 108, 250, 22, user)
    
    TextGadget(#TextPassword, 20, 140, 100, 20, "Passwort:")
    StringGadget(#StringPassword, 130, 138, 250, 22, password, #PB_String_Password)
    
    ButtonGadget(#ButtonConnectOK, 200, 180, 80, 30, "Verbinden")
    ButtonGadget(#ButtonConnectCancel, 290, 180, 80, 30, "Abbrechen")
    
    Repeat
      event = WaitWindowEvent()
      
      Select event
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #ButtonConnectOK
              host = GetGadgetText(#StringHost)
              port = GetGadgetText(#StringPort)
              database = GetGadgetText(#StringDatabase)
              user = GetGadgetText(#StringUser)
              password = GetGadgetText(#StringPassword)
              
              If host <> "" And database <> "" And user <> ""
                If ConnectToDatabase(host, port, database, user, password)
                  result = #True
                  quit = #True
                Else
                  MessageRequester("Fehler", "Verbindung zur Datenbank fehlgeschlagen!" + #CRLF$ + DatabaseError())
                EndIf
              Else
                MessageRequester("Fehler", "Bitte füllen Sie alle Felder aus!")
              EndIf
              
            Case #ButtonConnectCancel
              quit = #True
          EndSelect
          
        Case #PB_Event_CloseWindow
          quit = #True
      EndSelect
    Until quit
    
    CloseWindow(#WindowConnect)
  EndIf
  
  ProcedureReturn result
EndProcedure

; Tabellennamen aus Datenbank laden
Procedure LoadTables()
  Protected query.s
  Protected result.i
  Protected tableName.s
  Protected count.i = 0
  
  If dbConnection = 0
    ProcedureReturn
  EndIf
  
  ; Tabellennamen aus PostgreSQL abfragen
  query = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;"
  
  If DatabaseQuery(dbConnection, query)
    ClearGadgetItems(#StringTable)
    
    While NextDatabaseRow(dbConnection)
      tableName = GetDatabaseString(dbConnection, 0)
      AddGadgetItem(#StringTable, -1, tableName)
      count + 1
    Wend
    
    FinishDatabaseQuery(dbConnection)
    
    If count > 0
      SetGadgetState(#StringTable, 0)
      gridTable = GetGadgetText(#StringTable)
    EndIf
  EndIf
EndProcedure

; Spaltennamen aus Tabelle laden
Procedure LoadColumns()
  Protected query.s
  Protected columnName.s
  Protected columnType.s
  Protected i.i
  Protected columnCount.i = 0
  Protected firstColumn.i = #True
  Protected existingColumns.i
  
  If dbConnection = 0 Or gridTable = ""
    ProcedureReturn
  EndIf
  
  ; Spalteninformationen abfragen
  query = "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = '" + gridTable + "' ORDER BY ordinal_position;"
  
  If DatabaseQuery(dbConnection, query)
    ; Grid leeren
    ClearGadgetItems(#GridData)
    
    ; Alle vorhandenen Spalten entfernen (außer der ersten)
    ; Wir zählen rückwärts, um Indizes nicht zu verschieben
    existingColumns = gridColumnCount
    While existingColumns > 1
      RemoveGadgetColumn(#GridData, existingColumns - 1)
      existingColumns - 1
    Wend
    
    ; Spaltenüberschriften setzen
    gridColumns = ""
    columnCount = 0
    
    While NextDatabaseRow(dbConnection)
      columnName = GetDatabaseString(dbConnection, 0)
      columnType = GetDatabaseString(dbConnection, 1)
      
      If firstColumn
        ; Erste Spalte setzen
        SetGadgetText(#GridData, columnName)
        gridColumns = columnName
        gridPrimaryKey = columnName  ; Erste Spalte als Primary Key annehmen
        firstColumn = #False
      Else
        ; Weitere Spalten hinzufügen
        AddGadgetColumn(#GridData, columnCount, columnName, 150)
        gridColumns + "|" + columnName
      EndIf
      
      columnCount + 1
    Wend
    
    ; Globale Spaltenanzahl speichern
    gridColumnCount = columnCount
    
    FinishDatabaseQuery(dbConnection)
  EndIf
EndProcedure

; Daten aus Tabelle laden
Procedure LoadData()
  Protected query.s
  Protected row.s = ""
  Protected i.i
  Protected columnCount.i
  Protected value.s
  
  If dbConnection = 0 Or gridTable = ""
    ProcedureReturn
  EndIf
  
  ; Daten abfragen
  query = "SELECT * FROM " + gridTable + " ORDER BY " + gridPrimaryKey + " LIMIT 1000;"
  
  If DatabaseQuery(dbConnection, query)
    ClearGadgetItems(#GridData)
    
    ; Spaltenüberschriften setzen
    SetGadgetText(#GridData, gridColumns)
    
    ; Spaltenanzahl aus globaler Variable verwenden
    columnCount = gridColumnCount
    
    ; Datenzeilen hinzufügen
    While NextDatabaseRow(dbConnection)
      row = ""
      
      For i = 0 To columnCount - 1
        value = GetDatabaseString(dbConnection, i)
        
        If row = ""
          row = value
        Else
          row + "|" + value
        EndIf
      Next
      
      AddGadgetItem(#GridData, -1, row)
    Wend
    
    FinishDatabaseQuery(dbConnection)
    
    SetGadgetText(#TextStatus, "Geladen: " + Str(CountGadgetItems(#GridData)) + " Zeilen")
  Else
    SetGadgetText(#TextStatus, "Fehler: " + DatabaseError())
  EndIf
EndProcedure

; Zeile speichern (UPDATE oder INSERT)
Procedure SaveRow(rowIndex.i)
  Protected query.s
  Protected columnNames.s
  Protected columnValues.s
  Protected updateSet.s = ""
  Protected insertColumns.s = ""
  Protected insertValues.s = ""
  Protected i.i
  Protected columnCount.i
  Protected columnName.s
  Protected cellValue.s
  Protected primaryKeyValue.s
  Protected isNewRow.i = #False
  
  If dbConnection = 0 Or gridTable = "" Or rowIndex < 0
    ProcedureReturn #False
  EndIf
  
  columnCount = gridColumnCount
  
  If columnCount = 0
    ProcedureReturn #False
  EndIf
  
  ; Primary Key Wert holen (erste Spalte)
  primaryKeyValue = GetGadgetItemText(#GridData, rowIndex, 0)
  
  ; Wenn Primary Key leer ist, handelt es sich um eine neue Zeile
  If primaryKeyValue = ""
    isNewRow = #True
  EndIf
  
  ; Spaltennamen aus gridColumns extrahieren
  Protected columns.s = gridColumns
  
  If isNewRow
    ; INSERT-Query zusammenbauen
    query = "INSERT INTO " + gridTable + " ("
    
    ; Alle Spalten durchgehen
    For i = 0 To columnCount - 1
      columnName = StringField(columns, i + 1, "|")
      cellValue = GetGadgetItemText(#GridData, rowIndex, i)
      
      ; Leere Werte überspringen (könnte auto-increment sein)
      If cellValue = "" And i = 0
        Continue
      EndIf
      
      ; SQL-Escape für Strings
      cellValue = ReplaceString(cellValue, "'", "''")
      
      If insertColumns <> ""
        insertColumns + ", "
        insertValues + ", "
      EndIf
      
      insertColumns + columnName
      insertValues + "'" + cellValue + "'"
    Next
    
    query + insertColumns + ") VALUES (" + insertValues + ");"
  Else
    ; UPDATE-Query zusammenbauen
    query = "UPDATE " + gridTable + " SET "
    
    ; Alle Spalten außer der ersten (Primary Key) aktualisieren
    For i = 1 To columnCount - 1
      columnName = StringField(columns, i + 1, "|")
      cellValue = GetGadgetItemText(#GridData, rowIndex, i)
      
      ; SQL-Escape für Strings
      cellValue = ReplaceString(cellValue, "'", "''")
      
      If updateSet <> ""
        updateSet + ", "
      EndIf
      
      updateSet + columnName + " = '" + cellValue + "'"
    Next
    
    query + updateSet + " WHERE " + gridPrimaryKey + " = '" + primaryKeyValue + "';"
  EndIf
  
  ; Query ausführen
  If DatabaseUpdate(dbConnection, query)
    ProcedureReturn #True
  Else
    MessageRequester("Fehler", "Speichern fehlgeschlagen: " + DatabaseError())
    ProcedureReturn #False
  EndIf
EndProcedure

; Neue Zeile hinzufügen (INSERT)
Procedure AddNewRow()
  Protected query.s
  Protected columnNames.s
  Protected columnValues.s
  Protected i.i
  Protected columnCount.i
  Protected columnName.s
  Protected newRow.s = ""
  
  If dbConnection = 0 Or gridTable = ""
    ProcedureReturn
  EndIf
  
  columnCount = gridColumnCount
  
  If columnCount = 0
    ProcedureReturn
  EndIf
  
  ; Neue leere Zeile im Grid hinzufügen
  For i = 0 To columnCount - 1
    If newRow = ""
      newRow = ""
    Else
      newRow + "|"
    EndIf
  Next
  
  AddGadgetItem(#GridData, -1, newRow)
  
  ; Zeile markieren zum Bearbeiten
  SetGadgetState(#GridData, CountGadgetItems(#GridData) - 1)
EndProcedure

; Zeile löschen (DELETE)
Procedure DeleteRow(rowIndex.i)
  Protected query.s
  Protected primaryKeyValue.s
  Protected result.i
  
  If dbConnection = 0 Or gridTable = "" Or rowIndex < 0
    ProcedureReturn #False
  EndIf
  
  ; Primary Key Wert holen
  primaryKeyValue = GetGadgetItemText(#GridData, rowIndex, 0)
  
  If primaryKeyValue = ""
    MessageRequester("Fehler", "Keine gültige Zeile zum Löschen!")
    ProcedureReturn #False
  EndIf
  
  ; Bestätigung
  result = MessageRequester("Löschen", "Möchten Sie diese Zeile wirklich löschen?", #PB_MessageRequester_YesNo | #PB_MessageRequester_Warning)
  
  If result = #PB_MessageRequester_Yes
    ; DELETE-Query
    query = "DELETE FROM " + gridTable + " WHERE " + gridPrimaryKey + " = '" + primaryKeyValue + "';"
    
    If DatabaseUpdate(dbConnection, query)
      ; Zeile aus Grid entfernen
      RemoveGadgetItem(#GridData, rowIndex)
      SetGadgetText(#TextStatus, "Zeile gelöscht")
      ProcedureReturn #True
    Else
      MessageRequester("Fehler", "Löschen fehlgeschlagen: " + DatabaseError())
      ProcedureReturn #False
    EndIf
  EndIf
  
  ProcedureReturn #False
EndProcedure

; Hauptfenster erstellen
Procedure CreateMainWindow()
  If OpenWindow(#WindowMain, 0, 0, 1000, 700, "PostgreSQL Grid Editor", #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget)
    ; Verbindungs-Button
    ButtonGadget(#ButtonConnect, 10, 10, 100, 30, "Verbinden")
    
    ; Tabellenauswahl
    TextGadget(#TextTable, 120, 15, 60, 20, "Tabelle:")
    ComboBoxGadget(#StringTable, 185, 12, 200, 22)
    
    ; Buttons
    ButtonGadget(#ButtonRefresh, 400, 10, 80, 30, "Aktualisieren")
    ButtonGadget(#ButtonAdd, 490, 10, 80, 30, "Neu")
    ButtonGadget(#ButtonDelete, 580, 10, 80, 30, "Löschen")
    ButtonGadget(#ButtonSave, 670, 10, 80, 30, "Speichern")
    
    ; Status-Text
    TextGadget(#TextStatus, 10, 50, 980, 20, "Nicht verbunden")
    
    ; Grid
    ListIconGadget(#GridData, 10, 75, 980, 615, "", 200, #PB_ListIcon_GridLines | #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
    
    ; Grid editierbar machen
  ;  SetGadgetAttribute(#GridData, #PB_ListIcon_Editable, #True)
  EndIf
EndProcedure

; Hauptprogramm
Procedure Main()
  Protected event.i
  Protected quit.i = #False
  Protected selectedRow.i
  Protected tableChanged.i = #False
  
  ; Datenbank-Initialisierung
  If InitDatabase() = 0
    MessageRequester("Fehler", "Datenbank-Bibliothek konnte nicht initialisiert werden!")
    End
  EndIf
  
  ; PostgreSQL-Bibliothek initialisieren
  UsePostgreSQLDatabase()
  
  ; Hauptfenster erstellen
  CreateMainWindow()
  
  ; Verbindungsdialog anzeigen
  If ShowConnectionDialog() = #False
    End
  EndIf
  
  ; Tabellen laden
  LoadTables()
  
  ; Event-Schleife
  Repeat
    event = WaitWindowEvent()
    
    Select event
      Case #PB_Event_Gadget
        Select EventGadget()
          Case #ButtonConnect
            If dbConnection
              CloseDatabase(dbConnection)
              dbConnection = 0
            EndIf
            
            If ShowConnectionDialog()
              LoadTables()
              If gridTable <> ""
                LoadColumns()
                LoadData()
              EndIf
            EndIf
            
          Case #StringTable
            If EventType() = #PB_EventType_Change
              gridTable = GetGadgetText(#StringTable)
              If gridTable <> ""
                LoadColumns()
                LoadData()
              EndIf
            EndIf
            
          Case #ButtonRefresh
            If gridTable <> ""
              LoadData()
            EndIf
            
          Case #ButtonAdd
            AddNewRow()
            
          Case #ButtonDelete
            selectedRow = GetGadgetState(#GridData)
            If selectedRow >= 0
              DeleteRow(selectedRow)
            Else
              MessageRequester("Hinweis", "Bitte wählen Sie eine Zeile aus!")
            EndIf
            
          Case #ButtonSave
            selectedRow = GetGadgetState(#GridData)
            If selectedRow >= 0
              If SaveRow(selectedRow)
                SetGadgetText(#TextStatus, "Zeile gespeichert")
                LoadData()  ; Daten neu laden
              EndIf
            Else
              MessageRequester("Hinweis", "Bitte wählen Sie eine Zeile aus!")
            EndIf
            
          Case #GridData
            ; Doppelklick oder Enter zum Bearbeiten
            If EventType() = #PB_EventType_LeftDoubleClick
              ; Grid ist bereits editierbar
            EndIf
        EndSelect
        
      Case #PB_Event_CloseWindow
        quit = #True
    EndSelect
  Until quit
  
  ; Aufräumen
  If dbConnection
    CloseDatabase(dbConnection)
  EndIf
EndProcedure

; Programm starten
Main()

; IDE Options = PureBasic 6.21 (Windows - x86)
; CursorPosition = 471
; FirstLine = 467
; Folding = --
; EnableXP
; DPIAware