Unicode true
ManifestDPIAware true
!include MUI2.nsh

!define APP_NAME "GNZ Admin Pro"
!define COMPANY_NAME "GNZ Oil Services"
!define APP_EXE "GNZ Admin Pro.exe"
!define SOURCE_DIR "..\release\GNZ Admin Pro Flutter"
!define INSTALL_DIR "$LOCALAPPDATA\GNZ Oil Services\GNZ Admin Pro"
!define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\GNZ Admin Pro"
!define APP_ICON "..\windows\runner\resources\app_icon.ico"

Name "${APP_NAME}"
OutFile "..\release\GNZ Admin Pro Flutter Setup.exe"
InstallDir "${INSTALL_DIR}"
RequestExecutionLevel user
BrandingText "${COMPANY_NAME}"
Icon "${APP_ICON}"
UninstallIcon "${APP_ICON}"

VIProductVersion "1.0.5.0"
VIAddVersionKey "ProductName" "${APP_NAME}"
VIAddVersionKey "CompanyName" "${COMPANY_NAME}"
VIAddVersionKey "FileDescription" "${APP_NAME} Installer"
VIAddVersionKey "FileVersion" "1.0.5.0"
VIAddVersionKey "ProductVersion" "1.0.5.0"
VIAddVersionKey "LegalCopyright" "Copyright (C) 2026 ${COMPANY_NAME}"

!define MUI_ICON "${APP_ICON}"
!define MUI_UNICON "${APP_ICON}"
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE "Instalar GNZ Admin Pro"
!define MUI_WELCOMEPAGE_TEXT "Este asistente instalara GNZ Admin Pro en una ubicacion fija del usuario. No necesitas seleccionar carpeta.$\r$\n$\r$\nSi la app esta abierta, se cerrara para actualizar los archivos correctamente."
!define MUI_FINISHPAGE_TITLE "GNZ Admin Pro esta listo"
!define MUI_FINISHPAGE_TEXT "La instalacion termino correctamente."
!define MUI_FINISHPAGE_RUN "$INSTDIR\${APP_EXE}"
!define MUI_FINISHPAGE_RUN_TEXT "Abrir GNZ Admin Pro"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_UNFINISHPAGE_NOAUTOCLOSE

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "Spanish"

Section "Install"
  SetOverwrite on
  DetailPrint "Preparando actualizacion de GNZ Admin Pro..."
  nsExec::ExecToLog 'taskkill /IM "${APP_EXE}" /F'
  Sleep 1200

  CreateDirectory "$INSTDIR"
  SetOutPath "$INSTDIR"

  Delete "$INSTDIR\${APP_EXE}"
  Delete "$INSTDIR\flutter_windows.dll"
  RMDir /r "$INSTDIR\data"

  SetOutPath "$INSTDIR"
  File /r "${SOURCE_DIR}\*.*"

  WriteUninstaller "$INSTDIR\Uninstall.exe"

  CreateDirectory "$SMPROGRAMS\${COMPANY_NAME}"
  CreateShortcut "$SMPROGRAMS\${COMPANY_NAME}\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}" "" "$INSTDIR\${APP_EXE}" 0
  CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}" "" "$INSTDIR\${APP_EXE}" 0

  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayName" "${APP_NAME}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayVersion" "1.0.5"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "Publisher" "${COMPANY_NAME}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayIcon" "$INSTDIR\${APP_EXE}"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKCU "${UNINSTALL_KEY}" "QuietUninstallString" "$INSTDIR\Uninstall.exe /S"
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoModify" 1
  WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoRepair" 1

  IfSilent +1 +2
  Exec "$INSTDIR\${APP_EXE}"
SectionEnd

Section "Uninstall"
  nsExec::ExecToLog 'taskkill /IM "${APP_EXE}" /F'
  Sleep 800
  Delete "$DESKTOP\${APP_NAME}.lnk"
  Delete "$SMPROGRAMS\${COMPANY_NAME}\${APP_NAME}.lnk"
  RMDir "$SMPROGRAMS\${COMPANY_NAME}"
  DeleteRegKey HKCU "${UNINSTALL_KEY}"
  RMDir /r "$INSTDIR"
SectionEnd
