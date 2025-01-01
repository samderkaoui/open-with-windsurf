# Check admin privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList ("-File", $MyInvocation.MyCommand.Path)
    exit
}

# Define Windsurf path
$windsurfExePath = [System.IO.Path]::Combine($env:LOCALAPPDATA, "Programs", "windsurf", "Windsurf.exe")

if (Test-Path $windsurfExePath) {
    function Run-RegCommand {
        param ([string]$command)
        $process = Start-Process -FilePath "reg.exe" -ArgumentList $command -NoNewWindow -Wait -PassThru
        if ($process.ExitCode -ne 0) {
            Write-Host "Failed to execute: reg.exe $command"
            exit 1
        }
    }

    # Background menu
    $backgroundPath = "HKEY_CLASSES_ROOT\Directory\Background\shell\Open with Windsurf"
    Run-RegCommand "ADD `"$backgroundPath`" /ve /d `"Open with Windsurf`" /f"
    Run-RegCommand "ADD `"$backgroundPath`" /v Icon /d `"$windsurfExePath`" /f"
    Run-RegCommand "ADD `"$backgroundPath\command`" /ve /d `"\`"$windsurfExePath\`" \`"%V\`"`" /f"

    # Folder menu
    $folderPath = "HKEY_CLASSES_ROOT\Directory\shell\Open with Windsurf"
    Run-RegCommand "ADD `"$folderPath`" /ve /d `"Open with Windsurf`" /f"
    Run-RegCommand "ADD `"$folderPath`" /v Icon /d `"$windsurfExePath`" /f"
    Run-RegCommand "ADD `"$folderPath\command`" /ve /d `"\`"$windsurfExePath\`" \`"%1\`"`" /f"

    # File menu
    $filePath = "HKEY_CLASSES_ROOT\*\shell\Open with Windsurf"
    Run-RegCommand "ADD `"$filePath`" /ve /d `"Open with Windsurf`" /f"
    Run-RegCommand "ADD `"$filePath`" /v Icon /d `"$windsurfExePath`" /f"
    Run-RegCommand "ADD `"$filePath\command`" /ve /d `"\`"$windsurfExePath\`" \`"%1\`"`" /f"

    Write-Host "Context menus installed successfully."
} else {
    Write-Host "Error: Windsurf executable not found at $windsurfExePath"
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")