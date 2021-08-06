Import "tlayoutgadget.bmx"

Function GadgetFromString:Object[]( str:String )
	Local ch:String
	Local token:String
	
	Local gadgets:TList = New TList ' Oh I wish TStack<TLayoutGadget> didn't crash
	Local gadgetId:String
	Local gadgetType:String
	Local gadgetProp:TList = New TList
	Local lastGadget:TLayoutGadget
	
	Local gadgetDepth:TList = New TList ' Again, TStack please
	
	Local inParam:Int
	Local inString:Int
	
	Local extractedKey:String
	Local extractedValue:String
	
	For Local i:Int = 0 Until str.Length
		If str[i] < 32 Then Continue ' Skip junk
		ch = Chr(str[i])
		
		If ch = "~q" Then inString = Not inString
		
		If inString Then
			If ch <> "~q" Then token:+ch
			Continue
		ElseIf inParam Then
			If ch = ")" Then
				' This creates the gadget
				inParam:-1
				If token Then
					extractedValue = token
					gadgetProp.AddLast( extractedKey + "=" + extractedValue )
				EndIf
				token = Null
				
				gadgetType = "TLayout" + gadgetType
				Local id:TTypeId = TTypeId.ForName( gadgetType )
				If Not id Then ' Fallback
					gadgetType = "TLayout" + TLayoutGadget.FALLBACK_GADGET
					id = TTypeId.ForName( gadgetType )
				EndIf
				lastGadget = TLayoutGadget( id.NewObject() )
				lastGadget.Id = gadgetId
				
				SetGadgetProperties( lastGadget, gadgetProp.ToArray(), gadgetType )
				token = Null
				gadgetProp.Clear()
				
				If gadgetDepth.Count() > 0 Then
					TLayoutGadget( gadgetDepth.Last() ).AddGadget( lastGadget )
				Else
					gadgets.AddLast( lastGadget )
				EndIf
			ElseIf ch = ","
				extractedValue = token
				token = Null
				gadgetProp.AddLast( extractedKey + "=" + extractedValue )
			ElseIf ch = "="
				extractedKey = token.Trim()
				token = Null
			Else
				If ch <> "~q" Then
					If ch = " " Then
						If token.Length > 0 Then token:+ch
					Else
						token:+ch
					EndIf
				EndIf
			EndIf
		Else
			If ch = "(" Then
				inParam:+1
				gadgetId = token
				token = Null
			ElseIf ch = "#"
				gadgetType = token
				token = Null
			ElseIf ch = "{"
				gadgetDepth.AddLast( lastGadget )
			ElseIf ch = "}"
				gadgetDepth.RemoveLast()
			Else
				If ch <> " " And ch <> "~q" Then token:+ch
			EndIf
		EndIf
	Next
	
	Return gadgets.ToArray()
EndFunction