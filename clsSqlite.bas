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
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(cb As Object, evt As String)
	callback = cb
	event = evt
	m_salt = "123321"
End Sub

Public Sub checkDbExist()
	If File.Exists(File.DirDefaultExternal, "") = False Then
		File.MakeDir(File.DirDefaultExternal, "")
	End If
	If File.Exists(File.DirDefaultExternal, "JsonColumn.db") Then
		' Return True
		CallSubDelayed2(callback, event, CreateMap("issuccess": True, "task": "checkdb", "msg": "db is checked"))
		Return
	End If
	Dim SQLc As SQLCipher
	Try
		SQLc.Initialize(File.DirDefaultExternal, "JsonColumn.db", True, m_salt, "")
		SQLc.Close
		Dim iscreated As Boolean = createtable		
		If iscreated Then
			CallSubDelayed2(callback, event, CreateMap("issuccess": True, "task": "checkdb", "msg": "db is created"))
		Else
			CallSubDelayed2(callback, event, CreateMap("issuccess": False, "task": "checkdb", "msg": "db is created but table is not created"))
		End If
	Catch
		LogColor("checkdbexist: " & LastException.Message, Colors.Red)
		CallSubDelayed2(callback, event, CreateMap("issuccess": False, "task": "checkdb", "errmsg": LastException.Message))
	End Try
End Sub

Private Sub createtable() As Boolean
	Dim sqlstr As String = "CREATE TABLE IF NOT EXISTS tblUser(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT)"
	Dim sqlc As SQLCipher
	Try
		sqlc.Initialize(File.DirDefaultExternal, "JsonColumn.db", False, m_salt, "")
		sqlc.ExecNonQuery(sqlstr)
		sqlc.close		
		Return True	
	Catch
		LogColor("createtable: " & LastException.Message, Colors.Red)
		Return False
	End Try
End Sub

Public Sub updaterecord(n As String, ph As String)
	Dim sqlc As SQLCipher
	Dim sqlstr As String = "UPDATE tblUser SET phone = " & _
		"(SELECT json_set(tblUser.phone, '$.cell', ?) from tblUser)" & _
		"WHERE name= ?"
	sqlc.Initialize(File.DirDefaultExternal, "JsonColumn.db", False, m_salt, "")
	Try
		' android.database.sqlite.SQLiteException: no such function: json_set (code 1): , while compiling: 
		' UPDATE tblUser SET phone = (SELECT json_set(tblUser.phone, '$.cell', ?) from tblUser)WHERE name= ?
		sqlc.ExecNonQuery2(sqlstr, Array As String(ph, n))
		sqlc.Close
		CallSubDelayed2(callback, event, CreateMap("issuccess": True, "task": "updaterecord", "msg": "record is updated"))
	Catch
		LogColor("updaterecord: " & LastException.Message, Colors.Red)
		CallSubDelayed2(callback, event, CreateMap("issuccess": False, "task": "updaterecord", "errmsg": LastException.Message))
	End Try
End Sub

Public Sub insertrecord(n As String, m As Map) 
	Dim sqlc As SQLCipher
	Dim sqlstr As String = "INSERT INTO tblUser(name, phone) VALUES (?, json(?))"
	sqlc.Initialize(File.DirDefaultExternal, "JsonColumn.db", False, m_salt, "")
	Try
		' android.database.sqlite.SQLiteException: no such function: json (code 1): , while compiling: 
		' INSERT INTO tblUser(name, phone) VALUES (?, json(?))
		sqlc.ExecNonQuery2(sqlstr, Array As String(n, MapToJStr(m)))
		sqlc.Close
		CallSubDelayed2(callback, event, CreateMap("issuccess": True, "task": "insertrecord", "msg": "record is inserted"))
	Catch
		LogColor("insertrecord: " & LastException.Message, Colors.Red)
		CallSubDelayed2(callback, event, CreateMap("issuccess": False, "task": "insertrecord", "errmsg": LastException.Message))		
	End Try
End Sub

Public Sub selectrecord(pn As String)
	Dim sqlc As SQLCipher
	Dim sqlstr As String = "SELECT tblUser.name, tblUser.phone FROM tblUser WHERE json_extract(tblUser.phone, '$.cell') = ?"
	sqlc.Initialize(File.DirDefaultExternal, "JsonColumn.db", False, m_salt, "")
	Dim rs As ResultSet
	Try
		' android.database.sqlite.SQLiteException: no such function: json_extract (code 1): , while compiling: 
		' SELECT tblUser.name, tblUser.phone FROM tblUser WHERE json_extract(tblUser.phone, '$.cell') = ?
		rs = sqlc.ExecQuery2(sqlstr, Array As String(pn))
		Dim lst As List
		lst.Initialize
		Do While rs.NextRow
			lst.Add(CreateMap("name": rs.GetString("name")))
		Loop
		sqlc.Close
		CallSubDelayed2(callback, event, _ 
			CreateMap("issuccess": True, "task": "insertrecord", "msg": "record is selected", "list": lst))
	Catch
		LogColor("selectrecord: " & LastException.Message, Colors.Red)
		CallSubDelayed2(callback, event, CreateMap("issuccess": False, "task": "selectrecord", "errmsg": LastException.Message))
	End Try
End Sub

Private Sub MapToJStr(i_map As Map) As String
	Dim jgen As JSONGenerator
	Try
		jgen.Initialize(i_map)
		Return jgen.ToString
	Catch
		LogColor("MapToJStr: " & LastException.Message, Colors.Red)
		Return ""
	End Try	
End Sub