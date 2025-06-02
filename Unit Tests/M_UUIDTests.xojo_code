#tag Class
Protected Class M_UUIDTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub ExtractDateTimeTest()
		  var now as DateTime = DateTime.Now
		  var actual as DateTime = M_UUID.ExtractDateTime( M_UUID.GenerateV7( false ) )
		  var diff as DateInterval = actual - now
		  
		  Assert.AreEqual 0, diff.Days
		  Assert.AreEqual 0, diff.Hours
		  Assert.AreEqual 0, diff.Minutes
		  Assert.AreEqual 0, diff.Seconds
		  
		  actual = M_UUID.ExtractDateTime( "01973223-59cd-73b1-9f91-917fb8af9cc7", new TimeZone( 0 ) )
		  Assert.AreEqual "2025-06-02 19:34", actual.SQLDateTime.Left( 16 )
		  
		  Assert.IsNil M_UUID.ExtractDateTime( M_UUID.GenerateV4() )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ExtractVersionTest()
		  Assert.AreEqual 4, M_UUID.ExtractVersion( "01973223-59cd-43b1-9f91-917fb8af9cc7" )
		  Assert.AreEqual 7, M_UUID.ExtractVersion( "01973223-59cd-73b1-9f91-917fb8af9cc7" )
		  
		  Assert.AreEqual 4, M_UUID.ExtractVersion( M_UUID.GenerateV4() )
		  Assert.AreEqual 7, M_UUID.ExtractVersion( M_UUID.GenerateV7() )
		  
		  Assert.AreEqual -1, M_UUID.ExtractVersion( "01973223-59cd-03b1-9f91-917fb8af9cc7" )
		  
		End Sub
	#tag EndMethod

	#tag DelegateDeclaration, Flags = &h21
		Private Delegate Function GenerateDelegate(withHyphens As Boolean) As String
	#tag EndDelegateDeclaration

	#tag Method, Flags = &h0
		Sub GenerateV4Test()
		  var uuid as string
		  
		  uuid = M_UUID.GenerateV4()
		  
		  Assert.IsTrue uuid.Contains( "-" )
		  ValidatePattern uuid
		  ValidateVersion uuid, 4
		  
		  uuid = M_UUID.GenerateV4( false )
		  
		  Assert.IsFalse uuid.Contains( "-" )
		  ValidatePattern uuid
		  ValidateVersion uuid, 4
		  
		  ValidateUniqueness AddressOf M_UUID.GenerateV4
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GenerateV7Test()
		  var uuid as string
		  
		  uuid = M_UUID.GenerateV7()
		  
		  Assert.IsTrue uuid.Contains( "-" )
		  ValidatePattern uuid
		  ValidateVersion uuid, 7
		  uuid = M_UUID.GenerateV7()
		  
		  uuid = M_UUID.GenerateV7( false )
		  
		  Assert.IsFalse uuid.Contains( "-" )
		  ValidatePattern uuid
		  ValidateVersion uuid, 7
		  
		  ValidateUniqueness AddressOf M_UUID.GenerateV7
		  
		  //
		  // The first few bytes will represent seconds so we can count on them
		  // being the same
		  //
		  
		  uuid = M_UUID.GenerateV7
		  var uuid2 as string = M_UUID.GenerateV7
		  
		  Assert.AreSame uuid.Left( 6 ), uuid2.Left( 6 )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IsValidTest()
		  Assert.IsTrue M_UUID.IsValid( M_UUID.GenerateV4 )
		  Assert.IsTrue M_UUID.IsValid( M_UUID.GenerateV7 )
		  Assert.IsTrue M_UUID.IsValid( "00000000-0000-4000-8000-000000000000" )
		  Assert.IsTrue M_UUID.IsValid( "00000000000040008000000000000000" )
		  
		  Assert.IsFalse M_UUID.IsValid( "00000000-0000-0000-0000-000000000000" )
		  Assert.IsFalse M_UUID.IsValid( "00000000-0000-4000-0000-000000000000" )
		  Assert.IsFalse M_UUID.IsValid( "00000000-0000-4000-5000-000000000000" )
		  Assert.IsFalse M_UUID.IsValid( "00000000-0000-A000-8000-000000000000" )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ValidatePattern(uuid As String)
		  var validator as new RegEx
		  validator.SearchPattern = "^[[:xdigit:]]{8}(-[[:xdigit:]]{4}){3}-[[:xdigit:]]{12}$|^[[:xdigit:]]{32}$"
		  
		  Assert.IsNotNil validator.Search( uuid ), uuid
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ValidateUniqueness(d As GenerateDelegate)
		  var uuids as new Set
		  
		  for i as integer = 1 to 10000
		    var uuid as string = d.Invoke( false )
		    
		    if uuids.HasMember( uuid ) then
		      Assert.Fail "UUID not unique: " + uuid
		      return
		    end if
		    
		    uuids.Add uuid
		  next
		  
		  Assert.Pass
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ValidateVersion(uuid As String, expectedVersion As Integer)
		  var stripped as string = uuid.ReplaceAll( "-", "" )
		  var mb as MemoryBlock = DecodeHex( stripped )
		  
		  var shifted as integer
		  
		  shifted = Bitwise.ShiftRight( mb.Byte( 6 ), 4 )
		  Assert.AreEqual expectedVersion, shifted
		  
		  shifted = Bitwise.ShiftRight( mb.Byte( 8 ), 6 )
		  Assert.AreEqual CType( &b10, Integer ), shifted
		  
		End Sub
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="Duration"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="FailedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IncludeGroup"
			Visible=false
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsRunning"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="NotImplementedCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PassedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="RunTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SkippedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="StopTestOnFail"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
