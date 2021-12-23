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
	Private objSqlite2 As clsSqlite2
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Private btnAdd As Button
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("Layout1")
	If objSqlite2.IsInitialized = False Then
		objSqlite2.Initialize(Me, "dbHandler2")
	End If
	Activity.Title = "Sqlite 2"
End Sub

Sub Activity_Resume	
	objSqlite2.checkDbExistOne
	objSqlite2.checkDbExistTwo
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub dbHandler2(map2 As Map) 'ignore
	If map2.IsInitialized = False Then
		Return
	End If
	If map2.ContainsKey("issuccess") = False Then
		ToastMessageShow(map2.Get("errmsg"), True)
		Return
	End If
	Dim task2 As String = map2.Get("task")
	Select task2
		Case "checkdb1"
			ToastMessageShow(map2.Get("msg"), False)
		Case "checkdb2"
			ToastMessageShow(map2.Get("msg"), False)
		Case "batchinsert1"
			ToastMessageShow(map2.Get("msg"), False)
		Case "batchinsert2"
			ToastMessageShow(map2.Get("msg"), False)
	End Select
End Sub

Private Sub btnAdd_Click
	objSqlite2.insertSQL
	objSqlite2.insertSQLC
End Sub