#tag Class
Protected Class UUID7Generator
	#tag Method, Flags = &h21
		Private Sub Constructor()
		  db = new SQLiteDatabase
		  db.Connect
		  db.ExecuteSQL( kTrigger )
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function Get() As String
		  if instance = nil then instance = new UUID7Generator
		  Return instance.getNext
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function getNext() As String
		  var rs as RowSet = db.SelectSQL( "SELECT next FROM uuid7;" )
		  Return rs.Column( "next" ).StringValue
		End Function
	#tag EndMethod


	#tag Note, Name = License
		
		MIT License
		
		Copyright (c) 2025 Anthony G. Cyphers
		
		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:
		
		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.
		
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
	#tag EndNote

	#tag Note, Name = Source
		
		View modified from https://stackoverflow.com/a/79315986
	#tag EndNote


	#tag Property, Flags = &h21
		Private db As SQLiteDatabase
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared instance As UUID7Generator
	#tag EndProperty


	#tag Constant, Name = kTrigger, Type = String, Dynamic = False, Default = \"CREATE VIEW uuid7 AS\nWITH unixtime AS (\nSELECT CAST((STRFTIME(\'%s\') * 1000) + ((STRFTIME(\'%f\') * 1000) % 1000) AS INTEGER) AS time\n)\nSELECT PRINTF(\'%08x-%04x-%04x-%04x-%012x\'\x2C \n(select time from unixtime) >> 16\x2C\n(select time from unixtime) & 0xffff\x2C\nABS(RANDOM()) % 0x0fff + 0x7000\x2C\nABS(RANDOM()) % 0x3fff + 0x8000\x2C\nABS(RANDOM()) >> 16) AS next", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
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
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
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
