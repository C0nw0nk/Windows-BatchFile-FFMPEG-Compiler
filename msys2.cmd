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

:: FFMPEG build type to compile
:: 1. Both Win32 and Win64
:: 2. Win32 (32-bit only)
:: 3. Win64 (64-bit only)
:: 4. Local native
set ffmpeg_arch=3

set ffmpeg_folder_name=ffmpeg

:: 1 enabled
:: 0 disabled
set quick_cross_compile_ffmpeg_fdk_aac_and_x264_using_packaged_mingw64=0

::mingw32 | -mingw64 | -ucrt64 | -clang64 | -msys
::set MSYSTEM=MSYS
::set MSYSTEM=MINGW32
::set MSYSTEM=MINGW64
::set MSYSTEM=UCRT64
::set MSYSTEM=CLANG64
::set MSYSTEM=CLANG32
::set MSYSTEM=CLANGARM64

set MSYS2_NOSTART=yes
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=enabled_from_arguments

:: https://conemu.github.io/
::set MSYSCON=conemu.exe
::conemu64.exe
::set shell_type=bash.exe
::set shell_type=mintty.exe
::set shell_type=env.exe

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

::Build file paths for msys2 to use for its libraries includes and compilers
(
echo export LD_LIBRARY_PATH=/clang32/lib:/clang64/lib:/clangarm64/lib:/ucrt64/lib:/mingw32/lib:/mingw64/lib:/usr/local/lib:/usr/share/lib:$LD_LIBRARY_PATH
echo export PKG_CONFIG_PATH=/clang32/lib/pkgconfig:/clang64/lib/pkgconfig:/clangarm64/lib/pkgconfig:/ucrt64/lib/pkgconfig:/mingw32/lib/pkgconfig:/mingw64/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/share/lib/pkgconfig:$PKG_CONFIG_PATH
echo FT2_CFLAGS=$^(pkg-config --cflags freetype2^)
echo FT2_LIBS=$^(pkg-config --libs freetype2^)
echo export MSYS2_ARG_CONV_EXCL=^"^*^"
echo export MSYS_NO_PATHCONV=1
echo export PATH=$HOME/%ffmpeg_folder_name%/sandbox/cross_compilers/mingw-w64-i686/bin:$HOME/%ffmpeg_folder_name%/sandbox/cross_compilers/mingw-w64-i686/i686-w64-mingw32/bin:$HOME/%ffmpeg_folder_name%/sandbox/cross_compilers/mingw-w64-x86_64/bin:$HOME/%ffmpeg_folder_name%/sandbox/cross_compilers/mingw-w64-x86_64/x86_64-w64-mingw32/bin:/usr/bin:/mingw64/bin:/mingw32/bin:/clangarm64/bin:/clang64/bin:/clang32/bin:/mingw64/share:$PATH
echo export XDG_DATA_HOME=/mingw64/share
echo export XDG_DATA_DIRS=/mingw64/share
)>"%root_path:"=%msys2_vars.txt"
:: MSYS2 can't print to windows cmd so i made a way it can
for /f "usebackq tokens=*" %%a in (%root_path:"=%msys2_vars.txt) do (
	if not defined msys_variables (
		set msys_variables=%%a
	) else (
		set msys_variables=!msys_variables! ^&^& %%a
	)
)
echo !msys_variables!
del "%root_path:"=%msys2_vars.txt"
::End build vars

::Get march
(
echo gcc -march=native -Q --help=target ^| grep march ^| tr -d '\n'
)>"%root_path:"=%msys2_march.txt"
:: MSYS2 can't print to windows cmd so i made a way it can
for /f "usebackq tokens=*" %%a in (%root_path:"=%msys2_march.txt) do (
	set MSYSTEM=MSYS
	for /f "delims=" %%x in ('%~d0\msys64\usr\bin\env.exe MSYSTEM^=MSYS /usr/bin/bash -lc "%%a"') do (
		for /f "delims=" %%t in ("%%x") do (
			set console=%%t
			set gcc_march_value=!console:~32,-43!
			echo !console!
		)
	)
	echo(^ )
)
del "%root_path:"=%msys2_march.txt"
set "gcc_march_value=%gcc_march_value: =%"
::End get march

