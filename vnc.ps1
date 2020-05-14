param (
    [Parameter(Mandatory=$true)][string]$session = "",
    [string]$port = "5901",
    [string]$vncPasswordPath = ".vnc/passwd",
    [string]$password = ""
 )

Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class Tricks {
     [DllImport("user32.dll")]
     [return: MarshalAs(UnmanagedType.Bool)]
     public static extern bool SetForegroundWindow(IntPtr hWnd);
  }
"@

if(!(Test-Path "$PSScriptRoot\3rdparty")) {
    New-Item "$PSScriptRoot\3rdparty" -itemtype directory
}
if(!(Test-Path "$PSScriptRoot\tmp")) {
    New-Item "$PSScriptRoot\tmp" -itemtype directory
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if(!(Test-Path "$PSScriptRoot\3rdparty\plink.exe")) {
    Invoke-WebRequest -Uri "https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe" -OutFile "$PSScriptRoot\3rdparty\plink.exe"
}
if(!(Test-Path "$PSScriptRoot\3rdparty\pscp.exe")) {
    Invoke-WebRequest -Uri "https://the.earth.li/~sgtatham/putty/latest/w64/pscp.exe" -OutFile "$PSScriptRoot\3rdparty\pscp.exe"
}
if(!(Test-Path "$PSScriptRoot\3rdparty\vncviewer.exe")) {
    Invoke-WebRequest -Uri "https://bintray.com/tigervnc/stable/download_file?file_path=vncviewer64-1.10.1.exe" -OutFile "$PSScriptRoot\3rdparty\vncviewer.exe"
}

if($password -eq "") {
    $securepassword = $( Read-Host -assecurestring "Please enter your password" )
    $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securepassword))
}
Start-Process -FilePath $PSScriptRoot\3rdparty\pscp.exe -ArgumentList "-pw $password `"${session}:${vncPasswordPath}`" `"$PSScriptRoot/tmp/passwd`""
$plink = Start-Process -FilePath $PSScriptRoot\3rdparty\plink.exe -ArgumentList "-load `"$session`" -pw $password -batch" -PassThru
Clear-Variable password
$vncviewer = Start-Process -FilePath $PSScriptRoot\3rdparty\vncviewer.exe -ArgumentList "localhost:$port -passwd `"$PSScriptRoot/tmp/passwd`" -Maximize −AcceptClipboard −SendClipboard" -PassThru # -NoNewWindow -Wait
sleep 1
[void] [Tricks]::SetForegroundWindow($vncviewer.MainWindowHandle)
$vncviewer.WaitForExit()
Remove-Item $PSScriptRoot\tmp\passwd
Stop-Process $plink