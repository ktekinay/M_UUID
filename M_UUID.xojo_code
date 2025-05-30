#tag Module
Protected Module M_UUID
	#tag Method, Flags = &h1
		Protected Function GenerateV7() As String
		  #if not DebugBuild
		    #pragma BackgroundTasks false
		  #endif
		  #pragma BoundsChecking false
		  #pragma NilObjectChecking false
		  #pragma StackOverflowChecking false
		  
		  var uuid as new MemoryBlock( 16 )
		  uuid.LittleEndian = false
		  
		  var p as ptr = uuid
		  
		  var ms as UInt64
		  
		  #If TargetWindows
		    // --- Windows Implementation ---
		    // Uses GetSystemTimeAsFileTime to get time in FILETIME format
		    // FILETIME is 100-nanosecond intervals since Jan 1, 1601 UTC
		    
		    Declare Sub GetSystemTimeAsFileTime Lib "kernel32" (ByRef lpFileTime As FILETIME)
		    
		    Var ft As FILETIME
		    GetSystemTimeAsFileTime(ft)
		    
		    // Combine the two 32-bit parts into a 64-bit unsigned integer
		    // Note: Xojo's UInt64 handles this correctly.
		    Var fileTime64 As UInt64 = ft.dwHighDateTime
		    fileTime64 = fileTime64 * &h100000000 + ft.dwLowDateTime // Combine high and low parts
		    
		    // Constant for the difference between Jan 1, 1970 (Unix epoch)
		    // and Jan 1, 1601 (FILETIME epoch) in 100-nanosecond intervals.
		    // This is 11644473600 seconds * 10,000,000 (100ns per second)
		    Const EPOCH_DIFFERENCE_100NS As UInt64 = 116444736000000000
		    
		    // Subtract the epoch difference and convert to seconds
		    ms = (fileTime64 - EPOCH_DIFFERENCE_100NS) / (10 ^ 4) ' Divide to get milliseconds
		    
		  #ElseIf TargetMacOS or TargetIOS Or TargetLinux
		    // --- macOS and Linux (POSIX) Implementation ---
		    // Uses gettimeofday to get seconds and microseconds since Unix epoch
		    
		    Var tv As timeval
		    Var apiResult As Int32 // Stores the return value of gettimeofday
		    
		    #If TargetMacOS // macOS specific library
		      Declare Function gettimeofday Lib "libc.dylib" (ByRef tv As timeval, tz As Ptr) As Int32
		      apiResult = gettimeofday(tv, Nil) // Pass Nil for timezone argument (not usually needed)
		    #ElseIf TargetIOS // iOS specific library
		      Declare Function gettimeofday Lib "Foundation" (ByRef tv As timeval, tz As Ptr) As Int32
		      apiResult = gettimeofday(tv, Nil) // Pass Nil for timezone argument (not usually needed)
		    #ElseIf TargetLinux // Linux specific library (common for most distributions)
		      Declare Function gettimeofday Lib "libc.so.6" (ByRef tv As timeval, tz As Ptr) As Int32
		      apiResult = gettimeofday(tv, Nil) // Pass Nil for timezone argument
		    #EndIf
		    
		    If apiResult = 0 Then // Function call succeeded
		      ms = tv.tv_sec * 1000 + ( tv.tv_usec \ 1000 ) // Return milliseconds
		    End If
		    
		  #elseif TargetAndroid
		    Declare Function currentTimeMillis_Android Lib "Runtime" _
		    (className As String, methodName As String) As Int64
		    ms = currentTimeMillis_Android("java/lang/System", "currentTimeMillis")
		  #EndIf
		  
		  //
		  // If we get here, the above didn't work
		  //
		  if ms = 0 then ms = DateTime.Now.SecondsFrom1970 * 1000.0
		  
		  //
		  // Copy to the first 6 bytes
		  // 
		  const kShift2 as UInt64 = 256 * 256
		  
		  ms = ms * kShift2
		  uuid.UInt64Value( 0 ) = ms
		  
		  var mbRandom as MemoryBlock = Crypto.GenerateRandomBytes( 10 )
		  
		  uuid.CopyBytes mbRandom, 0, 10, 6
		  
		  //
		  // Set the seventh byte to the version
		  //
		  var value as byte = p.Byte( 6 )
		  value = value and CType( &b00001111, Byte ) // Turn off the first four bits
		  value = value or CType( &b01110000, Byte ) // Set to version 7
		  p.Byte( 6 ) = value
		  
		  //
		  // Adjust ninth byte
		  //
		  value = p.Byte( 8 )
		  value = value and CType( &b00111111, Byte ) // Turn off the first two bits
		  value = value or CType( &b10000000, Byte ) // Turn on the first bit
		  p.Byte( 8 ) = value
		  
		  var result as string = EncodeHex( uuid )
		  result = result.LeftBytes( 8 ) + "-" + result.MiddleBytes( 8, 4 ) + "-" + result.MiddleBytes( 12, 4 ) + "-" + result.MiddleBytes( 16, 4 ) + _
		  "-" + result.RightBytes( 12 )
		  
		  return result
		End Function
	#tag EndMethod


	#tag Structure, Name = FILETIME, Flags = &h21
		dwLowDateTime As UInt32
		dwHighDateTime As UInt32
	#tag EndStructure

	#tag Structure, Name = timeval, Flags = &h21
		tv_sec As Int64   // seconds (typically time_t, which is Int64 on 64-bit systems)
		tv_usec As Int32  // microseconds
	#tag EndStructure


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
End Module
#tag EndModule
