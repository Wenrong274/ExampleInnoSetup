
#define MyAppGUID "{{D0D7EBDD-2493-4086-A306-AB012D2AFA93}"
#define MyAppName "Examle"
#define MyAppFolder "ExampleFolder"
#define MyAppSetupExeName "Examle"

#define MyAppExeName "Examle.exe"
#define MyAppURL "https://wenrongdev.com/"
#define MyAppPublisher "wen rong studio"

[Setup]
AppId={#MyAppGUID}
AppName={#MyAppName}
AppVersion=0.1.0
AppVerName={#MyAppName}
AppPublisher = {#MyAppPublisher}
AppPublisherURL = {#MyAppURL}
AppSupportURL = {#MyAppURL}
AppUpdatesURL = {#MyAppURL}
Compression = lzma2
DefaultDirName={commonpf32}\{#MyAppFolder}
DisableProgramGroupPage=yes
DefaultGroupName={#MyAppName}
UninstallDisplayIcon={app}ForwardSlash{#MyAppExeName}
SolidCompression = no
OutputDir = "Setup"
OutputBaseFilename = {#MyAppSetupExeName}
ShowLanguageDialog=yes

// 是否需要分割 
DiskSpanning=yes
SlicesPerDisk=3
DiskSliceSize=1566000000
///

[Languages]
Name: EN; MessagesFile: "compiler:Default.isl"
Name: CT; MessagesFile: "compiler:Languages\Unofficial\ChineseTraditional.isl"
Name: CS; MessagesFile: "compiler:Languages\Unofficial\ChineseSimplified.isl"
Name: JP; MessagesFile: "compiler:Languages\Japanese.isl"

[CustomMessages]
MyAppName = {#MyAppName}
MyAppVerName = {#MyAppName} %1

[Messages] 
BeveledLabel = {#MyAppURL}
  
[Dirs]
Name: "{app}"; Permissions: everyone-full

[Files]
Source: "{#MyAppFolder}\*"; DestDir: "{app}\{#MyAppFolder}"; Flags: ignoreversion recursesubdirs

[Icons]
//Name: "{group}\{#MyAppFolder}\{cm:MyAppName}"; Filename: "{app}\{#MyAppFolder}\{#MyAppExeName}"
//Name: "{group}\{cm:UninstallProgram,{cm:MyAppName}}"; Filename: "{uninstallexe}"
Name: "{userdesktop}\{cm:MyAppName}"; Filename: "{app}\{#MyAppFolder}\{#MyAppExeName}";

[Code]
function GetNumber(var temp: String): Integer;
var
  part: String;
  pos1: Integer;
begin
  if Length(temp) = 0 then
  begin
    Result := -1;
    Exit;
  end;
    pos1 := Pos('.', temp);
    if (pos1 = 0) then
    begin
      Result := StrToInt(temp);
    temp := '';
    end
    else
    begin
    part := Copy(temp, 1, pos1 - 1);
      temp := Copy(temp, pos1 + 1, Length(temp));
      Result := StrToInt(part);
    end;
end;

function CompareInner(var temp1, temp2: String): Integer;
var
  num1, num2: Integer;
begin
    num1 := GetNumber(temp1);
  num2 := GetNumber(temp2);
  if (num1 = -1) or (num2 = -1) then
  begin
    Result := 0;
    Exit;
  end;
      if (num1 > num2) then
      begin
        Result := 1;
      end
      else if (num1 < num2) then
      begin
        Result := -1;
      end
      else
      begin
        Result := CompareInner(temp1, temp2);
      end;
end;

function CompareVersion(str1, str2: String): Integer;
var
  temp1, temp2: String;
begin
    temp1 := str1;
    temp2 := str2;
    Result := CompareInner(temp1, temp2);
end;

function InitializeSetup(): Boolean;
var
  oldVersion: String;
  uninstaller: String;
  ErrorCode: Integer;
  vCurID      :String;
  vCurAppName :String;
begin
  vCurID:= '{#SetupSetting("AppId")}';
  vCurAppName:= '{#SetupSetting("AppName")}';
  vCurID:= Copy(vCurID, 2, Length(vCurID) - 1);

  if RegKeyExists(HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' + vCurID + '_is1') then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE,
      'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' + vCurID + '_is1',
      'DisplayVersion', oldVersion);
    if (CompareVersion(oldVersion, '{#SetupSetting("AppVersion")}') < 0) then      
    begin
      if MsgBox('Version ' + oldVersion + ' of ' + vCurAppName + ' is already installed. Continue to use this old version?',
        mbConfirmation, MB_YESNO) = IDYES then
      begin
        Result := False;
      end
      else
      begin
          RegQueryStringValue(HKEY_LOCAL_MACHINE,
            'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' + vCurID + '_is1',
            'UninstallString', uninstaller);
          ShellExec('runas', uninstaller, '/SILENT', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
          Result := True;
      end;
    end
    else
    begin
      MsgBox('Version ' + oldVersion + ' of ' + vCurAppName + ' is already installed. This installer will exit.',
        mbInformation, MB_OK);
      Result := False;
    end;
  end
  else
  begin
    Result := True;
  end;
end;
