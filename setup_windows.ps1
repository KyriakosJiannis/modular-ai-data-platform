# Configure Ollama to accept connections from Docker containers on Windows
# Run this script in an elevated PowerShell session (as Administrator).

function Set-EnvIfDifferent {
    param(
        [string]$Name,
        [string]$Value
    )

    $current = [System.Environment]::GetEnvironmentVariable($Name, 'User')
    if ($current) {
        if ($current -ne $Value) {
            Write-Warning "$Name already set to '$current'; overwriting with '$Value'"
            [System.Environment]::SetEnvironmentVariable($Name, $Value, 'User')
        } else {
            Write-Host "$Name already set to desired value '$Value'; no change needed."
        }
    } else {
        [System.Environment]::SetEnvironmentVariable($Name, $Value, 'User')
        Write-Host "$Name set to '$Value'."
    }
}

Set-EnvIfDifferent 'OLLAMA_HOST' '0.0.0.0'
Set-EnvIfDifferent 'OLLAMA_ORIGINS' '*'

Write-Host "Ollama environment variables set. Restart Ollama to apply changes." -ForegroundColor Green
