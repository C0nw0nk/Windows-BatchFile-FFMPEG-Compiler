@echo off & setLocal EnableDelayedExpansion
:: Copyright Conor McKnight
:: https://github.com/C0nw0nk/Windows-BatchFile-FFMPEG-Compiler
:: https://www.facebook.com/C0nw0nk
:: Automatically sets up dependancies and can compile FFMPEG for use to be portable to any folder on your pc
:: all you need is the batch script it will download the latest versions from their github pages
:: simple fast efficient easy to move and manage
::One file to rule them all,
::One file to find them,
::One file to bring them all,
::and inside cyberspace bind them.
::~Conor McKnight

:: IF you like my work please consider helping me keep making things like this
:: DONATE! The same as buying me a beer or a cup of tea/coffee :D <3
:: PayPal : https://paypal.me/wimbledonfc
:: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ZH9PFY62YSD7U&source=url
:: Crypto Currency wallets :
:: BTC BITCOIN : 3A7dMi552o3UBzwzdzqFQ9cTU1tcYazaA1
:: ETH ETHEREUM : 0xeD82e64437D0b706a55c3CeA7d116407E43d7257
:: SHIB SHIBA INU : 0x39443a61368D4208775Fd67913358c031eA86D59

:: Script Settings
:settings_load

::instead of just closing the window after our automated web tasking we pause to view and check once your happy you can set this to 0
:: 1 enabled
:: 0 disabled
set pause_window=1

:: End Edit DO NOT TOUCH ANYTHING BELOW THIS POINT UNLESS YOU KNOW WHAT YOUR DOING!

TITLE Dev Tools Programing Compiling Auto Installer ^| FFMPEG

::Elevate to admin rights
if defined varpass goto :start_exe

:start
net session >nul 2>&1
if %errorlevel% == 0 (
goto :admin
) else (
@pushd "%~dp0" & fltmc | find ^".^" && (powershell start '%~f0' ' %*' -verb runas 2>nul && exit /b)
)
goto :start
:admin

:start_loop
if "%~1"=="" (
start /wait /B "" "%~dp0%~nx0" go 2^>Nul
) else (
goto begin
)
goto start_loop
:begin
set varpass=1
::End elevation to admin

set root_path="%~dp0"

if %PROCESSOR_ARCHITECTURE%==x86 (
	set programs_path=%ProgramFiles(x86)%
	set system_folder=System32
) else (
	set programs_path=%ProgramFiles%
	set system_folder=SysWOW64
)
goto :next_download

:start_exe
if not defined pause_window (
goto :settings_load
)
::stuff

(
echo pacman -V
echo pacman -S mercurial texinfo autogen cmake gperf nasm patch unzip pax ed bison flex cvs svn clang meson mingw-w64-x86_64-ragel mingw-w64-x86_64-python3 mingw-w64-x86_64-meson
echo pacman -S git --noconfirm
echo pacman -S autoconf --noconfirm
echo pacman -S automake --noconfirm
echo pacman -S libtool --noconfirm
echo pacman -S make --noconfirm
echo pacman -S diffutils --noconfirm
echo pacman -S pkg-config --noconfirm
echo pacman -S yasm --noconfirm
echo wget http://www.colm.net/files/ragel/ragel-6.9.tar.gz ^&^& tar -zxvf ragel-6.9.tar.gz ^&^& cd $HOME/ragel-6.9 ^&^& ./configure --prefix=/usr CXXFLAGS="$CXXFLAGS -std=gnu^+^+98" ^&^& make ^&^& make install
echo cd $HOME ^&^& git clone --recursive https://github.com/rdp/ffmpeg-windows-build-helpers.git
echo cd $HOME/ffmpeg-windows-build-helpers ^&^& bash cross_compile_ffmpeg.sh ^&^& echo 3
)>"%root_path:"=%msys2.txt"
:: MSYS2 can't print to windows cmd so i made a way it can
for /f "usebackq tokens=*" %%a in (%root_path:"=%msys2.txt) do (
	for /f "delims=" %%x in ('%~d0\msys64\usr\bin\env.exe MSYSTEM^=MSYS2 /usr/bin/bash -lc "%%a"') do (
		for /f "delims=" %%t in ("%%x") do (
			set console=%%t
			echo !console!
		)
	)
	echo(^ )
)
del "%root_path:"=%msys2.txt"
echo Compiled to Directory : "%~d0\msys64\home\%USERNAME%\ffmpeg-windows-build-helpers\sandbox"
start "" "%~d0\msys64\home\%USERNAME%\ffmpeg-windows-build-helpers\sandbox"

