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
  !define REG_UNINSTALL "Software\Microsoft\Windows\CurrentVersion\Uninstall\SubtitlesFinder"

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
;Installer Sections

Section "Dummy Section" SecDummy

  SetOutPath "$INSTDIR"
  
  File SubtitlesFinder.lua
  
  ;Create uninstaller
  WriteUninstaller "$INSTDIR\${MAIN_NAME}-uninstall.exe"
  
  ;Register uninstaller into Add/Remove panel (for local user only)
  WriteRegStr HKCU "${REG_UNINSTALL}" "DisplayName" "VLC SubtitlesFinder"
  WriteRegStr HKCU "${REG_UNINSTALL}" "Publisher" "ThePanz"
  WriteRegStr HKCU "${REG_UNINSTALL}" "DisplayVersion" "${VERSION}"
  WriteRegDWord HKCU "${REG_UNINSTALL}" "EstimatedSize" 21 ;KB
  ; WriteRegStr HKCU "${REG_UNINSTALL}" "HelpLink" "${WEBSITE_LINK}"
  ;WriteRegStr HKCU "${REG_UNINSTALL}" "URLInfoAbout" "${WEBSITE_LINK}"
  WriteRegStr HKCU "${REG_UNINSTALL}" "InstallLocation" "$\"$INSTDIR$\""
  ;WriteRegStr HKCU "${REG_UNINSTALL}" "InstallSource" "$\"$EXEDIR$\""
  WriteRegDWord HKCU "${REG_UNINSTALL}" "NoModify" 1
  WriteRegDWord HKCU "${REG_UNINSTALL}" "NoRepair" 1
  WriteRegStr HKCU "${REG_UNINSTALL}" "UninstallString" "$\"$INSTDIR\${MAIN_NAME}-uninstall.exe$\""
  WriteRegStr HKCU "${REG_UNINSTALL}" "Comments" "Uninstalls VLC SubtitlesFinder plugin."  

SectionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  Delete "$INSTDIR\SubtitlesFinder.lua"

  Delete "$INSTDIR\SubtitlesFinder-uninstall.exe"

SectionEnd
