#tag Class
Protected Class TimingTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub GenerateV4InBulkTest()
		  TimeBulk AddressOf M_UUID.GenerateV4
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub GenerateV7InBulkTest()
		  TimeBulk AddressOf M_UUID.GenerateV7
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub TimeBulk(f As M_UUIDTests.GenerateDelegate)
		  var sw as new Stopwatch_MTC
		  
		  for i as integer = 1 to kCount
		    sw.Start
		    call f.Invoke( true )
		    sw.Stop
		  next
		  
		  var elapsed as double = sw.ElapsedSeconds
		  var avgus as double = elapsed / kCount * 1000000.0
		  
		  Assert.Message "Generating " + kCount.ToString( "#,##0" ) + " UUID's took " + elapsed.ToString( "#,##0.0" ) + " s"
		  Assert.Message "at an average of " + avgus.ToString( "#,##0.0" ) + " µs"
		  
		  Assert.Pass
		  
		End Sub
	#tag EndMethod


	#tag Constant, Name = kCount, Type = Double, Dynamic = False, Default = \"500000", Scope = Private
	#tag EndConstant


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
