;NSIS Modern User Interface
; VLC Subtitles Finder installer script
;Written by thePanz

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;General
  
  !define MAIN_NAME "SubtitlesFinder"
  !define VERSION "1.1.0"
  !define REG_UNINSTALL "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MAIN_NAME}"

  ;Name and file
  Name "VLC Subtitles Finder (v. ${VERSION})"
  OutFile "${MAIN_NAME}-${VERSION}-install.exe"

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

;--------------------------------
;Installer Sections
Section "Dummy Section" SecDummy

  SetOutPath "$INSTDIR"
  File SubtitlesFinder.lua
  Call AddRegistry
SectionEnd

;--------------------------------
;Uninstaller Section
Section "Uninstall"
  Delete "$INSTDIR\${MAIN_NAME}.lua"
  Delete "$INSTDIR\${MAIN_NAME}-uninstall.exe"
SectionEnd