(
echo gcc -march=native -Q --help=target ^| grep march
echo pacman -V ^&^& !msys_variables! ^&^& echo $PATH
echo pacman -Su --needed ^&^& echo y
echo pacman -S python-pip --needed --noconfirm
echo python -m pip install docwriter
echo pip install vharfbuzz
echo pacman -S mingw-w64-x86_64-arm-none-eabi-toolchain mingw-w64-x86_64-avr-toolchain mingw-w64-x86_64-eda mingw-w64-x86_64-kde-applications mingw-w64-x86_64-kde-education mingw-w64-x86_64-kde-graphics mingw-w64-x86_64-kde-utilities mingw-w64-x86_64-kdesdk mingw-w64-x86_64-kf5 mingw-w64-x86_64-perl-modules mingw-w64-x86_64-qt-static mingw-w64-x86_64-qt5 mingw-w64-x86_64-qt5-debug mingw-w64-x86_64-qt5-static mingw-w64-x86_64-qt6 mingw-w64-x86_64-qt6-debug mingw-w64-x86_64-riscv64-unknown-elf-toolchain mingw-w64-x86_64-texlive-full mingw-w64-x86_64-texlive-scheme-basic mingw-w64-x86_64-texlive-scheme-context mingw-w64-x86_64-texlive-scheme-full mingw-w64-x86_64-texlive-scheme-gust mingw-w64-x86_64-texlive-scheme-medium mingw-w64-x86_64-texlive-scheme-small mingw-w64-x86_64-texlive-scheme-tetex mingw-w64-x86_64-toolchain mingw-w64-x86_64-vulkan-devel net-utils perl-modules python-modules sys-utils tesseract-data utilities VCS vim-plugins --needed --noconfirm
echo pacman -S mingw-w64-clang-x86_64-vulkan-devel mingw-w64-x86_64-chafa perl-modules python-modules mingw-w64-x86_64-toolchain perl-devel perl-doc python-brotli --needed --noconfirm
echo pacman -S perl-Compress-Bzip2 mingw-w64-x86_64-python-brotli brotli-devel glib2-devel setconf mingw-w64-x86_64-SDL2 libbz2-devel mingw-w64-cross-zlib mingw-w64-clang-i686-libc^+^+ mingw-w64-x86_64-libc^+^+ mingw-w64-x86_64-lld mingw-w64-clang-i686-xavs mingw-w64-clang-x86_64-xavs mingw-w64-i686-xavs mingw-w64-x86_64-xavs mingw-w64-ucrt-x86_64-xavs gcc gcc-fortran gcc-libs mingw-w64-i686-gcc gengetopt mingw-w64-x86_64-globjects mingw-w64-x86_64-gtkada mingw-w64-x86_64-gcc-ada mingw-w64-cross-gcc mingw-w64-x86_64-dlfcn mingw-w64-x86_64-freetype mingw-w64-x86_64-mpg123 mingw-w64-x86_64-gst-plugins-good mingw-w64-ucrt-x86_64-opencv mingw-w64-x86_64-libsamplerate --needed --noconfirm
echo pacman -S mercurial texinfo autogen cmake gperf nasm patch unzip pax ed bison flex cvs svn clang meson mingw-w64-x86_64-ragel python mingw-w64-x86_64-python3 mingw-w64-x86_64-meson --needed --noconfirm
echo pacman -S base-devel gcc vim cmake --needed --noconfirm
echo pacman -S mingw-w64-x86_64-gnome-common --needed --noconfirm
echo pacman -S mingw-w64-x86_64-htslib --needed --noconfirm
echo pacman -S git --needed --noconfirm
echo pacman -S autoconf --needed --noconfirm
echo pacman -S automake --needed --noconfirm
echo pacman -S libtool --needed --noconfirm
echo pacman -S make --needed --noconfirm
echo pacman -S diffutils --needed --noconfirm
echo pacman -S pkgconfig --needed --noconfirm
echo pacman -S yasm nasm --needed --noconfirm
echo !msys_variables! ^&^& wget http://www.colm.net/files/ragel/ragel-6.9.tar.gz ^&^& tar -zxvf ragel-6.9.tar.gz ^&^& cd $HOME/ragel-6.9 ^&^& ./configure --prefix=/usr CXXFLAGS=^"$CXXFLAGS -std=gnu^+^+98^" ^&^& make -j$^(nproc^) ^&^& make install
echo !msys_variables! ^&^& cd $HOME ^&^& git clone --recursive https://github.com/rdp/ffmpeg-windows-build-helpers.git %ffmpeg_folder_name%
echo !msys_variables! ^&^& cd $HOME/%ffmpeg_folder_name% ^&^& bash cross_compile_ffmpeg.sh --build-intel-qsv=y --disable-nonfree=y --compiler-flavors=win64 --cflags=-march=%gcc_march_value% ^&^& echo %ffmpeg_arch%
if %quick_cross_compile_ffmpeg_fdk_aac_and_x264_using_packaged_mingw64% == 1 echo !msys_variables! ^&^& cd $HOME/%ffmpeg_folder_name%/quick_build ^&^& bash quick_cross_compile_ffmpeg_fdk_aac_and_x264_using_packaged_mingw64.sh
)>"%root_path:"=%msys2.txt"
:: MSYS2 can't print to windows cmd so i made a way it can
for /f "usebackq tokens=*" %%a in (%root_path:"=%msys2.txt) do (
	set MSYSTEM=MSYS
	for /f "delims=" %%x in ('%~d0\msys64\usr\bin\env.exe MSYSTEM^=MSYS /usr/bin/bash -lc "%%a"') do (
		for /f "delims=" %%t in ("%%x") do (
			set console=%%t
			echo !console!
		)
	)
	echo(^ )
)
del "%root_path:"=%msys2.txt"
echo Compiled to Directory : "%~d0\msys64\home\%USERNAME%\%ffmpeg_folder_name%\sandbox"
start "" "%~d0\msys64\home\%USERNAME%\%ffmpeg_folder_name%\sandbox"

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
if [%file_name_to_extract%]==[*] echo set FilesInZip = app.NameSpace^(ZipFile^).items
if [%file_name_to_extract%]==[*] echo app.NameSpace^(ExtractTo^).CopyHere FilesInZip, 4
if [%delete_download%]==[1] echo fso.DeleteFile ZipFile
echo Set fso = Nothing
echo Set objShell = Nothing
)>"%root_path:"=%%~n0.vbs"
cscript //nologo "%root_path:"=%%~n0.vbs"
del "%root_path:"=%%~n0.vbs"
:next_download

	if not exist "%~d0\msys64\clang64.exe" (
		if not defined msys2_exe (
			set downloadurl=https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-x86_64-latest.exe
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
	set PATH=%PATH%;%~d0\msys64\;%~d0\msys64\usr\bin;%~d0\msys64\mingw64\bin;%~d0\msys64\mingw32\bin;%~d0\msys64\clangarm64\bin;%~d0\msys64\clang64\bin;%~d0\msys64\clang32\bin

goto :start_exe
:end_script

if %pause_window% == 1 pause

exit