goto :end_script

goto :next_download
:start_download
set downloadurl=%downloadurl: =%
FOR /f %%i IN ("%downloadurl:"=%") DO set filename="%%~ni"& set fileextension="%%~xi"
set downloadpath="%root_path:"=%%filename%%fileextension%"
(
echo Dim oXMLHTTP
echo Dim oStream
echo Set fso = CreateObject^("Scripting.FileSystemObject"^)
echo If Not fso.FileExists^("%downloadpath:"=%"^) Then
echo Set oXMLHTTP = CreateObject^("MSXML2.ServerXMLHTTP.6.0"^)
echo oXMLHTTP.Open "GET", "%downloadurl:"=%", False
echo oXMLHTTP.SetRequestHeader "User-Agent", "Mozilla/5.0 ^(Windows NT 10.0; Win64; rv:51.0^) Gecko/20100101 Firefox/51.0"
echo oXMLHTTP.SetRequestHeader "Referer", "https://www.google.co.uk/"
echo oXMLHTTP.SetRequestHeader "DNT", "1"
echo oXMLHTTP.Send
echo If oXMLHTTP.Status = 200 Then
echo Set oStream = CreateObject^("ADODB.Stream"^)
echo oStream.Open
echo oStream.Type = 1
echo oStream.Write oXMLHTTP.responseBody
echo oStream.SaveToFile "%downloadpath:"=%"
echo oStream.Close
echo End If
echo End If
echo ZipFile="%downloadpath:"=%"
echo ExtractTo="%root_path:"=%"
echo ext = LCase^(fso.GetExtensionName^(ZipFile^)^)
echo If NOT fso.FolderExists^(ExtractTo^) Then
echo fso.CreateFolder^(ExtractTo^)
echo End If
echo Set app = CreateObject^("Shell.Application"^)
echo Sub ExtractByExtension^(fldr, ext, dst^)
echo For Each f In fldr.Items
echo If f.Type = "File folder" Then
echo ExtractByExtension f.GetFolder, ext, dst
echo End If
echo If instr^(f.Path, "\%file_name_to_extract%"^) ^> 0 Then
echo If fso.FileExists^(dst ^& f.Name ^& "." ^& LCase^(fso.GetExtensionName^(f.Path^)^) ^) Then
echo Else
echo call app.NameSpace^(dst^).CopyHere^(f.Path^, 4^+16^)
echo End If
echo End If
echo Next
echo End Sub
echo If instr^(ZipFile, "zip"^) ^> 0 Then
echo ExtractByExtension app.NameSpace^(ZipFile^), "exe", ExtractTo
echo End If
if %file_name_to_extract% == * echo set FilesInZip = app.NameSpace^(ZipFile^).items
if %file_name_to_extract% == * echo app.NameSpace^(ExtractTo^).CopyHere FilesInZip, 4
if %delete_download% == 1 echo fso.DeleteFile ZipFile
echo Set fso = Nothing
echo Set objShell = Nothing
)>"%root_path:"=%%~n0.vbs"
cscript //nologo "%root_path:"=%%~n0.vbs"
del "%root_path:"=%%~n0.vbs"
:next_download
goto :skip_latest_download_link
:get_latest_download_link
::Get latest download link of a webpage
(
echo $url = "%grab_latest_url:"=%"
echo $html_tag = "%grab_latest_html_tag:"=%"
echo $matching_string = "%grab_latest_matching_string:"=%"
echo foreach^($i in %grab_low_range%..%grab_high_range%^){
echo $downloadUri = ^(^(Invoke-WebRequest $url -UseBasicParsing -MaximumRedirection 10^).Links ^| Where-Object $html_tag -like $matching_string^)[$i].href
echo if ^( -not ^([string]::IsNullOrEmpty^($downloadUri^)^) ^) {
echo $true_variable=%redirect_true_or_false%;
echo if ^($true_variable^) {
echo if ^($downloadUri -match "^^/"^) {
echo $var = [System.Uri]$url
echo $scheme = $var.Scheme
echo $domain = $var.Host
echo $downloadUri = $scheme ^+ "://" ^+ $domain ^+ $downloadUri
echo }
echo $downloadURL = $downloadUri
echo $request = Invoke-WebRequest -Method Head -Uri $downloadURL
echo $redirectedUri = $request.BaseResponse.ResponseUri.AbsoluteUri
echo $downloadUri = $redirectedUri
echo }
echo Write-Output $downloadUri ^| Out-File "%root_path:"=%%~n0-psoutput.txt"
echo break;
echo }
echo }
)>"%root_path:"=%%~n0-latest-download.ps1"
powershell -ExecutionPolicy Unrestricted -File "%root_path:"=%%~n0-latest-download.ps1" "%*" -Verb runAs
for /f "tokens=*" %%a in ('type "%root_path:"=%%~n0-psoutput.txt"') do set "latest_download_output=%%a"
del "%root_path:"=%%~n0-latest-download.ps1"
del "%root_path:"=%%~n0-psoutput.txt"
:skip_latest_download_link

	if not exist "%~d0\msys64\clang64.exe" (
		if not defined msys2_exe (
			set downloadurl=https://github.com/msys2/msys2-installer/releases/download/2022-12-16/msys2-x86_64-20221216.exe
			set file_name_to_extract=msys2.exe
			set delete_download=0
			set msys2_exe=true
			::my little trick for redirects and links that dont have a file name i will create one
			set downloadurl=!downloadurl!^?#/!file_name_to_extract!
			goto :start_download
		)
		if defined msys2_exe (
			call "%root_path:"=%%filename:"=%%fileextension:"=%" install --confirm-command
			del "%root_path:"=%%filename:"=%%fileextension:"=%"
		)
	)
	set PATH=%PATH%;%~d0\msys64\
	
	if not exist "%LocalAppData%\bin\NASM" (
		if not defined nasm_exe (
			set downloadurl=https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/win64/nasm-2.15.05-installer-x64.exe
			set file_name_to_extract=nasm_installer.exe
			set delete_download=0
			set nasm_exe=true
			::my little trick for redirects and links that dont have a file name i will create one
			set downloadurl=!downloadurl!^?#/!file_name_to_extract!
			goto :start_download
		)
		if defined nasm_exe (
			call "%root_path:"=%nasm_installer.exe"
		)
	)
	set PATH=%PATH%;%LocalAppData%\bin\NASM
	
	if not exist "%ProgramFiles%\Python39\python.exe" (
		if not defined python_exe (
			set downloadurl=https://www.python.org/ftp/python/3.9.9/python-3.9.9-amd64.exe
			set file_name_to_extract=python64.exe
			set delete_download=0
			set python_exe=true
			::my little trick for redirects and links that dont have a file name i will create one
			set downloadurl=!downloadurl!^?#/!file_name_to_extract!
			goto :start_download
		)
		if defined python_exe (
			call "%root_path:"=%%filename:"=%%fileextension:"=%" /quiet TargetDir="%ProgramFiles%\Python39" InstallAllUsers=1 PrependPath=1 AssociateFiles=1 Include_symbols=1 CompileAll=1 Shortcuts=1 Include_launcher=1 Include_test=1 Include_tcltk=1 Include_pip=1 Include_doc=1
		)
	)
	
	if not exist "%ProgramFiles%\Go\bin\go.exe" (
		if not defined go_exe (
			set downloadurl=https://go.dev/dl/go1.19.4.windows-amd64.msi
			set file_name_to_extract=go64.exe
			set delete_download=0
			set go_exe=true
			::my little trick for redirects and links that dont have a file name i will create one
			set downloadurl=!downloadurl!^?#/!file_name_to_extract!
			goto :start_download
		)
		if defined go_exe (
			call "%windir%\%system_folder%\msiexec.exe" /fa "%root_path:"=%%filename:"=%%fileextension:"=%" /qn
			call "%windir%\%system_folder%\msiexec.exe" /i "%root_path:"=%%filename:"=%%fileextension:"=%" /qn
			del "%root_path:"=%%filename:"=%%fileextension:"=%"
		)
	)
	
	if not exist "%~d0\Strawberry\perl\bin\perl.exe" (
		if not defined perl_exe (
			set downloadurl=https://strawberryperl.com/download/5.32.1.1/strawberry-perl-5.32.1.1-64bit.msi
			set file_name_to_extract=perl64.exe
			set delete_download=0
			set perl_exe=true
			::my little trick for redirects and links that dont have a file name i will create one
			set downloadurl=!downloadurl!^?#/!file_name_to_extract!
			goto :start_download
		)
		if defined perl_exe (
			call "%windir%\%system_folder%\msiexec.exe" /fa "%root_path:"=%%filename:"=%%fileextension:"=%" /qn
			call "%windir%\%system_folder%\msiexec.exe" /i "%root_path:"=%%filename:"=%%fileextension:"=%" /qn
			del "%root_path:"=%%filename:"=%%fileextension:"=%"
		)
	)	

goto :start_exe
:end_script

if %pause_window% == 1 pause

exit
