liness := []
labels := []
keys := []
Scale := 1.0
buildI := 1
uipause := 0
rotate := 1
mirror := 1

Menu, Tray, Icon, %A_WorkingDir%\misc\icon.png, , 1

#singleinstance,force
setbatchlines,-1
settitlematchmode,2

#include shinsoverlayclass.ahk
#Include vision.ahk
#Include builds.ahk

if (!WinExist("Zero-K")) {
    msgbox % "Please launch a Zero-K window and press OK to reload"
    reload
}
WinActivate, Zero-K

overlay := new ShinsOverlayClass("Zero-K")

settimer,draw,10

makesquare(mousex,mousey,offsetx,offsety,sizex,sizey,scale,key1,key2,rotate,mirror,index){
	
	
	if (rotate==2){
		temp:=offsetx
		offsetx:=-offsety
		offsety:=temp
		
		temp:=sizex
		sizex:=sizey
		sizey:=temp
	}
	if (rotate==3){
		offsetx:=-offsetx
		offsety:=-offsety
	}
	if (rotate==4){
		temp:=offsetx
		offsetx:=offsety
		offsety:=-temp
		
		temp:=sizex
		sizex:=sizey
		sizey:=temp
	}
	
	if (mirror==2){
		offsetx:=-offsetx
	}
	if (mirror==3){
		offsety:=-offsety
	}
	
	
	
	defaultscale:=9
	
	w:=scale*defaultscale*sizex
	h:=scale*defaultscale*sizey

	x:=mousex-w/2 + offsetx*scale*defaultscale
	y:=mousey-h/2 + offsety*scale*defaultscale
	
	outlines := []
	
	borderline := [0x9900FF00,3]
	
	outlines.Push([[x,y,x+w,y],borderline])
	outlines.Push([[x,y,x,y+h],borderline])
	outlines.Push([[x,y+h,x+w,y+h],borderline])
	outlines.Push([[x+w,y,x+w,y+h],borderline])
	
	
	borderline := [0x6600FF00,1]
	
	i := 0
	Loop, %sizex%{
		i++
		outlines.Push([[x+w*i/sizex,y,x+w*i/sizex,y+h],borderline])
		outlines.Push([[x,y+h*i/linecounts,x+w,y+h*i/linecounts],borderline])
	}
	i := 0
	Loop, %sizey%{
		i++
		outlines.Push([[x,y+h*i/sizey,x+w,y+h*i/sizey],borderline])
	}
	
	name := key1 . "-" . key2 . " (" . index-1 . ")"
	outlabel := [name,x+w/2-15,y+h/2-15]
	
	outkeys := [x+w/2,y+h/2,key1,key2]
	
	
	out := [outlines,outlabel,outkeys]
	
	return out
}

draw:
    if (overlay.BeginDraw() && uipause!=1) {
		if (GetKeyState("LShift")){
			keys.RemoveAt(1,keys.Length())
			
			overlay.GetMousePos(x,y)
			
			for i, k in builds[buildI]{
				if(i==1){
					name1 := "(" . buildI-1 . "/" . builds.Length()-1 . ") " . k
					name2 := ((rotate-1)?"angle" . (rotate-1)*90:"")  . ((mirror==2)?" x-mirrored":((mirror==3)?" y-mirrored":""))
					overlay.DrawText(name1,A_ScreenWidth/2,100,40,0xFF00FF00,fontName	:="Arial",extraOptions:="aLeft")
					overlay.DrawText(name2,A_ScreenWidth/2,150,20,0xFF00FF00,fontName	:="Arial",extraOptions:="aLeft")
				}
				else{
					square := makesquare(x,y,k[1],k[2],k[3],k[4],Scale,k[5],k[6],rotate,mirror,i)
					for i, k in square[1]{
						liness.Push(k)
					}
					labels.Push(square[2])
					keys.Push(square[3])
				}
			}
			
			for i, k in liness
        {	
		
            overlay.DrawLine(liness[i][1][1],liness[i][1][2],liness[i][1][3],	liness[i][1][4],0x40000000, liness[i][2][2]+2)
            overlay.DrawLine(liness[i][1][1],liness[i][1][2],liness[i][1][3],	liness[i][1][4],liness[i][2][1], liness[i][2][2])
			}
			
			for i, k in labels
			{
            overlay.DrawText(k[1],k[2],k[3],18,0xCC00FF00,fontName:="Arial",	extraOptions:="aLeft")
			}
			
			
			liness.RemoveAt(1,liness.Length())
			labels.RemoveAt(1,labels.Length())
		}
		overlay.EndDraw()
	}
return

#IfWinActive Zero-K

    +*WheelDown::
        scale:=scale/1.1
    return
	
    +*WheelUp::
        scale:=scale*1.1
    return
	
    +WheelDown::
        buildI:=buildI-1
		if (buildI<=1){
			buildI:=1
		}
    return
	
    +WheelUp::
        buildI:=buildI+1
		len:=builds.Length()
		if (buildI>=len){
			buildI:=len
		}
    return
	
	~+LButton::
		BlockInput, On
		if (buildI!=1){
			
			Sleep, 60
			
			overlay.GetMousePos(x,y)
			MouseGetPos, realx, realy
			
			CoordMode "Mouse", "Window"
			uipause := 1
			
			Sleep, 20
			
			for i, k in keys
			{	
				Send {LShift down}
				Sleep, 30
				key1:=k[3]
				StringLower, key1, key1
				key2:=k[4]
				StringLower, key2, key2
				
				MouseMove, k[1]+realx-x, k[2]+realy-y
				

				Send +{%key1%}
				Sleep, 30
				Send +{%key2%}
				Sleep, 30
				Send +{LButton}
				Sleep, 30
				if (GetKeyState("LShift", "P")==1){
					send {Esc}
					Sleep, 30
				}
			}
			MouseMove, realx, realy
			uipause := 0
		}
		BlockInput, Off
	return
	
	+LAlt::
		
		Send ^{WheelUp 15}
		Sleep, 50
		Send {WheelUp 40}
		Sleep, 50
		
		stepscount:=18
		scalestep:=(Scale-1)/stepscount
		Loop, %stepscount%{
			Scale:=Scale-scalestep
			Send {WheelDown}
			Sleep, 30
		}
		Scale:=1
	return
	
	+R::
        rotate:=rotate+1
		if (rotate>=5){
			rotate:=1
		}
	return
	
	+T::
        mirror:=mirror+1
		if (mirror>=4){
			mirror:=1
		}
	return
	
	+Esc::
        buildI:=1
		rotate:=1
		mirror:=1
	return

	

#If