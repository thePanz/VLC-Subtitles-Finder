Function AddRegistry
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
FunctionEnd
