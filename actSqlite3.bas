B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=11
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Private objSqlite3 As clsSqlite3
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Private btnAdd2 As Button
	Private btnAdd1 As Button
	Private btnDelete As Button
	Private btnVer1 As Button
	Private btnVer2 As Button
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	'Activity.LoadLayout("Layout1")
	Activity.LoadLayout("Layout2")
	If objSqlite3.IsInitialized = False Then
		objSqlite3.Initialize(Me, "dbHandler3")
	End If
	Activity.Title = "Sqlite 3"
End Sub

Sub Activity_Resume
	objSqlite3.checkDbExistOne
	objSqlite3.checkDbExistTwo
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub dbHandler3(map3 As Map) 'ignore
	If map3.IsInitialized = False Then
		Return
	End If
	If map3.ContainsKey("issuccess") = False Then
		ToastMessageShow(map3.Get("errmsg"), True)
		Return
	End If
	Dim task2 As String = map3.Get("task")
	Select task2
		Case "checkdb1"
			ToastMessageShow(map3.Get("msg"), False)
		Case "checkdb2"
			ToastMessageShow(map3.Get("msg"), False)
		Case "batchinsert1"
			ToastMessageShow(map3.Get("msg"), False)
		Case "batchinsert2"
			ToastMessageShow(map3.Get("msg"), False)
	End Select
End Sub

Private Sub btnAdd2_Click
	objSqlite3.insertSQLC
End Sub

Private Sub btnAdd1_Click
	objSqlite3.insertSQL
End Sub

Private Sub btnDelete_Click
	objSqlite3.deleteAll
End Sub

Private Sub btnVer2_Click
	Dim ver2 As String = objSqlite3.versionTwo
	MsgboxAsync("Sqlite Cipher version: " & ver2, "Version")
End Sub

Private Sub btnVer1_Click
	Dim ver1 As String = objSqlite3.versionOne
	MsgboxAsync("Sqlite version: " & ver1, "Version")
End Sub