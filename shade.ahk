#NoEnv
#SingleInstance, Force
SetKeyDelay, 0

tb_siz := 30
dblclk_t := 200
IDs := []
OnExit("cleanup")

$WheelDown::
$WheelUp::
$LButton::
$MButton::
  hk := A_ThisHotKey
  hkn := LTrim(hk,"$")
  whl := InStr(hkn,"Wheel")  
  
  CoordMode, Mouse, Screen
  MouseGetPos, mX, mY, winID
  WinGetPos, wX, wY,,, ahk_id %winID%  

  dbl := (A_PriorHotkey==hk && A_TimeSincePriorHotkey<dblclk_t)

  if(mY-wY>tb_siz || (hkn=="LButton" && !dbl)) {
    if(whl) {
      Send {%hkn%}
    } else {
      btn := SubStr(hkn,1,1)
      MouseClick, % btn,,,,, D
      KeyWait, % hkn
      MouseClick, % btn,,,,, U
    }
    return
  }

  rollup(whl?hkn!="WheelUp":2)
  return

$^MButton::
  MouseGetPos,,, winID
  rollup()
  return

; t==0 roll up, t==1 roll down, t==2 toggle
rollup(t := 2) {  
  global IDs, winID

  if (t) {
    for i, e in IDs {
      if(InStr(e, winID)) { 
        t := StrSplit(e, "|")
        WinMove, % "ahk_id" t[1],,,,, % t[2]
        IDs.Delete(i)
        return
      }
    }
  }

  if (t!=1) {
    for i, e in IDs {
      if(InStr(e, winID)) { 
        return
      }
    }
    
    WinGet, pN, ProcessName, ahk_id %winID%
    if(InStr(pN, "Thunderbird")) {
      nh := 38
    } else {
      nh := 30
    }

    WinGetPos,,,, winH, ahk_id %winID%
    WinMove, ahk_id %winID%,,,,, %nh%
    t = %winID%|%winH%
    IDs.Push(t)
  }
}

cleanup() {
  global IDs
  for i, e in IDs {
    t := StrSplit(e, "|")
    WinMove, % "ahk_id" t[1],,,,, % t[2]
  }
  
  return 0
}
