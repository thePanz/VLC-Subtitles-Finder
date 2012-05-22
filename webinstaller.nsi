;NSIS Modern User Interface
; VLC Subtitles Finder installer script
;Written by thePanz

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;General
  
  !define MAIN_NAME "SubtitlesFinder"
  !define VERSION "1.x-dev"
  !define AUTHOR "ThePanz"
  !define REG_UNINSTALL "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MAIN_NAME}"
  !define URL_LUA "https://raw.github.com/thePanz/VLC-Subtitles-Finder/master/SubtitlesFinder.lua"

  ;Name and file
  Name "VLC Subtitles Finder"
  OutFile "${MAIN_NAME}-webinstall.exe"

  ;Default installation folder
  InstallDir "$APPDATA\vlc\lua\extensions"

  ;Request application privileges for Windows Vista
  RequestExecutionLevel user

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  ; !insertmacro MUI_PAGE_LICENSE "${NSISDIR}\Docs\Modern UI\License.txt"
  ;!insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  
;--------------------------------
;Languages
  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
; Include Functions
!include "functions.nsh"
!addPluginDir "."

;--------------------------------
;Installer Sections
Section "Dummy Section" SecDummy

  SetOutPath "$INSTDIR"
  
  DetailPrint "Downloading SubtitlesFinder.lua from ${URL_LUA}"
  
  ; NSISdl::download do not work with HTTPs urls
  ; NSISdl::download /TIMEOUT=30000 ${URL_LUA} "$INSTDIR\SubtitlesFinder.lua"
  inetc::get /NOCANCEL /CONNECTTIMEOUT=30000 ${URL_LUA} "$INSTDIR\SubtitlesFinder.lua"

  Pop $R0
  
  StrCmp $R0 OK success
    SetDetailsView show
    DetailPrint "Error downloading SubtitlesFinder.lua: $R0"
    MessageBox MB_OK "Error downloading SubtitlesFinder.lua: $R0"
    Goto end
  
  success:
    Call AddRegistry
  
  end:
    ; nothing to do here!
  
SectionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  Delete "$INSTDIR\SubtitlesFinder.lua"
  Delete "$INSTDIR\${MAIN_NAME}-uninstall.exe"

SectionEnd