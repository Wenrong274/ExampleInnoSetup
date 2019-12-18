# Inno Setup Simple use

## Install

去官網下載 [Inno Setup][1]，請下載 **Stable Release** 版本。

## Add Language

1. 下載官方提供的 [Github][2]，直接下載 **Releases** 版本，完成後解壓縮。
2. 複製 `root/Files/Languages` 資料夾，貼上並且覆蓋 **Inno Setup 安裝資料夾**。![img_1]

## 使用方式

可以參考以下腳本，也可以自己寫，不知道寫法可以參考[官方文件][3]。

``` Pascal

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

```

## 修改方式

假如是使用複製舊有的 `.iss 檔`，只需要修改幾個需要注意的文字即可。

正常的資料夾結構

| Folder      | Description             |
| :---------- | :---------------------- |
| ExampleFolder      | 打包前的資料夾          |
| Setup       | Inno Setup 輸出的資料夾 |
| .iss        | Inno Setup Script       |

![img_2]

### 修改 .iss

``` Pascal
#define MyAppGUID "GUID"
#define MyAppName "Examle"
#define MyAppFolder "ExampleFolder"
#define MyAppSetupExeName "Examle"
#define MyAppExeName "Examle.exe"
#define MyAppURL "https://wenrongdev.com/"
#define MyAppPublisher "wen rong studio"
```

### 需修改地方

| Arg               | Description                                        |
| :---------------- | :------------------------------------------------- |
| MyAppGUID         | 安裝系統 GUID，產生方式為 `Tools/Generated GUID`。 |
| MyAppName         | 桌面路徑名稱  。                                   |
| MyAppFolder       | 安裝目錄名稱。                                     |
| MyAppSetupExeName | Inno Setup 輸出安裝檔名稱 。                       |

#### 取得 GUID 方法

![img_3]

________________________________________________________________________________

[1]:http://www.jrsoftware.org/isinfo.php
[2]:https://github.com/jrsoftware/issrc
[3]:http://www.jrsoftware.org/ishelp/
[img_1]: https://imgur.com/3gD0X18.jpg
[img_2]: https://imgur.com/AXDhz5x.jpg
[img_3]: https://imgur.com/d05PwU1.jpg
