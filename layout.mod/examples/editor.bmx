SuperStrict

Framework magna.layout
Import brl.eventqueue
Import maxgui.drivers
Import maxgui.proxygadgets
Import brl.standardio
Import brl.max2d
Import brl.glmax2d
Import brl.timerdefault
Import brl.timer

Global window:TGadget = CreateWindow( "MagnaLib Layout Editor", 0, 0, 640, 720, Desktop(), ..
	WINDOW_CENTER | WINDOW_CLIENTCOORDS | WINDOW_TITLEBAR | WINDOW_RESIZABLE | WINDOW_STATUS )

Global splitter:TSplitter = CreateSplitter( 0, 0, ClientWidth(window), ClientHeight(window), window )
SetGadgetLayout( splitter,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED,EDGE_ALIGNED )
SetSplitterOrientation( splitter, SPLIT_HORIZONTAL )
SetSplitterPosition( splitter, ClientHeight(window) / 2 )

Global splitterText:TGadget =  SplitterPanel(splitter,SPLITPANEL_MAIN)
Global splitterPreview:TGadget =  SplitterPanel(splitter,SPLITPANEL_SIDEPANE)

Global textarea:TGadget = CreateTextArea( 0, 0, ClientWidth(splitterText), ClientHeight(splitterText), splitterText )
SetGadgetLayout( textarea, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
SetGadgetText( textarea, """
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
""")

Global canvas:TGadget=CreateCanvas(0,0,ClientWidth( splitterPreview ),ClientHeight( splitterPreview ),splitterPreview)
SetGadgetLayout( canvas, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )

Global myLayout:TLayoutGadget[] = GadgetFromString( GadgetText( textarea ) )

ActivateGadget( textarea )

Global updateTimer:TTimer = CreateTimer( 10 )
Global updateCountdown:Int

Global genTime:Int
Global drawTime:Int

While WaitEvent()
	Select EventID()
		Case EVENT_TIMERTICK
			updateCountdown:-1
			If updateCountdown = 0 Then
				genTime = MilliSecs()
				SetStatusText( window, "Generating layout from script..." )
				myLayout = GadgetFromString( GadgetText( textarea ) )
				genTime = MilliSecs() - genTime
				UpdateStatus()
				RedrawGadget( splitterPreview )
			EndIf
			
		Case EVENT_GADGETPAINT
			SetGraphics( CanvasGraphics(canvas) )
			SetViewport( 0, 0, ClientWidth( canvas ), ClientHeight( canvas ) )
			Cls()
			
			drawTime = MilliSecs()
			
			' Draw the base containers and its children
			Local posX:Int
			For Local g:TLayoutGadget = EachIn myLayout
				g.SetPosition( posX, 0 )
				g.SetSize( ClientWidth( canvas ) / myLayout.Length, ClientHeight( canvas ) )
				DrawGenericGadgetItem( g )
				posX:+g.GetOuterSize().x
			Next
			
			drawTime = MilliSecs() - drawTime
			
			UpdateStatus()
			Flip(0)

		Case EVENT_MOUSEMOVE
			'Print "MOVE!"

		Case EVENT_GADGETACTION
			Select EventSource()
				Case textarea updateCountdown = 10
			EndSelect
			
		Case EVENT_WINDOWCLOSE
			FreeGadget( canvas )
			End

		Case EVENT_APPTERMINATE
			End
	EndSelect
Wend
End

Function UpdateStatus()
	SetStatusText( window, "Layout generated in " + genTime + "ms~t~tDraw in " + drawTime + "ms " )
EndFunction

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
		SetViewport( g.GetInnerPosition().x, g.GetInnerPosition().y, g.GetInnerSize().x, g.GetInnerSize().y )
		SetAlpha( 1 )
		SetColor( 255, 255, 255 )
		DrawText( g.GetText(), ..
			g.GetPosition.x + g.GetSize.x / 2 - TextWidth( g.GetText() ) / 2,..
			g.GetPosition.y + g.GetSize.y / 2 - TextHeight( g.GetText() ) / 2 )
		SetViewport( 0, 0, ClientWidth( canvas ), ClientHeight( canvas ) )
	EndIf
	
	' Draw any potential children of this gadget
	For Local cg:TLayoutGadget = EachIn g
		DrawGenericGadgetItem( cg )
	Next
EndFunction