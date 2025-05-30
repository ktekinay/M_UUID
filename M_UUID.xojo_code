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
		  
		  var µs as UInt64
		  
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
		    µs = (fileTime64 - EPOCH_DIFFERENCE_100NS) \ 10 ' Divide to get microseconds
		    
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
		      µs = tv.tv_sec * 1000000 + tv.tv_usec // Return microseconds
		    End If
		    
		  #elseif TargetAndroid
		    static counter as UInt64
		    
		    Declare Function currentTimeMillis_Android Lib "Runtime" _
		    (className As String, methodName As String) As Int64
		    µs = currentTimeMillis_Android("java/lang/System", "currentTimeMillis") * 1000 + counter
		    
		    counter = ( counter + 1 ) mod 1000
		    
		  #EndIf
		  
		  //
		  // If we get here, the above didn't work
		  //
		  if µs = 0 then 
		    µs = DateTime.Now.SecondsFrom1970 * 1000000.0
		  end
		  
		  //
		  // Copy to the first 6 bytes
		  // 
		  const kShift2 as UInt64 = 256 * 256
		  const kThousand as UInt64 = 1000
		  
		  var ms as UInt64 = µs \ kThousand
		  
		  ms = ms * kShift2
		  uuid.UInt64Value( 0 ) = ms
		  
		  //
		  // Write the microseconds to the the 7th and 8th bytes
		  // noting that the value will not take more than the 12 bits allowed
		  //
		  var remainingµs as UInt16 = µs mod kThousand
		  
		  //
		  // We set the version here by flipping the first bits of the value,
		  // which works because we know the first byte will be 0
		  //
		  remainingµs = remainingµs or &b0111000000000000 //  Version 7
		  
		  uuid.UInt16Value( 6 ) = remainingµs
		  
		  const kRandomCount as integer = 8
		  
		  var mbRandom as MemoryBlock = Crypto.GenerateRandomBytes( kRandomCount )
		  
		  //
		  // Adjust the bits of the first byte (ultimately byte 9 of the UUID)
		  //
		  var p as ptr = mbRandom
		  
		  var value as byte = p.Byte( 0 )
		  value = value and CType( &b00111111, Byte ) // Turn off the first two bits
		  value = value or CType( &b10000000, Byte ) // Turn on the first bit
		  p.Byte( 0 ) = value
		  
		  uuid.CopyBytes mbRandom, 0, kRandomCount, 16 - kRandomCount
		  
		  var result as string = EncodeHex( uuid )
		  
		  result = result.LeftBytes( 8 ) + "-" + _
		  result.MiddleBytes( 8, 4 ) + "-" + _
		  result.MiddleBytes( 12, 4 ) + "-" + _
		  result.MiddleBytes( 16, 4 ) + "-" + _
		  result.RightBytes( 12 )
		  
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
