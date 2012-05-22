Function AddRegistry
  ;Create uninstaller
  WriteUninstaller "$INSTDIR\${MAIN_NAME}-uninstall.exe"
  
  ;Register uninstaller into Add/Remove panel (for local user only)
  WriteRegStr HKCU "${REG_UNINSTALL}" "DisplayName" "VLC ${MAIN_NAME}"
  WriteRegStr HKCU "${REG_UNINSTALL}" "Publisher" "${AUTHOR}"
  WriteRegStr HKCU "${REG_UNINSTALL}" "DisplayVersion" "${VERSION}"
  WriteRegDWord HKCU "${REG_UNINSTALL}" "EstimatedSize" 21 ;KB
  ; WriteRegStr HKCU "${REG_UNINSTALL}" "HelpLink" "${WEBSITE_LINK}"
  ;WriteRegStr HKCU "${REG_UNINSTALL}" "URLInfoAbout" "${WEBSITE_LINK}"
  WriteRegStr HKCU "${REG_UNINSTALL}" "InstallLocation" "$\"$INSTDIR$\""
  ;WriteRegStr HKCU "${REG_UNINSTALL}" "InstallSource" "$\"$EXEDIR$\""
  WriteRegDWord HKCU "${REG_UNINSTALL}" "NoModify" 1
  WriteRegDWord HKCU "${REG_UNINSTALL}" "NoRepair" 1
  WriteRegStr HKCU "${REG_UNINSTALL}" "UninstallString" "$\"$INSTDIR\${MAIN_NAME}-uninstall.exe$\""
  WriteRegStr HKCU "${REG_UNINSTALL}" "Comments" "Uninstall VLC ${MAIN_NAME} plugin."  
FunctionEnd
