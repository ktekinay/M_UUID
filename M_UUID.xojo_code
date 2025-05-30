#tag Module
Protected Module M_UUID
	#tag Method, Flags = &h1, Description = 50756C6C7320746865206461746520616E642074696D652066726F6D2061205555494420762E373B2072657475726E73204E696C20666F72206F746865722076657273696F6E732E
		Protected Function ExtractDateTime(uuid As String) As DateTime
		  #if not DebugBuild
		    #pragma BackgroundTasks false
		  #endif
		  #pragma BoundsChecking false
		  #pragma NilObjectChecking false
		  #pragma StackOverflowChecking false
		  
		  if Version( uuid ) <> 7 then
		    return nil
		  end if
		  
		  uuid = uuid.ReplaceAllBytes( "-", "" )
		  
		  var mb as MemoryBlock = DecodeHex( uuid )
		  mb.LittleEndian = false
		  
		  const kShift2 as UInt64 = 256^2
		  
		  var ms as UInt64 = mb.UInt64Value( 0 ) \ kShift2
		  var secs as double = ms / 1000.0
		  
		  var dt as new DateTime( secs )
		  return dt
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 47656E657261746564205555494420762E34202872616E646F6D206279746573292E
		Protected Function GenerateV4() As String
		  #if not DebugBuild
		    #pragma BackgroundTasks false
		  #endif
		  #pragma BoundsChecking false
		  #pragma NilObjectChecking false
		  #pragma StackOverflowChecking false
		  
		  var uuid as MemoryBlock = Crypto.GenerateRandomBytes( 16 )
		  
		  var p as ptr = uuid
		  
		  var value as byte
		  
		  //
		  // Set the version in byte 7
		  //
		  value = p.Byte( 6 )
		  value = value and CType( &b00001111, Byte ) // Turn off first bits
		  value = value or CType( &b01000000, Byte ) // Set to 4
		  p.Byte( 6 ) = value
		  
		  //
		  // Set the first bit of byte 9
		  //
		  value = p.Byte( 8 )
		  value = value and CType( &b00111111, Byte ) // Turn off first bits
		  value = value or CType( &b10000000, Byte ) // Turn on first bit
		  p.Byte( 8 ) = value
		  
		  var result as string = EncodeHex( uuid )
		  
		  result = result.LeftBytes( 8 ) + "-" + _
		  result.MiddleBytes( 8, 4 ) + "-" + _
		  result.MiddleBytes( 12, 4 ) + "-" + _
		  result.MiddleBytes( 16, 4 ) + "-" + _
		  result.RightBytes( 12 )
		  
		  return result
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 47656E657261746573205555494420762E37202863757272656E74206461746520616E642074696D65206173206D6963726F7365636F6E647320706C75732072616E646F6D206279746573292E
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

	#tag Method, Flags = &h1, Description = 52657475726E7320547275652069662074686520555549442069732076616C69642E
		Protected Function IsValid(uuid As String) As Boolean
		  return Version( uuid ) <> kNotValid
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 52657475726E73207468652076657273696F6E206F6620612076616C696420555549442C206F72202D31206966206E6F742076616C69642E
		Protected Function Version(uuid As String) As Integer
		  #if not DebugBuild
		    #pragma BackgroundTasks false
		  #endif
		  #pragma BoundsChecking false
		  #pragma NilObjectChecking false
		  #pragma StackOverflowChecking false
		  
		  var validator as new RegEx
		  validator.SearchPattern = kValidatorPattern
		  
		  var match as RegExMatch = validator.Search( uuid )
		  
		  if match is nil then
		    return kNotValid
		  end if
		  
		  var version as integer = match.SubExpressionString( 1 ).ToInteger
		  return version
		  
		End Function
	#tag EndMethod


	#tag Constant, Name = kNotValid, Type = Double, Dynamic = False, Default = \"-1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kValidatorPattern, Type = String, Dynamic = False, Default = \"(\?x)\n\n\\A\n\n(\?|\n  [[:xdigit:]]{12}\n  ([12345678]) # version\n  [[:xdigit:]]{3}\n  [89AB] [[:xdigit:]]{15}\n  |\n  [[:xdigit:]]{8} - \n  [[:xdigit:]]{4} - \n  ([12345678]) # version\n  [[:xdigit:]]{3} - \n  [89AB][[:xdigit:]]{3} - \n  [[:xdigit:]]{12}\n)\n\n\\z", Scope = Private
	#tag EndConstant


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
