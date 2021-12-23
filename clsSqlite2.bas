B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=11
@EndOfDesignText@
Sub Class_Globals
	Private callback As Object
	Private event As String
	Private m_salt As String
	Private m_start1 As Long
	Private m_start2 As Long
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(cb As Object, evt As String)
	callback = cb
	event = evt
	m_salt = "123321"
End Sub

Public Sub checkDbExistOne()
	If File.Exists(File.DirDefaultExternal, "") = False Then
		File.MakeDir(File.DirDefaultExternal, "")
	End If
	If File.Exists(File.DirDefaultExternal, "JsonColumn1.db") Then
		' Return True
		CallSubDelayed2(callback, event, CreateMap("issuccess": True, "task": "checkdb1", "msg": "db1 is checked"))
		Return
	End If
	Dim SQL As SQL
	Try
		SQL.Initialize(File.DirDefaultExternal, "JsonColumn1.db", True)
		SQL.Close
		Dim iscreated As Boolean = createtableOne
		If iscreated Then
			CallSubDelayed2(callback, event, CreateMap("issuccess": True, "task": "checkdb1", "msg": "db1 is created"))
		Else
			CallSubDelayed2(callback, event, CreateMap("issuccess": False, "task": "checkdb1", "msg": "db1 is created but table is not created"))
		End If
	Catch
		LogColor("checkdbexistone: " & LastException.Message, Colors.Red)
		CallSubDelayed2(callback, event, CreateMap("issuccess": False, "task": "checkdb1", "errmsg": LastException.Message))
	End Try
End Sub

Public Sub checkDbExistTwo()
	If File.Exists(File.DirDefaultExternal, "") = False Then
		File.MakeDir(File.DirDefaultExternal, "")
	End If
	If File.Exists(File.DirDefaultExternal, "JsonColumn2.db") Then
		' Return True
		CallSubDelayed2(callback, event, CreateMap("issuccess": True, "task": "checkdb2", "msg": "db2 is checked"))
		Return
	End If
	Dim SQLC As SQLCipher
	Try
		SQLC.Initialize(File.DirDefaultExternal, "JsonColumn2.db", True, m_salt, "")
		SQLC.Close
		Dim iscreated As Boolean = createtableTwo
		If iscreated Then
			CallSubDelayed2(callback, event, CreateMap("issuccess": True, "task": "checkdb2", "msg": "db2 is created"))
		Else
			CallSubDelayed2(callback, event, CreateMap("issuccess": False, "task": "checkdb2", "msg": "db2 is created but table is not created"))
		End If
	Catch
		LogColor("checkdbexisttwo: " & LastException.Message, Colors.Red)
		CallSubDelayed2(callback, event, CreateMap("issuccess": False, "task": "checkdb2", "errmsg": LastException.Message))
	End Try
End Sub

Private Sub createtableOne() As Boolean
	Dim sqlstr As String = "CREATE TABLE IF NOT EXISTS tblFacility(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT)"
	Dim sql As SQL
	Try
		sql.Initialize(File.DirDefaultExternal, "JsonColumn1.db", False)
		sql.ExecNonQuery(sqlstr)
		sql.close
		Return True
	Catch
		LogColor("createtableone: " & LastException.Message, Colors.Red)
		Return False
	End Try
End Sub

Private Sub createtableTwo() As Boolean
	Dim sqlstr As String = "CREATE TABLE IF NOT EXISTS tblFacility(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT)"
	Dim sqlc As SQLCipher
	Try
		sqlc.Initialize(File.DirDefaultExternal, "JsonColumn2.db", False, m_salt, "")
		sqlc.ExecNonQuery(sqlstr)
		sqlc.close
		Return True
	Catch
		LogColor("createtabletwo: " & LastException.Message, Colors.Red)
		Return False
	End Try
End Sub

Public Sub insertSQL()
	Wait For (getResource) Complete(lst As List)
	LogColor("insertSQL(1) row count: " & lst.Size, Colors.Magenta)
	Dim sql As SQL
	sql.Initialize(File.DirDefaultExternal, "JsonColumn1.db", False)
	m_start1 = DateTime.Now
	LogColor($"insertSQL(1) starting... (${m_start1})"$, Colors.Magenta)
	For Each entry As Map In lst
		Dim jGen As JSONGenerator
		Try
			jGen.Initialize(entry)
			Dim entryJson As String = jGen.ToString.Replace("<li>", ";").Replace("<br>","")
			sql.AddNonQueryToBatch("INSERT INTO tblFacility(`data`) VALUES (?)", Array As String(entryJson))
		Catch
			Log(LastException)
			Continue
		End Try
	Next
	sql.ExecNonQueryBatch("SQL")
End Sub

Public Sub insertSQLC()
	Wait For (getResource) Complete(lst As List)
	LogColor("insertSQLC(2) row count: " & lst.Size, Colors.Magenta)
	Dim sqlc As SQLCipher
	sqlc.Initialize(File.DirDefaultExternal, "JsonColumn2.db", False, m_salt, "")
	m_start2 = DateTime.Now	
	LogColor($"insertSQLC(2) starting... (${m_start2})"$, Colors.Magenta)
	For Each entry As Map In lst
		Dim jGen As JSONGenerator
		Try
			jGen.Initialize(entry)
			Dim entryJson As String = jGen.ToString.Replace("<li>", ";").Replace("<br>","")
			sqlc.AddNonQueryToBatch("INSERT INTO tblFacility(`data`) VALUES (?)", Array As String(entryJson))
		Catch
			LogColor(LastException, Colors.Red)
			Continue
		End Try
	Next
	sqlc.ExecNonQueryBatch("SQLC")
End Sub

Private Sub SQL_NonQueryComplete(Success As Boolean)
	Dim end1 As Long = DateTime.Now
	LogColor("End Time(1): " & end1, Colors.Blue)
	Dim delta1 As Long = (end1 - m_start1)
	LogColor("Time elapsed(1): " & delta1 & " milli-sec", Colors.Blue)
	CallSubDelayed2(callback, event, CreateMap("issuccess": Success, "task": "batchinsert1", "msg": "records(1) are inserted"))	
End Sub

Private Sub SQLC_NonQueryComplete(Success As Boolean)
	Dim end2 As Long = DateTime.Now
	LogColor("End Time(2): " & end2, Colors.Blue)
	Dim delta2 As Long = (end2 - m_start2) 
	LogColor("Time elapsed(2): " & delta2 & " milli-sec", Colors.Blue)
	CallSubDelayed2(callback, event, CreateMap("issuccess": Success, "task": "batchinsert2", "msg": "records(2) are inserted"))	
End Sub

Private Sub getResource() As ResumableSub
	Dim uri As String = "https://www.lcsd.gov.hk/datagovhk/facility/facility-bbqs.json"
	Dim job As HttpJob
	job.Initialize("get", Me)	
	job.Download(uri)
	job.GetRequest.Timeout = 60000
	Wait For (job) JobDone(j As HttpJob)
	If j.Success Then
		Dim jparser As JSONParser
		Try
			jparser.Initialize(j.GetString)
			Return jparser.NextArray
		Catch
			Log(LastException)
			Return Null
		End Try
	End If
	Return Null
End Sub