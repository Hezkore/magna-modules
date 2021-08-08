SuperStrict

Framework magna.layout
Import brl.standardio
Import brl.max2d
Import brl.glmax2d

Local myLayout:TLayoutGadget[] = GadgetFromString( """
#window (layout=stackVertical) {
	#toolbar (layout=wrapHorizontal) {
		button#open (text="open")
		button#save (text="save")
		button#saveAs (text="save as")
		(grow=1)
		button#search ()
	}
	#content (layout=stackHorizontal, grow=1) {
		(width=200) {
			//sidebar content here
		}
		(grow=1, colour=content, border=thin, padding=controlSpace) {
			text(value=$content)
		}
	}
	#actions (layout=stackHorizontal) {
		button#cancel (text="Cancel")
		(grow=1)
		button#okay (text="Okay")
	}
}
			
""" )

'myLayout.AddGadget( GadgetFromString( "b1#button (text=~qButton 1~q, size=64)" ) )
'myLayout.AddGadget( New TLayoutButton( ["id=b1", "text=Button 1", "size=64"] ) )

' Make example layout
' TLayout is the same as TLayoutContainer
rem
Local myLayout:TLayoutContainer = New TLayoutContainer( 320, 240, ELayoutStyle.StackVertical )
myLayout.AddGadget( New TLayoutContainer( "window", -1, 16, ELayoutStyle.StackHorizontal ) )
myLayout.LastGadget.AddGadget( New TLayoutContainer( "expand" ) )
myLayout.LastGadget.AddGadget( New TLayoutButton( "minimize", 16, -1, "_" ) )
myLayout.LastGadget.AddGadget( New TLayoutButton( "close", 16, -1, "x" ) )
myLayout.AddGadget( New TLayoutContainer( "toolbar", -1, 16, ELayoutStyle.WrapHorizontal ) )
myLayout.LastGadget.AddGadget( New TLayoutButton( "button1", 64, -1, "File" ) )
myLayout.LastGadget.AddGadget( New TLayoutButton( "button2", -1, -1, "Edit" ) )
myLayout.LastGadget.AddGadget( New TLayoutButton( "button3", 64, -1, "View" ) )
myLayout.LastGadget.AddGadget( New TLayoutButton( "button4", 64, -1, "Blah" ) )
myLayout.LastGadget.AddGadget( New TLayoutButton( "button5", 64, -1, "Help" ) )
myLayout.AddGadget( New TLayoutContainer( "main", ELayoutStyle.StackHorizontal ) )
myLayout.LastGadget.AddGadget( New TLayoutContainer( "empty", 96, -1 ) )
myLayout.LastGadget.AddGadget( New TLayoutButton( "area", -1, -1, "Some Area" ) )
myLayout.AddGadget( New TLayoutContainer( "buttonrow", -1, 24 ) )
myLayout.LastGadget.AddGadget( New TLayoutContainer( "expand" ) )
myLayout.LastGadget.AddGadget( New TLayoutButton( "apply", 64, -1, "Apply" ) )
myLayout.LastGadget.AddGadget( New TLayoutButton( "abort", 64, -1, "Abort" ) )
endrem

'Print( "myLayout has the following properties: " )
'Print( ", ".Join( myLayout.GetProperties() ) )

Graphics( 640, 480 )
While Not AppTerminate() And Not KeyDown(KEY_ESCAPE)
	Cls()
	
	' Resize with left mouse button
	If MouseDown( 1 ) Then
		myLayout[0].SetSize( ..
			MouseX() - myLayout[0].GetPosition().x, ..
			MouseY() - myLayout[0].GetPosition().y )
	EndIf
	
	' Move with right mouse button
	If MouseDown( 2 ) Then
		myLayout[0].SetPosition( MouseX(), MouseY() )
	EndIf
	
	' Draw the base containers and its children
	For Local g:TLayoutGadget = EachIn myLayout
		DrawGenericGadgetItem( g )
	Next
	
	Flip( 0 )
Wend

Function DrawGenericGadgetItem( g:TLayoutGadget )
	SetBlend( ALPHABLEND )
	
	' Area rectangle
	SetAlpha( 0.15 )
	Select g.GetTypeHash()
		' Cache "Panel".Hash() ULong for even better performance
		Case "Panel".Hash()
			SetColor( 166, 204, 255 )
		Default
			SetColor( 239, 201, 253 )
	EndSelect
	DrawRect( g.GetPosition.x, g.GetPosition.y, g.GetSize.x, g.GetSize.y )
	
	' Outline
	SetAlpha( 0.35 )
	DrawLine( g.GetPosition.x, g.GetPosition.y, g.GetPosition.x + g.GetSize.x, g.GetPosition.y, False )
	DrawLine( g.GetPosition.x + g.GetSize.x, g.GetPosition.y, g.GetPosition.x + g.GetSize.x, g.GetPosition.y + g.GetSize.y, False )
	DrawLine( g.GetPosition.x + g.GetSize.x, g.GetPosition.y + g.GetSize.y, g.GetPosition.x, g.GetPosition.y + g.GetSize.y, False )
	DrawLine( g.GetPosition.x, g.GetPosition.y + g.GetSize.y, g.GetPosition.x, g.GetPosition.y, False )
	
	' Text
	If g.GetText() Then
		SetAlpha( 1 )
		SetColor( 255, 255, 255 )
		DrawText( g.GetText(), ..
			g.GetPosition.x + g.GetSize.x / 2 - TextWidth( g.GetText() ) / 2,..
			g.GetPosition.y + g.GetSize.y / 2 - TextHeight( g.GetText() ) / 2 )
	EndIf
	
	' Draw any potential children of this gadget
	For Local cg:TLayoutGadget = EachIn g
		DrawGenericGadgetItem( cg )
	Next
EndFunction