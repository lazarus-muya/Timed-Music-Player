; -------------------------------
; TimedPlayer Installer Script
; -------------------------------

[Setup]
; Basic application info
AppName=Timed Player
AppVersion=1.0.0
AppPublisher=Lazarus Muya

; Installation directories
DefaultDirName={pf}\TimedPlayer
DefaultGroupName=Timed Player
OutputDir=.\Installer
OutputBaseFilename=TimedPlayerInstaller

; Installer options
Compression=lzma
SolidCompression=yes
WizardStyle=modern
DisableDirPage=no
DisableProgramGroupPage=no
UninstallDisplayIcon={app}\TimedPlayer.exe

; Use your signed EXE for shortcuts
SetupIconFile=C:\Users\dev\Documents\projects\flutter\timed_app\assets\images\disc.ico

; Require admin privileges
; PrivilegesRequired=admin

[Files]
; Copy the signed EXE to the installation folder
Source: "C:\Users\dev\Documents\projects\flutter\timed_app\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

; Copy additional DLLs or dependencies if needed
; Example:
; Source: "C:\Users\dev\Documents\projects\flutter\timed_app\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; Desktop shortcut
Name: "{group}\Timed Player"; Filename: "{app}\TimedPlayer.exe"; WorkingDir: "{app}"; IconFilename: "{app}\TimedPlayer.exe"

; Quick Launch shortcut
Name: "{userdesktop}\Timed Player"; Filename: "{app}\TimedPlayer.exe"; WorkingDir: "{app}"; IconFilename: "{app}\TimedPlayer.exe"

[Run]
; Launch the app after installation
Filename: "{app}\TimedPlayer.exe"; Description: "Launch Timed Player"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Cleanup on uninstall
Type: filesandordirs; Name: "{app}"
